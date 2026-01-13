import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_manager/bloc/task_event.dart';
import 'package:task_manager/bloc/task_state.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/task_repository.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  TaskBloc({required this.taskRepository}) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<SearchTasks>(_onSearchTasks);
    on<SyncTasks>(_onSyncTasks);

    _monitorConnectivity();
  }

  void _monitorConnectivity() async {
    // Check initial connectivity
    final initialResult = await _connectivity.checkConnectivity();
    add(_ConnectivityChanged(
      isOnline: initialResult != ConnectivityResult.none,
    ) as TaskEvent);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      add(_ConnectivityChanged(
        isOnline: result != ConnectivityResult.none,
      ) as TaskEvent);

      // Sync tasks when coming back online
      if (result != ConnectivityResult.none) {
        add(SyncTasks());
      }
    });
  }

  Future<void> _onLoadTasks(
      LoadTasks event,
      Emitter<TaskState> emit,
      ) async {
    emit(state.copyWith(status: TaskStatus.loading));

    try {
      final tasks = await taskRepository.getTasks();

      // Check for pending sync tasks
      final hasPendingSync = await taskRepository.localStorage.hasPendingSyncTasks();

      emit(state.copyWith(
        status: TaskStatus.success,
        tasks: tasks,
        filteredTasks: _filterTasks(tasks, state.searchQuery),
        hasPendingSync: hasPendingSync,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Failed to load tasks: $e',
      ));
    }
  }

  Future<void> _onAddTask(
      AddTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      // Optimistic update - create temporary task
      final tempTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: event.title,
        completed: false,
        userId: 1,
        isLocal: true,
        createdAt: DateTime.now(),
      );

      final updatedTasks = [tempTask, ...state.tasks];
      emit(state.copyWith(
        tasks: updatedTasks,
        filteredTasks: _filterTasks(updatedTasks, state.searchQuery),
        hasPendingSync: true,
      ));

      // Create actual task (will sync if online)
      final task = await taskRepository.createTask(
        title: event.title,
        completed: false,
      );

      // Replace temporary task with actual task
      final finalTasks = updatedTasks.map((t) =>
      t.id == tempTask.id ? task : t
      ).toList();

      final hasPendingSync = await taskRepository.localStorage.hasPendingSyncTasks();

      emit(state.copyWith(
        tasks: finalTasks,
        filteredTasks: _filterTasks(finalTasks, state.searchQuery),
        hasPendingSync: hasPendingSync,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add task: $e',
      ));
      add(LoadTasks()); // Reload to get correct state
    }
  }

  Future<void> _onUpdateTask(
      UpdateTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      // Optimistic update
      final updatedTasks = state.tasks.map((task) =>
      task.id == event.task.id ? event.task : task
      ).toList();

      emit(state.copyWith(
        tasks: updatedTasks,
        filteredTasks: _filterTasks(updatedTasks, state.searchQuery),
      ));

      // Update in repository
      await taskRepository.updateTask(event.task);

      final hasPendingSync = await taskRepository.localStorage.hasPendingSyncTasks();
      emit(state.copyWith(hasPendingSync: hasPendingSync));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update task: $e',
      ));
      add(LoadTasks());
    }
  }

  Future<void> _onDeleteTask(
      DeleteTask event,
      Emitter<TaskState> emit,
      ) async {
    try {
      // Optimistic delete
      final updatedTasks = state.tasks
          .where((task) => task.id != event.id)
          .toList();

      emit(state.copyWith(
        tasks: updatedTasks,
        filteredTasks: _filterTasks(updatedTasks, state.searchQuery),
      ));

      // Delete from repository
      await taskRepository.deleteTask(event.id);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete task: $e',
      ));
      add(LoadTasks());
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletion event,
      Emitter<TaskState> emit,
      ) async {
    try {
      final updatedTask = event.task.copyWith(completed: event.completed);

      // Optimistic update
      final updatedTasks = state.tasks.map((task) =>
      task.id == updatedTask.id ? updatedTask : task
      ).toList();

      emit(state.copyWith(
        tasks: updatedTasks,
        filteredTasks: _filterTasks(updatedTasks, state.searchQuery),
      ));

      // Update in repository
      await taskRepository.updateTask(updatedTask);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update task: $e',
      ));
    }
  }

  void _onSearchTasks(
      SearchTasks event,
      Emitter<TaskState> emit,
      ) {
    final filteredTasks = _filterTasks(state.tasks, event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTasks: filteredTasks,
    ));
  }

  Future<void> _onSyncTasks(
      SyncTasks event,
      Emitter<TaskState> emit,
      ) async {
    try {
      await taskRepository.syncTasks();
      final hasPendingSync = await taskRepository.localStorage.hasPendingSyncTasks();
      emit(state.copyWith(hasPendingSync: hasPendingSync));
    } catch (e) {
      // Silently fail sync
    }
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks, String query) {
    if (query.isEmpty) return tasks;

    final lowercaseQuery = query.toLowerCase();
    return tasks.where((task) =>
        task.title.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    taskRepository.dispose();
    return super.close();
  }
}

// Private event for connectivity changes
class _ConnectivityChanged extends TaskEvent {
  final bool isOnline;

  const _ConnectivityChanged({required this.isOnline});

  @override
  List<Object> get props => [isOnline];
}
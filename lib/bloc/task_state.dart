import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/task_model.dart';

enum TaskStatus { initial, loading, success, failure, offline }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final List<TaskModel> filteredTasks;
  final String? errorMessage;
  final String searchQuery;
  final bool isOnline;
  final bool hasPendingSync;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.filteredTasks = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.isOnline = true,
    this.hasPendingSync = false,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    List<TaskModel>? filteredTasks,
    String? errorMessage,
    String? searchQuery,
    bool? isOnline,
    bool? hasPendingSync,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isOnline: isOnline ?? this.isOnline,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    filteredTasks,
    errorMessage,
    searchQuery,
    isOnline,
    hasPendingSync,
  ];
}
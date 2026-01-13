import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_manager/core/network/api_client.dart';
import 'package:task_manager/core/network/network_info.dart';
import 'package:task_manager/core/storage/local_storage.dart';
import 'package:task_manager/data/models/task_model.dart';

class TaskRepository {
  final LocalStorage localStorage;
  late final ApiClient _apiClient;
  late final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;

  TaskRepository({required this.localStorage}) {
    _apiClient = ApiClient(client: http.Client());
    _networkInfo = NetworkInfo(connectivity: Connectivity());
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        _syncPendingTasks();
      }
    });
  }

  Future<List<TaskModel>> getTasks() async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Try to get tasks from API
        final tasks = await _apiClient.getTasks();

        // Save to local storage
        await localStorage.saveTasks(tasks);

        // Sync pending tasks in background
        unawaited(_syncPendingTasks());

        return tasks;
      } else {
        // Get tasks from local storage
        return await localStorage.getTasks();
      }
    } catch (e) {
      // Fallback to local storage
      return await localStorage.getTasks();
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required bool completed,
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Create task on API
        final task = await _apiClient.createTask(
          title: title,
          completed: completed,
        );

        // Save to local storage
        await localStorage.saveTask(task);

        return task;
      } else {
        // Create local task
        final localTask = TaskModel(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          completed: completed,
          userId: 1,
          isLocal: true,
          createdAt: DateTime.now(),
        );

        // Save to local storage
        await localStorage.saveTask(localTask);

        // Save to pending sync
        await localStorage.savePendingSyncTask(localTask);

        return localTask;
      }
    } catch (e) {
      // Create local task as fallback
      final localTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        completed: completed,
        userId: 1,
        isLocal: true,
        createdAt: DateTime.now(),
      );

      await localStorage.saveTask(localTask);
      await localStorage.savePendingSyncTask(localTask);

      return localTask;
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Update task on API
        final updatedTask = await _apiClient.updateTask(task);

        // Update in local storage
        await localStorage.saveTask(updatedTask);

        return updatedTask;
      } else {
        // Update local task
        final localTask = task.copyWith(
          isLocal: true,
          updatedAt: DateTime.now(),
        );

        await localStorage.saveTask(localTask);
        await localStorage.savePendingSyncTask(localTask);

        return localTask;
      }
    } catch (e) {
      final localTask = task.copyWith(
        isLocal: true,
        updatedAt: DateTime.now(),
      );

      await localStorage.saveTask(localTask);
      await localStorage.savePendingSyncTask(localTask);

      return localTask;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final isConnected = await _networkInfo.isConnected;

      // Delete from local storage first (optimistic delete)
      await localStorage.deleteTask(id);

      if (isConnected) {
        // Delete from API
        await _apiClient.deleteTask(id);
      }
      // If offline, the task is already removed locally
    } catch (e) {
      // If API call fails, the task is already removed locally
      rethrow;
    }
  }

  Future<void> _syncPendingTasks() async {
    try {
      final pendingTasks = await localStorage.getPendingSyncTasks();

      for (final task in pendingTasks) {
        if (task.isLocal) {
          try {
            // Try to sync with API
            final syncedTask = await _apiClient.createTask(
              title: task.title,
              completed: task.completed,
            );

            // Update local storage with synced task
            await localStorage.deleteTask(task.id);
            await localStorage.saveTask(syncedTask);
            await localStorage.removePendingSyncTask(task.id);
          } catch (e) {
            // Skip this task, will retry later
            continue;
          }
        }
      }
    } catch (e) {
      // Silently fail, will retry on next connection
    }
  }

  Future<void> syncTasks() async {
    await _syncPendingTasks();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
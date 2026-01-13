import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/models/task_model.dart';

class LocalStorage {
  static const String tasksBox = 'tasks';
  static const String appDataBox = 'app_data';
  static const String pendingSyncKey = 'pending_sync_tasks';

  Future<Box<TaskModel>> get tasksBoxInstance async {
    return Hive.box<TaskModel>(tasksBox);
  }

  Future<Box> get appDataBoxInstance async {
    return Hive.box(appDataBox);
  }

  Future<List<TaskModel>> getTasks() async {
    final box = await tasksBoxInstance;
    return box.values.toList();
  }

  Future<void> saveTask(TaskModel task) async {
    final box = await tasksBoxInstance;
    await box.put(task.id, task);
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final box = await tasksBoxInstance;
    final Map<int, TaskModel> tasksMap = {
      for (var task in tasks) task.id: task
    };
    await box.putAll(tasksMap);
  }

  Future<void> deleteTask(int id) async {
    final box = await tasksBoxInstance;
    await box.delete(id);
  }

  Future<void> clearTasks() async {
    final box = await tasksBoxInstance;
    await box.clear();
  }

  Future<List<TaskModel>> getPendingSyncTasks() async {
    final box = await appDataBoxInstance;
    final tasks = box.get(pendingSyncKey, defaultValue: <TaskModel>[]);
    return List<TaskModel>.from(tasks);
  }

  Future<void> savePendingSyncTask(TaskModel task) async {
    final box = await appDataBoxInstance;
    final pendingTasks = await getPendingSyncTasks();
    pendingTasks.add(task);
    await box.put(pendingSyncKey, pendingTasks);
  }

  Future<void> removePendingSyncTask(int taskId) async {
    final box = await appDataBoxInstance;
    final pendingTasks = await getPendingSyncTasks();
    pendingTasks.removeWhere((task) => task.id == taskId);
    await box.put(pendingSyncKey, pendingTasks);
  }

  Future<void> clearPendingSyncTasks() async {
    final box = await appDataBoxInstance;
    await box.delete(pendingSyncKey);
  }

  Future<bool> hasPendingSyncTasks() async {
    final pendingTasks = await getPendingSyncTasks();
    return pendingTasks.isNotEmpty;
  }
}
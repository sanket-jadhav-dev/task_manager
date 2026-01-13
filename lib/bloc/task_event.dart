import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String title;

  const AddTask({required this.title});

  @override
  List<Object> get props => [title];
}

class UpdateTask extends TaskEvent {
  final TaskModel task;

  const UpdateTask({required this.task});

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int id;

  const DeleteTask({required this.id});

  @override
  List<Object> get props => [id];
}

class ToggleTaskCompletion extends TaskEvent {
  final TaskModel task;
  final bool completed;

  const ToggleTaskCompletion({
    required this.task,
    required this.completed,
  });

  @override
  List<Object> get props => [task, completed];
}

class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks({required this.query});

  @override
  List<Object> get props => [query];
}

class SyncTasks extends TaskEvent {}
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final int userId;

  @HiveField(4)
  final bool isLocal;

  @HiveField(5)
  final DateTime? createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.userId,
    this.isLocal = false,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      userId: json['userId'] as int,
      isLocal: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'userId': userId,
      'isLocal': isLocal,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    bool? completed,
    int? userId,
    bool? isLocal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      isLocal: isLocal ?? this.isLocal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    completed,
    userId,
    isLocal,
    createdAt,
    updatedAt,
  ];
}
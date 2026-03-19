import '../../domain/entities/task.dart';

/// Model для маппинга данных из JSONPlaceholder API
class TaskModel {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        completed: json['completed'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
      };

  /// Конвертация Model → Domain Entity
  Task toEntity() => Task(
        id: id,
        remoteId: id.toString(),
        title: title,
        description: 'User #$userId',
        isCompleted: completed,
        isSynced: true,
        createdAt: DateTime.now(),
      );
}

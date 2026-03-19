import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String remoteId;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isSynced;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.remoteId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isSynced,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? remoteId,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isSynced,
    DateTime? createdAt,
  }) =>
      Task(
        id: id ?? this.id,
        remoteId: remoteId ?? this.remoteId,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        isSynced: isSynced ?? this.isSynced,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, remoteId, title, description, isCompleted, isSynced, createdAt];
}

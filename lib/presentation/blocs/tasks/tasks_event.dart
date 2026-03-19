part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить задачи из локальной БД и начать их слушать
class TasksLoadEvent extends TasksEvent {
  const TasksLoadEvent();
}

/// Синхронизировать с API через Dio
class TasksSyncEvent extends TasksEvent {
  const TasksSyncEvent();
}

/// Добавить новую задачу
class TasksAddEvent extends TasksEvent {
  final String title;
  final String description;

  const TasksAddEvent({required this.title, this.description = ''});

  @override
  List<Object?> get props => [title, description];
}

/// Переключить статус выполнения
class TasksToggleEvent extends TasksEvent {
  final int id;

  const TasksToggleEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Удалить задачу
class TasksDeleteEvent extends TasksEvent {
  final int id;

  const TasksDeleteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Фильтр задач
class TasksFilterEvent extends TasksEvent {
  final TaskFilter filter;

  const TasksFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

enum TaskFilter { all, active, completed }

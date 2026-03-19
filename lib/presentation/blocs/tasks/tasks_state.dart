part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksSyncing extends TasksState {
  final List<Task> tasks;
  const TasksSyncing(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TasksLoaded extends TasksState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final TaskFilter filter;

  const TasksLoaded({
    required this.tasks,
    required this.filteredTasks,
    required this.filter,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get activeCount => tasks.where((t) => !t.isCompleted).length;

  TasksLoaded copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    TaskFilter? filter,
  }) =>
      TasksLoaded(
        tasks: tasks ?? this.tasks,
        filteredTasks: filteredTasks ?? this.filteredTasks,
        filter: filter ?? this.filter,
      );

  @override
  List<Object?> get props => [tasks, filteredTasks, filter];
}

class TasksError extends TasksState {
  final String message;
  const TasksError(this.message);

  @override
  List<Object?> get props => [message];
}

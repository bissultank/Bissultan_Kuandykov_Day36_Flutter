import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/usecases/get_tasks_usecase.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasksUseCase getTasks;
  final AddTaskUseCase addTask;
  final ToggleTaskUseCase toggleTask;
  final DeleteTaskUseCase deleteTask;
  final SyncTasksUseCase syncTasks;

  StreamSubscription<List<Task>>? _tasksSubscription;

  TasksBloc({
    required this.getTasks,
    required this.addTask,
    required this.toggleTask,
    required this.deleteTask,
    required this.syncTasks,
  }) : super(const TasksInitial()) {
    on<TasksLoadEvent>(_onLoad);
    on<TasksSyncEvent>(_onSync);
    on<TasksAddEvent>(_onAdd);
    on<TasksToggleEvent>(_onToggle);
    on<TasksDeleteEvent>(_onDelete);
    on<TasksFilterEvent>(_onFilter);
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _onLoad(TasksLoadEvent event, Emitter<TasksState> emit) async {
    emit(const TasksLoading());
    try {
      // Подписываемся на поток из Drift (реактивные обновления)
      await emit.forEach<List<Task>>(
        getTasks.watch(),
        onData: (tasks) => TasksLoaded(
          tasks: tasks,
          filteredTasks: tasks,
          filter: TaskFilter.all,
        ),
        onError: (_, __) => const TasksError('Ошибка загрузки задач'),
      );
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  // ── Sync (Dio) ────────────────────────────────────────────────────────────
  Future<void> _onSync(TasksSyncEvent event, Emitter<TasksState> emit) async {
    final current = state;
    if (current is TasksLoaded) {
      emit(TasksSyncing(current.tasks));
      try {
        await syncTasks();
        // Drift стрим сам обновит состояние после синхронизации
      } catch (e) {
        emit(TasksError('Ошибка синхронизации: ${e.toString()}'));
        await Future.delayed(const Duration(seconds: 2));
        emit(current);
      }
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  Future<void> _onAdd(TasksAddEvent event, Emitter<TasksState> emit) async {
    try {
      await addTask(title: event.title, description: event.description);
    } catch (e) {
      emit(TasksError('Ошибка добавления: ${e.toString()}'));
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> _onToggle(TasksToggleEvent event, Emitter<TasksState> emit) async {
    try {
      await toggleTask(event.id);
    } catch (e) {
      emit(TasksError('Ошибка обновления: ${e.toString()}'));
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> _onDelete(TasksDeleteEvent event, Emitter<TasksState> emit) async {
    try {
      await deleteTask(event.id);
    } catch (e) {
      emit(TasksError('Ошибка удаления: ${e.toString()}'));
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  void _onFilter(TasksFilterEvent event, Emitter<TasksState> emit) {
    final current = state;
    if (current is TasksLoaded) {
      final filtered = switch (event.filter) {
        TaskFilter.all => current.tasks,
        TaskFilter.active => current.tasks.where((t) => !t.isCompleted).toList(),
        TaskFilter.completed => current.tasks.where((t) => t.isCompleted).toList(),
      };
      emit(current.copyWith(filteredTasks: filtered, filter: event.filter));
    }
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}

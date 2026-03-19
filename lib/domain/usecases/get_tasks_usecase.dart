import '../entities/task.dart';
import '../repositories/tasks_repository.dart';

// ── Get Tasks ─────────────────────────────────────────────────────────────────
class GetTasksUseCase {
  final TasksRepository _repository;
  GetTasksUseCase(this._repository);

  Future<List<Task>> call() => _repository.getTasks();

  Stream<List<Task>> watch() => _repository.watchTasks();
}

// ── Add Task ──────────────────────────────────────────────────────────────────
class AddTaskUseCase {
  final TasksRepository _repository;
  AddTaskUseCase(this._repository);

  Future<void> call({required String title, String description = ''}) {
    final task = Task(
      id: 0,
      remoteId: '',
      title: title,
      description: description,
      isCompleted: false,
      isSynced: false,
      createdAt: DateTime.now(),
    );
    return _repository.addTask(task);
  }
}

// ── Toggle Task ───────────────────────────────────────────────────────────────
class ToggleTaskUseCase {
  final TasksRepository _repository;
  ToggleTaskUseCase(this._repository);

  Future<void> call(int id) => _repository.toggleTask(id);
}

// ── Delete Task ───────────────────────────────────────────────────────────────
class DeleteTaskUseCase {
  final TasksRepository _repository;
  DeleteTaskUseCase(this._repository);

  Future<void> call(int id) => _repository.deleteTask(id);
}

// ── Sync Tasks ────────────────────────────────────────────────────────────────
class SyncTasksUseCase {
  final TasksRepository _repository;
  SyncTasksUseCase(this._repository);

  Future<void> call() => _repository.syncWithRemote();
}

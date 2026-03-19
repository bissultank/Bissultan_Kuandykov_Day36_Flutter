import '../entities/task.dart';

abstract class TasksRepository {
  /// Получить все задачи из локальной БД
  Future<List<Task>> getTasks();

  /// Наблюдать за изменениями задач в реальном времени
  Stream<List<Task>> watchTasks();

  /// Добавить новую задачу локально
  Future<void> addTask(Task task);

  /// Переключить статус выполнения
  Future<void> toggleTask(int id);

  /// Удалить задачу
  Future<void> deleteTask(int id);

  /// Синхронизировать с удалённым API (Dio)
  Future<void> syncWithRemote();
}

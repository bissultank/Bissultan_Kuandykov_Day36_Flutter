import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../domain/entities/task.dart';

abstract class TasksLocalDataSource {
  Future<List<Task>> getTasks();
  Stream<List<Task>> watchTasks();
  Future<void> insertTask(Task task);
  Future<void> toggleTask(int id);
  Future<void> deleteTask(int id);
  Future<void> upsertRemoteTasks(List<Task> tasks);
}

class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  final AppDatabase _db;

  TasksLocalDataSourceImpl(this._db);

  @override
  Future<List<Task>> getTasks() async {
    final rows = await _db.getAllTasks();
    return rows.map(_rowToEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _db.watchAllTasks().map(
          (rows) => rows.map(_rowToEntity).toList(),
        );
  }

  @override
  Future<void> insertTask(Task task) async {
    await _db.insertTask(
      TasksTableCompanion.insert(
        title: task.title,
        description: Value(task.description),
        remoteId: Value(task.remoteId),
      ),
    );
  }

  @override
  Future<void> toggleTask(int id) async {
    final tasks = await _db.getAllTasks();
    final task = tasks.firstWhere((t) => t.id == id);
    await _db.updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  @override
  Future<void> deleteTask(int id) async {
    await _db.deleteTask(id);
  }

  @override
  Future<void> upsertRemoteTasks(List<Task> tasks) async {
    final companions = tasks
        .map(
          (t) => TasksTableCompanion(
            remoteId: Value(t.remoteId),
            title: Value(t.title),
            description: Value(t.description),
            isCompleted: Value(t.isCompleted),
            isSynced: const Value(true),
          ),
        )
        .toList();
    await _db.upsertTasks(companions);
  }

  Task _rowToEntity(TasksTableData row) => Task(
        id: row.id,
        remoteId: row.remoteId,
        title: row.title,
        description: row.description,
        isCompleted: row.isCompleted,
        isSynced: row.isSynced,
        createdAt: row.createdAt,
      );
}

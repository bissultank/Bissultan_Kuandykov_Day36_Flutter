import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Table definition ─────────────────────────────────────────────────────────
class TasksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().withDefault(const Constant(''))();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ── Database ──────────────────────────────────────────────────────────────────
@DriftDatabase(tables: [TasksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD operations
  Future<List<TasksTableData>> getAllTasks() => select(tasksTable).get();

  Stream<List<TasksTableData>> watchAllTasks() => select(tasksTable).watch();

  Future<int> insertTask(TasksTableCompanion task) =>
      into(tasksTable).insert(task);

  Future<bool> updateTask(TasksTableData task) =>
      update(tasksTable).replace(task);

  Future<int> deleteTask(int id) =>
      (delete(tasksTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllTasks() => delete(tasksTable).go();

  Future<void> upsertTasks(List<TasksTableCompanion> tasks) async {
    await transaction(() async {
      for (final task in tasks) {
        await into(tasksTable).insertOnConflictUpdate(task);
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tasks.db'));
    return NativeDatabase.createInBackground(file);
  });
}

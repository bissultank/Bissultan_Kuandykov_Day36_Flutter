import '../../domain/entities/task.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../datasources/local/tasks_local_datasource.dart';
import '../datasources/remote/tasks_remote_datasource.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksLocalDataSource localDataSource;
  final TasksRemoteDataSource remoteDataSource;

  TasksRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Task>> getTasks() => localDataSource.getTasks();

  @override
  Stream<List<Task>> watchTasks() => localDataSource.watchTasks();

  @override
  Future<void> addTask(Task task) => localDataSource.insertTask(task);

  @override
  Future<void> toggleTask(int id) => localDataSource.toggleTask(id);

  @override
  Future<void> deleteTask(int id) => localDataSource.deleteTask(id);

  /// Загружает данные с API (Dio) и сохраняет в Drift
  @override
  Future<void> syncWithRemote() async {
    final remoteModels = await remoteDataSource.getTasks();
    final entities = remoteModels.map((m) => m.toEntity()).toList();
    await localDataSource.upsertRemoteTasks(entities);
  }
}

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../network/dio_client.dart';
import '../../data/datasources/local/tasks_local_datasource.dart';
import '../../data/datasources/remote/tasks_remote_datasource.dart';
import '../../data/repositories/tasks_repository_impl.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/toggle_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/sync_tasks_usecase.dart';
import '../../presentation/blocs/tasks/tasks_bloc.dart';
import '../database/app_database.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Database (Drift) ──────────────────────────────────────────────────────
  final db = AppDatabase();
  getIt.registerSingleton<AppDatabase>(db);

  // ── Network (Dio) ─────────────────────────────────────────────────────────
  final dio = DioClient.create();
  getIt.registerSingleton<Dio>(dio);

  // ── DataSources ───────────────────────────────────────────────────────────
  getIt.registerLazySingleton<TasksLocalDataSource>(
    () => TasksLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<TasksRemoteDataSource>(
    () => TasksRemoteDataSourceImpl(getIt<Dio>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<TasksRepository>(
    () => TasksRepositoryImpl(
      localDataSource: getIt<TasksLocalDataSource>(),
      remoteDataSource: getIt<TasksRemoteDataSource>(),
    ),
  );

  // ── UseCases ──────────────────────────────────────────────────────────────
  getIt.registerFactory(() => GetTasksUseCase(getIt<TasksRepository>()));
  getIt.registerFactory(() => AddTaskUseCase(getIt<TasksRepository>()));
  getIt.registerFactory(() => ToggleTaskUseCase(getIt<TasksRepository>()));
  getIt.registerFactory(() => DeleteTaskUseCase(getIt<TasksRepository>()));
  getIt.registerFactory(() => SyncTasksUseCase(getIt<TasksRepository>()));

  // ── BLoC ──────────────────────────────────────────────────────────────────
  getIt.registerFactory<TasksBloc>(
    () => TasksBloc(
      getTasks: getIt<GetTasksUseCase>(),
      addTask: getIt<AddTaskUseCase>(),
      toggleTask: getIt<ToggleTaskUseCase>(),
      deleteTask: getIt<DeleteTaskUseCase>(),
      syncTasks: getIt<SyncTasksUseCase>(),
    ),
  );
}

import 'package:dio/dio.dart';
import '../../models/task_model.dart';

abstract class TasksRemoteDataSource {
  Future<List<TaskModel>> getTasks({int limit = 20});
  Future<TaskModel> createTask(String title);
}

class TasksRemoteDataSourceImpl implements TasksRemoteDataSource {
  final Dio _dio;

  TasksRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TaskModel>> getTasks({int limit = 20}) async {
    final response = await _dio.get(
      '/todos',
      queryParameters: {'_limit': limit},
    );
    final list = response.data as List;
    return list.map((json) => TaskModel.fromJson(json)).toList();
  }

  @override
  Future<TaskModel> createTask(String title) async {
    final response = await _dio.post(
      '/todos',
      data: {
        'title': title,
        'completed': false,
        'userId': 1,
      },
    );
    return TaskModel.fromJson(response.data);
  }
}

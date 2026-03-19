import 'package:dio/dio.dart';

class DioClient {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int _connectTimeout = 10000;
  static const int _receiveTimeout = 10000;

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptors ─────────────────────────────────────────────────────────
    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
      _RetryInterceptor(dio),
    ]);

    return dio;
  }
}

// ── Logging Interceptor ──────────────────────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌── REQUEST ──────────────────────────────────────');
    print('│ ${options.method} ${options.uri}');
    if (options.data != null) print('│ Body: ${options.data}');
    print('└─────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌── RESPONSE ─────────────────────────────────────');
    print('│ ${response.statusCode} ${response.requestOptions.uri}');
    print('└─────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌── ERROR ────────────────────────────────────────');
    print('│ ${err.response?.statusCode} ${err.message}');
    print('└─────────────────────────────────────────────────');
    handler.next(err);
  }
}

// ── Error Interceptor ────────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Timeout подключения',
      DioExceptionType.receiveTimeout => 'Timeout ответа сервера',
      DioExceptionType.badResponse => 'Ошибка сервера: ${err.response?.statusCode}',
      DioExceptionType.connectionError => 'Нет соединения с интернетом',
      _ => 'Неизвестная ошибка: ${err.message}',
    };
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

// ── Retry Interceptor ────────────────────────────────────────────────────────
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  static const int _maxRetries = 2;

  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;

    if (err.type == DioExceptionType.connectionError &&
        retryCount < _maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      print('Retry ${retryCount + 1}/$_maxRetries...');
      await Future.delayed(const Duration(seconds: 1));
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // fall through to next error handler
      }
    }
    handler.next(err);
  }
}

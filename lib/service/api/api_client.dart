import 'package:dio/dio.dart';

/// API 客户端类，用于处理与服务器的通信
class ApiClient {
  /// 基本 URL
  final String baseUrl;
  
  /// 可选的请求头
  final Map<String, String> defaultHeaders;
  
  /// Dio 实例
  late final Dio _dio;

  /// 构造函数
  ApiClient({
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    } {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: this.defaultHeaders,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  /// 更新默认请求头
  void updateDefaultHeaders(Map<String, String> headers) {
    defaultHeaders.addAll(headers);
    _dio.options.headers.addAll(headers);
  }

  /// 移除请求头
  void removeHeader(String key) {
    defaultHeaders.remove(key);
    _dio.options.headers.remove(key);
  }

  /// 执行 GET 请求
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// 执行 POST 请求
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// 执行 PUT 请求
  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// 执行 DELETE 请求
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleDioException(e);
    }
  }

  /// 处理 Dio 异常
  dynamic _handleDioException(DioException e) {
    final response = e.response;
    if (response != null) {
      throw ApiException(
        statusCode: response.statusCode ?? 500,
        message: response.statusMessage ?? 'Unknown error',
        body: response.data,
      );
    } else {
      throw ApiException(
        statusCode: 500,
        message: e.message ?? 'Network error',
        body: null,
      );
    }
  }
}

/// API 异常类
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic body;

  ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  @override
  String toString() => 'ApiException: $statusCode $message';
}

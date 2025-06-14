import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:valet/service/logger_service.dart';

/// API 客户端类，用于处理与服务器的通信
class ApiClient {
  /// 基本 URL
  final String baseUrl;
  
  /// 可选的请求头
  final Map<String, String> defaultHeaders;
  
  /// Dio 实例
  late final Dio _dio;
  
  /// Cookie管理器
  late final CookieJar _cookieJar;

  /// 构造函数
  ApiClient({
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = defaultHeaders ?? {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    } {
    // 初始化Cookie管理器
    _cookieJar = CookieJar();
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: this.defaultHeaders,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    ));
    
    // 添加Cookie管理器拦截器
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    // 添加请求拦截器来确保编码正确
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 确保请求头包含正确的编码信息
        options.headers['Content-Type'] = 'application/json; charset=utf-8';
        options.headers['Accept'] = 'application/json';
        
        // 如果是POST/PUT请求且body是Map，确保Dio使用UTF-8编码
        if ((options.method == 'POST' || options.method == 'PUT') && 
            options.data is Map<String, dynamic>) {
          options.contentType = 'application/json; charset=utf-8';
        }
        
        // 记录请求信息
        logger.trace('API请求: ${options.method} ${options.uri}', tag: 'ApiClient');
        logger.trace('请求头: ${options.headers}', tag: 'ApiClient');
        if (options.data != null) {
          logger.trace('请求体: ${options.data}', tag: 'ApiClient');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        logger.debug('API响应: ${response.statusCode} ${response.statusMessage}', tag: 'ApiClient');
        logger.debug('响应头: ${response.headers}', tag: 'ApiClient');
        if (response.data != null) {
          logger.debug('响应体: ${response.data}', tag: 'ApiClient');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        logger.error('API错误: ${error.message}', tag: 'ApiClient');
        if (error.response != null) {
          logger.error('错误响应: ${error.response?.statusCode} ${error.response?.data}', tag: 'ApiClient');
        }
        handler.next(error);
      },
    ));
  }

  /// 更新默认请求头
  void updateDefaultHeaders(Map<String, String> headers) {
    defaultHeaders.addAll(headers);
    _dio.options.headers.addAll(headers);
  }

  /// 清除所有Cookies（用于登出）
  void clearCookies() {
    _cookieJar.deleteAll();
  }
  
  /// 获取Cookie信息（用于调试）
  Future<List<Cookie>> getCookies(String url) async {
    return await _cookieJar.loadForRequest(Uri.parse(url));
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

import 'dart:convert';
import 'package:http/http.dart' as http;

/// API 客户端类，用于处理与服务器的通信
class ApiClient {
  /// 基本 URL
  final String baseUrl;
  
  /// 可选的请求头
  final Map<String, String> defaultHeaders;

  /// 构造函数
  ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  });

  /// 执行 GET 请求
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: {...defaultHeaders, ...?headers},
    );
    return _handleResponse(response);
  }

  /// 执行 POST 请求
  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {...defaultHeaders, ...?headers},
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  /// 执行 PUT 请求
  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: {...defaultHeaders, ...?headers},
      body: body != null ? json.encode(body) : null,
    );
    return _handleResponse(response);
  }

  /// 执行 DELETE 请求
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(
      url,
      headers: {...defaultHeaders, ...?headers},
    );
    return _handleResponse(response);
  }

  /// 处理 HTTP 响应
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 成功响应
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      // 错误处理
      throw ApiException(
        statusCode: response.statusCode,
        message: response.reasonPhrase ?? 'Unknown error',
        body: response.body.isNotEmpty ? json.decode(response.body) : null,
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

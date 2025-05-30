# API 模块使用说明

本模块提供了一套完整的 API 访问工具，用于简化与 RESTful API 的交互。

## 结构

- `api_client.dart`: 提供基础的 HTTP 请求功能，封装了 GET、POST、PUT、DELETE 等基本方法
- `api_service.dart`: 整合所有 API 服务，提供统一的访问入口

## 快速开始

### 1. 初始化 API 服务

```dart
final apiService = ApiService.create(
  baseUrl: 'https://api.example.com/v1',
);
```

### 2. 错误处理

所有 API 调用都使用 try-catch 来处理可能的错误：

```dart
try {
  final result = await apiService.userApi.login(...);
  // 处理成功的情况
} catch (e) {
  if (e is ApiException) {
    // 处理特定的 API 错误
    print('API 错误: ${e.statusCode} - ${e.message}');
    print('错误详情: ${e.body}');
  } else {
    // 处理其他类型错误
    print('发生错误: $e');
  }
}
```


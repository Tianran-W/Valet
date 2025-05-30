# API 模块使用说明

本模块提供了一套完整的 API 访问工具，用于简化与 RESTful API 的交互。

## 结构

- `api_client.dart`: 提供基础的 HTTP 请求功能，封装了 GET、POST、PUT、DELETE 等基本方法
- `user_api.dart`: 提供用户相关的 API 功能，如登录、注册、获取用户信息等
- `workspace_api.dart`: 提供工作空间相关的 API 功能，如创建、查询、更新工作空间等
- `api_service.dart`: 整合所有 API 服务，提供统一的访问入口
- `api_examples.dart`: 提供使用样例，展示如何在实际应用中使用这些 API

## 快速开始

### 1. 初始化 API 服务

```dart
final apiService = ApiService.create(
  baseUrl: 'https://api.example.com/v1',
);
```

### 2. 用户认证

```dart
// 登录
final loginResponse = await apiService.userApi.login(
  email: 'user@example.com',
  password: 'password123',
);

// 获取并存储令牌
final token = loginResponse['token'] as String;
apiService.updateAuthToken(token);
```

### 3. 获取用户信息

```dart
final currentUser = await apiService.userApi.getCurrentUser();
print('当前用户: $currentUser');
```

### 4. 获取工作空间

```dart
// 获取所有工作空间
final workspaces = await apiService.workspaceApi.getAllWorkspaces();

// 获取特定工作空间
final workspaceId = 'your-workspace-id';
final workspace = await apiService.workspaceApi.getWorkspace(workspaceId);
```

### 5. 操作工作空间

```dart
// 创建工作空间
final newWorkspace = await apiService.workspaceApi.createWorkspace(
  name: '新项目',
  description: '这是一个新项目的工作空间',
  isPrivate: true,
);

// 邀请用户加入工作空间
final invitation = await apiService.workspaceApi.inviteUser(
  workspaceId: workspaceId,
  email: 'colleague@example.com',
  role: 'editor',
);

// 获取工作空间成员
final members = await apiService.workspaceApi.getWorkspaceMembers(workspaceId);
```

### 6. 错误处理

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

## 完整示例

请参考 `api_examples.dart` 文件中的 `ApiExampleWidget` 类，展示了如何在 Flutter 应用中集成和使用这些 API。

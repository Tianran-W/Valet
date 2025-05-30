import '../core/api_client.dart';

/// 工作空间 API 类，处理工作空间相关的 API 请求
class WorkspaceApi {
  final ApiClient _apiClient;

  /// 构造函数
  WorkspaceApi(this._apiClient);

  /// 获取所有工作空间
  Future<List<dynamic>> getAllWorkspaces() async {
    final response = await _apiClient.get('/workspaces');
    return response['workspaces'] as List<dynamic>;
  }

  /// 获取单个工作空间详情
  /// [workspaceId]: 工作空间 ID
  Future<Map<String, dynamic>> getWorkspace(String workspaceId) async {
    return await _apiClient.get('/workspaces/$workspaceId');
  }

  /// 创建新工作空间
  /// [name]: 工作空间名称
  /// [description]: 工作空间描述
  /// [isPrivate]: 是否为私有工作空间
  Future<Map<String, dynamic>> createWorkspace({
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    return await _apiClient.post(
      '/workspaces',
      body: {
        'name': name,
        'description': description,
        'is_private': isPrivate,
      },
    );
  }

  /// 更新工作空间
  /// [workspaceId]: 工作空间 ID
  /// [data]: 要更新的工作空间数据
  Future<Map<String, dynamic>> updateWorkspace(
    String workspaceId,
    Map<String, dynamic> data,
  ) async {
    return await _apiClient.put(
      '/workspaces/$workspaceId',
      body: data,
    );
  }

  /// 删除工作空间
  /// [workspaceId]: 工作空间 ID
  Future<void> deleteWorkspace(String workspaceId) async {
    await _apiClient.delete('/workspaces/$workspaceId');
  }

  /// 邀请用户加入工作空间
  /// [workspaceId]: 工作空间 ID
  /// [email]: 被邀请用户的邮箱
  /// [role]: 用户角色 (admin, editor, viewer)
  Future<Map<String, dynamic>> inviteUser({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    return await _apiClient.post(
      '/workspaces/$workspaceId/invitations',
      body: {
        'email': email,
        'role': role,
      },
    );
  }

  /// 获取工作空间成员
  /// [workspaceId]: 工作空间 ID
  Future<List<dynamic>> getWorkspaceMembers(String workspaceId) async {
    final response = await _apiClient.get('/workspaces/$workspaceId/members');
    return response['members'] as List<dynamic>;
  }

  /// 移除工作空间成员
  /// [workspaceId]: 工作空间 ID
  /// [userId]: 被移除成员的用户 ID
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    await _apiClient.delete('/workspaces/$workspaceId/members/$userId');
  }
}

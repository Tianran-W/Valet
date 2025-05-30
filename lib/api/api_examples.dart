import 'dart:async';
import 'package:flutter/material.dart';
import 'core/api_service.dart';

/// API 使用示例类
class ApiExamples {
  /// 演示如何使用 API 服务
  static void demonstrateApiUsage() async {
    // 创建 API 服务实例
    final apiService = ApiService.create(
      baseUrl: 'https://api.example.com/v1',
    );

    try {
      // 用户登录示例
      final loginResponse = await apiService.userApi.login(
        email: 'user@example.com',
        password: 'password123',
      );

      // 获取并存储令牌
      final token = loginResponse['token'] as String;
      apiService.updateAuthToken(token);
      print('登录成功: $loginResponse');

      // 获取当前用户信息
      final currentUser = await apiService.userApi.getCurrentUser();
      print('当前用户: $currentUser');

      // 获取所有工作空间
      final workspaces = await apiService.workspaceApi.getAllWorkspaces();
      print('工作空间列表: $workspaces');

      if (workspaces.isNotEmpty) {
        // 获取第一个工作空间的详情
        final firstWorkspaceId = workspaces[0]['id'] as String;
        final workspaceDetails = await apiService.workspaceApi.getWorkspace(firstWorkspaceId);
        print('工作空间详情: $workspaceDetails');

        // 获取工作空间成员
        final members = await apiService.workspaceApi.getWorkspaceMembers(firstWorkspaceId);
        print('工作空间成员: $members');
      }

      // 创建新工作空间
      final newWorkspace = await apiService.workspaceApi.createWorkspace(
        name: '新项目',
        description: '这是一个新项目的工作空间',
        isPrivate: true,
      );
      print('创建的新工作空间: $newWorkspace');

      // 邀请用户加入工作空间
      final invitation = await apiService.workspaceApi.inviteUser(
        workspaceId: newWorkspace['id'] as String,
        email: 'colleague@example.com',
        role: 'editor',
      );
      print('邀请发送: $invitation');

      // 更新用户信息
      final userId = currentUser['id'] as String;
      final updatedUser = await apiService.userApi.updateUserInfo(
        userId,
        {'name': '新用户名', 'avatar_url': 'https://example.com/avatar.jpg'},
      );
      print('更新后的用户信息: $updatedUser');

      // 登出
      await apiService.userApi.logout();
      apiService.clearAuthToken();
      print('用户已登出');
    } catch (e) {
      print('错误: $e');
    }
  }
}

/// 实际应用中的 API 使用示例 Widget
class ApiExampleWidget extends StatefulWidget {
  const ApiExampleWidget({super.key});

  @override
  State<ApiExampleWidget> createState() => _ApiExampleWidgetState();
}

class _ApiExampleWidgetState extends State<ApiExampleWidget> {
  final _apiService = ApiService.create(baseUrl: 'https://api.example.com/v1');
  bool _isLoading = false;
  String _result = '';
  List<dynamic> _workspaces = [];
  Map<String, dynamic>? _currentUser;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _result = '正在登录...';
    });

    try {
      final response = await _apiService.userApi.login(
        email: 'user@example.com',
        password: 'password123',
      );
      
      // 存储令牌
      _apiService.updateAuthToken(response['token'] as String);
      
      setState(() {
        _result = '登录成功!';
        _fetchCurrentUser(); // 登录后获取用户信息
      });
    } catch (e) {
      setState(() {
        _result = '登录失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _apiService.userApi.getCurrentUser();
      setState(() {
        _currentUser = user;
        _result = '用户信息获取成功';
      });
    } catch (e) {
      setState(() {
        _result = '获取用户信息失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWorkspaces() async {
    setState(() {
      _isLoading = true;
      _result = '获取工作空间列表...';
    });

    try {
      final workspaces = await _apiService.workspaceApi.getAllWorkspaces();
      setState(() {
        _workspaces = workspaces;
        _result = '获取了 ${workspaces.length} 个工作空间';
      });
    } catch (e) {
      setState(() {
        _result = '获取工作空间失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createWorkspace(String name, String description) async {
    setState(() {
      _isLoading = true;
      _result = '创建工作空间...';
    });

    try {
      final workspace = await _apiService.workspaceApi.createWorkspace(
        name: name,
        description: description,
      );
      setState(() {
        _result = '工作空间创建成功: ${workspace['name']}';
        _fetchWorkspaces(); // 刷新工作空间列表
      });
    } catch (e) {
      setState(() {
        _result = '创建工作空间失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
      _result = '正在登出...';
    });

    try {
      await _apiService.userApi.logout();
      _apiService.clearAuthToken();
      setState(() {
        _result = '已登出';
        _currentUser = null;
        _workspaces = [];
      });
    } catch (e) {
      setState(() {
        _result = '登出失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: const Text('登录'),
            ),
            ElevatedButton(
              onPressed: _currentUser == null || _isLoading ? null : _fetchWorkspaces,
              child: const Text('获取工作空间'),
            ),
            ElevatedButton(
              onPressed: _currentUser == null || _isLoading 
                  ? null 
                  : () => _createWorkspace('新工作空间', '这是一个新的工作空间'),
              child: const Text('创建工作空间'),
            ),
            ElevatedButton(
              onPressed: _currentUser == null || _isLoading ? null : _logout,
              child: const Text('登出'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '结果: $_result',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_currentUser != null) ...[
              const Text('当前用户:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('姓名: ${_currentUser!['name']}'),
              Text('邮箱: ${_currentUser!['email']}'),
              const SizedBox(height: 8),
            ],
            if (_workspaces.isNotEmpty) ...[
              const Text('工作空间:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: _workspaces.length,
                  itemBuilder: (context, index) {
                    final workspace = _workspaces[index];
                    return ListTile(
                      title: Text(workspace['name']),
                      subtitle: Text(workspace['description'] ?? '无描述'),
                      onTap: () {
                        // 可以添加查看工作空间详情的逻辑
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

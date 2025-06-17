import 'package:flutter/material.dart';
import 'package:valet/startup/startup.dart';
import 'package:valet/user/application/auth_service.dart';
import 'package:valet/user/application/hr_service.dart';
import 'package:valet/user/models/hr_user_model.dart';
import 'package:valet/service/api/user_api.dart';

/// 人力资源页面
class HRPage extends StatefulWidget {
  const HRPage({super.key});

  @override
  State<HRPage> createState() => _HRPageState();
}

class _HRPageState extends State<HRPage> {
  late HRService _hrService;
  late AuthService _authService;

  // 数据状态
  List<HRUser> _allUsers = [];
  Map<String, List<HRUser>> _usersByDepartment = {};
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  // 过滤状态
  String _searchQuery = "";
  String? _selectedDepartment;
  String? _selectedRole;
  final TextEditingController _searchController = TextEditingController();

  // 视图状态
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    
    // 初始化HR服务
    final userApi = getIt<UserApi>();
    _hrService = HRService(userApi);
    
    // 加载用户数据
    _loadUsers();
  }

  /// 加载用户数据
  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = "";
    });

    try {
      final users = await _hrService.getAllUsers();
      final groupedUsers = _hrService.groupUsersByDepartment(users);

      setState(() {
        _allUsers = users;
        _usersByDepartment = groupedUsers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('获取用户列表失败: $_errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '重试',
              onPressed: _loadUsers,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  /// 获取过滤后的用户列表
  List<HRUser> get _filteredUsers {
    List<HRUser> filtered = List.from(_allUsers);

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) =>
          user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.displayDepartment.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // 部门过滤
    if (_selectedDepartment != null && _selectedDepartment!.isNotEmpty) {
      filtered = filtered.where((user) => user.displayDepartment == _selectedDepartment).toList();
    }

    // 角色过滤
    if (_selectedRole != null && _selectedRole!.isNotEmpty) {
      filtered = filtered.where((user) => user.roleName == _selectedRole).toList();
    }

    return filtered;
  }

  /// 获取所有部门列表
  List<String> get _departments {
    return _usersByDepartment.keys.toList()..sort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 检查权限 - 只有管理员可以访问
    if (!(_authService.currentUser?.isAdmin ?? false)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '权限不足',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '只有管理员可以访问人力资源模块',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '人力资源管理',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                      tooltip: _isGridView ? '列表视图' : '网格视图',
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                    IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      tooltip: '刷新数据',
                      onPressed: _isLoading ? null : _loadUsers,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 错误信息显示
            if (_hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadUsers,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),

            // 统计卡片
            _buildStatsCards(),
            const SizedBox(height: 24),

            // 搜索和过滤区域
            _buildFilters(),
            const SizedBox(height: 16),

            // 用户列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('加载失败: $_errorMessage'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadUsers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCards() {
    final adminUsers = _hrService.getAdminUsers(_allUsers);
    final normalUsers = _hrService.getNormalUsers(_allUsers);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '总用户数',
            _allUsers.length.toString(),
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '管理员',
            adminUsers.length.toString(),
            Icons.admin_panel_settings,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '普通用户',
            normalUsers.length.toString(),
            Icons.person,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '部门数',
            _departments.length.toString(),
            Icons.business,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  /// 构建单个统计卡片
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建过滤器
  Widget _buildFilters() {
    return Row(
      children: [
        // 搜索框
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: '搜索用户',
              hintText: '用户名、邮箱或部门',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // 部门筛选
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: '部门',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('全部部门'),
              ),
              ..._departments.map((dept) => DropdownMenuItem<String>(
                value: dept,
                child: Text(dept),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        
        // 角色筛选
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: '角色',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<String>(
                value: null,
                child: Text('全部角色'),
              ),
              DropdownMenuItem<String>(
                value: 'admin',
                child: Text('管理员'),
              ),
              DropdownMenuItem<String>(
                value: 'user',
                child: Text('普通用户'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
          ),
        ),
      ],
    );
  }

  /// 构建用户列表
  Widget _buildUserList() {
    final filteredUsers = _filteredUsers;

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无用户数据'),
          ],
        ),
      );
    }

    return _isGridView ? _buildGridView(filteredUsers) : _buildListView(filteredUsers);
  }

  /// 构建列表视图
  Widget _buildListView(List<HRUser> users) {
    return Card(
      elevation: 1,
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserListTile(user);
        },
      ),
    );
  }

  /// 构建网格视图
  Widget _buildGridView(List<HRUser> users) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  /// 构建用户列表项
  Widget _buildUserListTile(HRUser user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.roleColor.withAlpha(51),
        child: Text(
          user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
          style: TextStyle(
            color: user.roleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: user.roleColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.roleDisplayName,
                  style: TextStyle(
                    color: user.roleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.business, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                user.displayDepartment,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleUserAction(value, user),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility),
                SizedBox(width: 8),
                Text('查看详情'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('编辑'),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _showUserDetail(user),
    );
  }

  /// 构建用户卡片
  Widget _buildUserCard(HRUser user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.roleColor.withAlpha(51),
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: user.roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.roleColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    user.roleDisplayName,
                    style: TextStyle(
                      color: user.roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user.displayDepartment,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示用户详情
  void _showUserDetail(HRUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('用户详情 - ${user.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('用户ID', user.userId.toString()),
            _buildDetailRow('用户名', user.username),
            _buildDetailRow('邮箱', user.email),
            _buildDetailRow('部门', user.displayDepartment),
            _buildDetailRow('角色', user.roleDisplayName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 处理用户操作
  void _handleUserAction(String action, HRUser user) {
    switch (action) {
      case 'view':
        _showUserDetail(user);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('编辑功能开发中')),
        );
        break;
    }
  }
}

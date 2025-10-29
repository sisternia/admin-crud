// lib\presentation\screens\home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/navigation.dart';
import '../widgets/card_user.dart';
import '../widgets/floating_button.dart';
import 'add_screen.dart';
import '../../core/constants/api.dart';
import '../../data/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = false;

  bool _isMenuOpen = false;
  IconData _mainIcon = Icons.add;

  bool _isDeleteMode = false;
  bool _isEditMode = false;
  final Set<String> _selectedUserIds = {};

  /// 🔽 Loại lọc hiện tại: 'username' hoặc 'email'
  String _filterType = 'username';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _openMenu() => setState(() => _isMenuOpen = true);

  void _closeMenu({bool resetIcon = true}) {
    setState(() {
      _isMenuOpen = false;
      if (resetIcon) _mainIcon = Icons.add;
    });
  }

  void _selectMenuItem(IconData icon) {
    setState(() => _mainIcon = icon);
    _closeMenu(resetIcon: false);

    if (icon == Icons.add) {
      setState(() {
        _isDeleteMode = false;
        _isEditMode = false;
      });
    } else if (icon == Icons.delete) {
      setState(() {
        _isDeleteMode = true;
        _isEditMode = false;
      });
    } else if (icon == Icons.edit) {
      setState(() {
        _isEditMode = true;
        _isDeleteMode = false;
      });
    }
  }

  void _onMainPressed() {
    if (_isDeleteMode) {
      _deleteSelectedUsers();
    } else if (_mainIcon == Icons.add && !_isMenuOpen) {
      _openAddScreen();
    } else {
      _closeMenu();
    }
  }

  Future<void> _openAddScreen() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddScreen()));
    _fetchUsers();
  }

  Future<void> _deleteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa các user đã chọn?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm != true) return;

    List<UserModel> remainingUsers = List.from(_users);
    for (var user in _users) {
      if (_selectedUserIds.contains(user.email)) {
        final uri = Uri.parse('${ApiConstants.users}/${user.email}');
        await http.delete(uri);
        remainingUsers.remove(user);
      }
    }

    setState(() {
      _users = remainingUsers;
      _filteredUsers = remainingUsers;
      _isDeleteMode = false;
      _selectedUserIds.clear();
      _mainIcon = Icons.add;
    });
  }

  void _toggleSelectUser(String id) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
      } else {
        _selectedUserIds.add(id);
      }
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse(ApiConstants.users);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<UserModel> usersList = [];

        if (data is List) {
          usersList = data.map((e) => UserModel.fromJson(e)).toList();
        } else if (data is Map && data['users'] is List) {
          usersList = (data['users'] as List)
              .map((e) => UserModel.fromJson(e))
              .toList();
        }

        setState(() {
          _users = usersList;
          _filteredUsers = usersList;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải dữ liệu: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _users);
    } else {
      setState(() {
        _filteredUsers = _users.where((user) {
          final email = user.email.toLowerCase();
          final username = user.username.toLowerCase();
          final q = query.toLowerCase();
          if (_filterType == 'email') return email.contains(q);
          return username.contains(q);
        }).toList();
      });
    }
  }

  /// 🔽 Chuyển đổi giữa lọc theo tên & email
  void _toggleFilterType() {
    setState(() {
      _filterType = _filterType == 'username' ? 'email' : 'username';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const TopNavigation(),

          /// 🔽 Thanh tìm kiếm có luôn icon lọc
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _filterType == 'username'
                    ? 'Tìm kiếm theo tên người dùng...'
                    : 'Tìm kiếm theo Email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: _filterType == 'username'
                      ? 'Đang lọc theo Tên'
                      : 'Đang lọc theo Email',
                  onPressed: _toggleFilterType,
                  icon: Icon(
                    _filterType == 'username' ? Icons.person : Icons.email,
                    color: Colors.deepPurple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),

          /// 🔽 Danh sách người dùng
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('Chưa có user nào'))
                    : ReorderableListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final user = _filteredUsers.removeAt(oldIndex);
                            _filteredUsers.insert(newIndex, user);
                          });
                        },
                        children: [
                          for (int index = 0;
                              index < _filteredUsers.length;
                              index++)
                            Container(
                              key: ValueKey(_filteredUsers[index].email),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: UserCard(
                                key: ValueKey(
                                    'card_${_filteredUsers[index].email}'),
                                user: _filteredUsers[index],
                                isDeleteMode: _isDeleteMode,
                                isEditMode: _isEditMode,
                                isSelected: _selectedUserIds
                                    .contains(_filteredUsers[index].email),
                                onSelect: () => _toggleSelectUser(
                                    _filteredUsers[index].email),
                                onUpdated: _fetchUsers,
                                reorderIndex: index, // ✅ thêm dòng này
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingButton(
        isMenuOpen: _isMenuOpen,
        isDeleteMode: _isDeleteMode,
        mainIcon: _mainIcon,
        onLongPress: _openMenu,
        onPressed: _onMainPressed,
        onAdd: () => _selectMenuItem(Icons.add),
        onEdit: () => _selectMenuItem(Icons.edit),
        onDelete: () => _selectMenuItem(Icons.delete),
        onChangeMainIcon: (icon) {
          setState(() => _mainIcon = icon);
        },
      ),
    );
  }
}

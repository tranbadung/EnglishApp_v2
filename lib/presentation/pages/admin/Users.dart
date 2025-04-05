import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:speak_up/data/repositories/firestore/firestore_repository.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<Map<String, dynamic>> users = [];
  final FirestoreRepository firestoreRepository =
  FirestoreRepository(FirebaseFirestore.instance);
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      users = await firestoreRepository.getUsers();
    } catch (e) {
      _showErrorSnackBar('Error loading users: $e');
    }
    setState(() => isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> deleteUser(Map<String, dynamic> user) async {
    try {
      // Try to extract uid first, if not available, use userId
      final userId = user['uid'] ?? user['userId'];

      if (userId == null) {
        _showErrorSnackBar('Cannot find user ID');
        return;
      }

      await firestoreRepository.deleteUser(userId);
      await fetchUsers();
      _showSuccessSnackBar('User deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Error deleting user: $e');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '<1 Tháng Trước';
    final DateTime date =
    DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    return formatter.format(date.toLocal());
  }

  String calculateHoursDifference(
      Timestamp? loginTimestamp, Timestamp? logoutTimestamp) {
    if (loginTimestamp == null || logoutTimestamp == null) {
      return 'Không có dữ liệu';
    }

    final DateTime loginTime = loginTimestamp.toDate();
    final DateTime logoutTime = logoutTimestamp.toDate();
    final Duration difference = logoutTime.difference(loginTime);

    final int hours = difference.inHours;
    final int minutes = difference.inMinutes % 60;

    return '$hours giờ, $minutes phút';
  }

  void showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                user['name']?[0].toUpperCase() ?? '?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('User Details'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailCard(
                  icon: Icons.person,
                  title: 'Tên',
                  value: user['name'] ?? 'Người dùng chưa cập nhật ',
                ),
                _buildDetailCard(
                  icon: Icons.access_time_filled_rounded,
                  title: 'Đăng nhập gần nhất',
                  value: _formatTimestamp(user['lastLoginAt']),
                ),
                _buildDetailCard(
                  icon: Icons.access_time_filled_rounded,
                  title: 'logout',
                  value: _formatTimestamp(user['lastLogoutAt']),
                ),
                _buildDetailCard(
                  icon: Icons.timer,
                  title: 'Số giờ đã học:',
                  value: calculateHoursDifference(
                      user['lastLoginAt'], user['lastLogoutAt']),
                ),
                _buildDetailCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: user['email'] ?? 'Người dùng chưa cập nhật',
                ),
                _buildDetailCard(
                  icon: Icons.phone,
                  title: 'Số điện thoại',
                  value: user['phone'] ?? 'Người dùng chưa cập nhật',
                ),
                _buildDetailCard(
                  icon: Icons.calendar_today,
                  title: 'createdAt',
                  value: _formatTimestamp(user['createdAt']),
                ),
                _buildDetailCard(
                  icon: Icons.hearing,
                  title: 'Listening',
                  value: user['scores']?['listening'] != null
                      ? '${user['scores']['listening']}%'
                      : 'Người dùng chưa làm bài kiểm tra',
                ),
                _buildDetailCard(
                  icon: Icons.menu_book,
                  title: 'Reading',
                  value: user['scores']?['reading'] != null
                      ? '${user['scores']['reading']}%'
                      : 'Người dùng chưa làm bài kiểm tra',
                ),
                _buildDetailCard(
                  icon: Icons.record_voice_over,
                  title: 'Speaking',
                  value: user['scores']?['speaking'] != null
                      ? '${user['scores']['speaking']}%'
                      : 'Người dùng chưa làm bài kiểm tra',
                ),
                _buildDetailCard(
                  icon: Icons.edit,
                  title: 'Writing',
                  value: user['scores']?['writing'] != null
                      ? '${user['scores']['writing']}%'
                      : 'Người dùng chưa làm bài kiểm tra',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Future<void> showEditDialog(Map<String, dynamic> user) async {
    final nameController = TextEditingController(text: user['name'] ?? '');
    final emailController = TextEditingController(text: user['email'] ?? '');
    final phoneController = TextEditingController(text: user['phone'] ?? '');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Phone',
              icon: Icons.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Use userId or uid from the original user map
              final documentId = user['userId'] ?? user['uid'];

              if (documentId == null) {
                _showErrorSnackBar('Cannot find user document ID');
                return;
              }

              final name = nameController.text.isEmpty
                  ? 'Unnamed User'
                  : nameController.text;
              final email = emailController.text.isEmpty
                  ? 'No Email'
                  : emailController.text;
              final phone = phoneController.text.isEmpty
                  ? 'No Phone'
                  : phoneController.text;

              try {
                await firestoreRepository.updateUser(
                  documentId,
                  {
                    'name': name,
                    'email': email,
                    // Only add phone if it's not 'No Phone'
                    if (phone != 'No Phone') 'phone': phone,
                  },
                );
                Navigator.pop(context);
                await fetchUsers();
                _showSuccessSnackBar('User updated successfully');
              } catch (e) {
                print('Error updating user: $e');
                _showErrorSnackBar('Error updating user: $e');
              }
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Future<void> showAddDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Phone',
              icon: Icons.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await firestoreRepository.addUser({
                  'name': nameController.text.isEmpty
                      ? 'Unnamed User'
                      : nameController.text,
                  'email': emailController.text.isEmpty
                      ? 'No Email'
                      : emailController.text,
                  'phone': phoneController.text.isEmpty
                      ? 'No Phone'
                      : phoneController.text,
                  'createdAt': DateTime.now(),
                });
                Navigator.pop(context);
                await fetchUsers();
                _showSuccessSnackBar('User added successfully');
              } catch (e) {
                print('Error adding user: $e');
                _showErrorSnackBar('Error adding user: $e');
              }
            },
            child: Text('Add'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchUsers,
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        )
            : users.isEmpty
            ? Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "No users found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: showAddDialog,
                  icon: Icon(Icons.add),
                  label: Text('Add User'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            : ListView.builder(
          itemCount: users.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            var user = users[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Hero(
                  tag: 'avatar_${user['id']}',
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user['name']?[0].toUpperCase() ?? '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  user['name'] ?? 'Người dùng chưa cập nhật',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(user['email'] ??
                            'Người dùng chưa cập nhật'),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(user['phone'] ??
                            'Người dùng chưa cập nhật'),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.visibility,
                            color: Colors.blue),
                        title: Text('View'),
                        dense: true,
                      ),
                      onTap: () => Future.delayed(
                        Duration(seconds: 0),
                            () => showUserDetails(user),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading:
                        Icon(Icons.edit, color: Colors.orange),
                        title: Text('Edit'),
                        dense: true,
                      ),
                      onTap: () => Future.delayed(
                        Duration(seconds: 0),
                            () => showEditDialog(user),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading:
                        Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        dense: true,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Confirm Delete'),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to delete this user?',
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                deleteUser(
                                    user); // Pass the entire user map
                              },
                              child: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => showUserDetails(user),
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: isLoading ? 0.0 : 1.0,
        duration: Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: showAddDialog,
          icon: Icon(Icons.add),
          label: Text('Add User'),
          tooltip: 'Add User',
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // Add animation controller for list items
  Widget _buildAnimatedListItem(Widget child, int index) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 300),
      child: AnimatedPadding(
        padding: EdgeInsets.only(top: 0),
        duration: Duration(milliseconds: 300),
        child: child,
      ),
    );
  }

  // Add custom loading indicator
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading users...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Add custom theme for the screen
  ThemeData _getCustomTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Add custom animations for dialogs
  Future<T?> _showAnimatedDialog<T>({
    required Widget Function(BuildContext) builder,
  }) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) => builder(context),
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation1.value),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  // Add custom error handling widget
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: fetchUsers,
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

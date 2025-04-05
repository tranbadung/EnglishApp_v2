import 'package:flutter/material.dart';
import 'package:speak_up/domain/entities/category/category.dart';
import 'package:speak_up/presentation/pages/admin/Users.dart';

import 'Conversation.dart';
import 'category_management_screen.dart';
import 'expression_management_screen.dart';
import 'word_management_screen.dart';
import 'phonetic_management_screen.dart';

class ManagementScreen extends StatelessWidget {
  final List<TabItem> tabs = [
    TabItem(
      title: 'Từ vựng',
      icon: Icons.book,
      screen: WordManagementScreen(),
    ),
    TabItem(
      title: 'Phát âm',
      icon: Icons.record_voice_over,
      screen: PhoneticManagementScreen(),
    ),
    TabItem(
      title: 'Ngữ cảnh',
      icon: Icons.account_tree_sharp,
      screen: ExpressionManagementScreen(),
    ),
    TabItem(
      title: 'Users',
      icon: Icons.people,
      screen: UsersListScreen(),
    ),
    TabItem(
      title: 'Category',
      icon: Icons.category,
      screen: CategoryManagementScreen(),
    ),
    TabItem(
      title: 'Conversation',
      icon: Icons.connect_without_contact_rounded,
      screen: CategoryListWidget(initialCategories: categories),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quản lý dữ liệu'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              isScrollable: true, // Enable horizontal scrolling
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: tabs.map((tab) => _buildTab(tab)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: tabs.map((tab) => tab.screen).toList(),
        ),
      ),
    );
  }

  Widget _buildTab(TabItem tab) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon),
            SizedBox(width: 8),
            Text(
              tab.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabItem {
  final String title;
  final IconData icon;
  final Widget screen;

  TabItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

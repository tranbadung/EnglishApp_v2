import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/presentation/pages/chat/chat_view.dart';
import 'package:speak_up/presentation/pages/home/home_view.dart';
import 'package:speak_up/presentation/pages/lesson/lessonview.dart';
import 'package:speak_up/presentation/pages/pattern_lesson_detail/patern_lessson_view.dart';
import 'package:speak_up/presentation/pages/profile/profile_screen.dart';
import 'package:speak_up/presentation/pages/profile/profile_view.dart';
import 'package:speak_up/presentation/pages/quiz/quiz_view_start.dart';
import 'main_menu_state.dart';
import 'main_menu_view_model.dart';

final mainMenuViewModelProvider =
    StateNotifierProvider.autoDispose<MainMenuViewModel, MainMenuState>(
  (ref) => MainMenuViewModel(),
);

class MainMenuView extends ConsumerWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainMenuViewModelProvider);

    List<Widget> _pageOptions = [
      const HomeView(),
      const QuizScreenPath(),
      const QuizStartScreen(),
      LessonView1(),
      ProgressTrackingScreen(),
      UsersListScreen(),
    ];

    return Scaffold(
      appBar: kIsWeb ? _buildWebAppBar(context, ref) : null,
      body: _pageOptions[state.currentTabIndex],
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
              currentIndex: state.currentTabIndex,
              onTap: (index) =>
                  ref.read(mainMenuViewModelProvider.notifier).changeTab(index),
              items: [
                _buildBottomNavItem(
                    Icons.home, 'Khóa học của tôi', state.currentTabIndex == 0),
                _buildBottomNavItem(Icons.record_voice_over, 'Chương trình học',
                    state.currentTabIndex == 1),
                _buildBottomNavItem(
                    Icons.quiz, 'Đề thi online', state.currentTabIndex == 2),
                _buildBottomNavItem(Icons.play_lesson, 'Flashcards',
                    state.currentTabIndex == 3),
                _buildBottomNavItem(Icons.person, 'Kích hoạt tài khoản',
                    state.currentTabIndex == 4),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                height: kIsWeb
                    ? MediaQuery.of(context).size.height * 1
                    : MediaQuery.of(context).size.height * 0.5,
                width: kIsWeb
                    ? MediaQuery.of(context).size.width *
                        20 // 75% width for web
                    : MediaQuery.of(context)
                        .size
                        .width, // Full width for mobile
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ChatView(),
              );
            },
          );
        },
        child: Image.asset('assets/images/chatbot.png'),
      ),
    );
  }

  AppBar _buildWebAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            'English_App',
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            _buildNavItem(context, ref, Icons.home, 'Khóa học của tôi', 0),
            _buildNavItem(
                context, ref, Icons.record_voice_over, 'Chương trình học', 1),
            _buildNavItem(context, ref, Icons.quiz, 'Đề thi online', 3),
            _buildNavItem(context, ref, Icons.play_lesson, 'Flashcards', 2),
            _buildNavItem(context, ref, Icons.person, 'tài khoản', 4),
            _buildNavItem(context, ref, Icons.person, 'Quản lý người dùng', 5),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: isSelected
            ? Colors.blue
            : Colors.grey, // Màu xanh cho mục được chọn
      ),
      label: label,
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, IconData icon,
      String label, int index) {
    final isSelected =
        ref.watch(mainMenuViewModelProvider).currentTabIndex == index;

    return InkWell(
      onTap: () {
        ref.read(mainMenuViewModelProvider.notifier).changeTab(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!kIsWeb)
              Icon(
                icon,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 24,
              ),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

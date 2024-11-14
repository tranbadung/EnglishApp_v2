import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/presentation/pages/admin/ExpressionType.dart';
import 'package:speak_up/presentation/pages/admin/Idiom_screen.dart';
import 'package:speak_up/presentation/pages/admin/PatternListScreen%20.dart';
import 'package:speak_up/presentation/pages/admin/Phonetic.dart';
import 'package:speak_up/presentation/pages/admin/TenseUsageListScreen.dart';
import 'package:speak_up/presentation/pages/admin/lesson_screen.dart';
import 'package:speak_up/presentation/pages/admin/word_screen.dart';
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
    final viewModel = ref.read(mainMenuViewModelProvider.notifier);

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      viewModel.fetchUserRole(currentUser.uid);
    }
    List<Widget> _pageOptions = [
      const HomeView(),
      const QuizScreenPath(),
      const QuizStartScreen(),
      LessonView1(),
      ProgressTrackingScreen(),
      UsersListScreen(),
      IdiomListScreen(),
      WordListScreen(),
      LessonListScreen(),
      PatternListScreen(),
      ExpressionTypeListScreen(),
      PhoneticListScreen(),
      TenseUsageListScreen(),
    ];

    final List<BottomNavigationBarItem> bottomNavItems = state.userRole ==
            'admin'
        ? [
            _buildBottomNavItem(Icons.maps_home_work, 'Khóa học của tôi',
                state.currentTabIndex == 0),
            _buildBottomNavItem(Icons.analytics_sharp, 'Chương trình học',
                state.currentTabIndex == 1),
            _buildBottomNavItem(
                Icons.quiz, 'Đề thi online', state.currentTabIndex == 2),
            _buildBottomNavItem(
                Icons.play_lesson, 'Flashcards', state.currentTabIndex == 3),
            _buildBottomNavItem(Icons.access_time_filled_rounded,
                'Kích hoạt tài khoản', state.currentTabIndex == 4),
          ]
        : [
            _buildBottomNavItem(Icons.maps_home_work, 'Khóa học của tôi',
                state.currentTabIndex == 0),
            _buildBottomNavItem(Icons.analytics_sharp, 'Chương trình học',
                state.currentTabIndex == 1),
            _buildBottomNavItem(
                Icons.quiz, 'Đề thi online', state.currentTabIndex == 2),
            _buildBottomNavItem(
                Icons.play_lesson, 'Flashcards', state.currentTabIndex == 3),
            _buildBottomNavItem(Icons.access_time_filled_rounded,
                'Kích hoạt tài khoản', state.currentTabIndex == 4),
          ];

    return Scaffold(
      appBar: kIsWeb ? _buildWebAppBar(context, ref) : null,
      body: _pageOptions[state.currentTabIndex],
      bottomNavigationBar: kIsWeb
          ? null // Ẩn bottom nav trên web
          : BottomNavigationBar(
              currentIndex: state.currentTabIndex,
              onTap: (index) => viewModel.changeTab(index),
              items: bottomNavItems,
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
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
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

  BottomNavigationBarItem _buildBottomNavItem(
      IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      label: label,
    );
  }

  AppBar _buildWebAppBar(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainMenuViewModelProvider);

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
          children: state.userRole == 'admin'
              ? [
                  _buildNavItem(context, ref, 'Manage Users', 5),
                  _buildNavItem(context, ref, 'Manage Idiom', 6),
                  _buildNavItem(context, ref, 'Manage Word', 7),
                  _buildNavItem(context, ref, 'Manage Lesson', 8),
                  _buildNavItem(context, ref, 'Manage Pattern', 9),
                  _buildNavItem(context, ref, 'Manage Expression', 10),
                  _buildNavItem(context, ref, 'Manage Phonetic', 11),
                  _buildNavItem(context, ref, 'Manage TenseUsage', 12),
                ]
              : [
                  _buildNavItem(context, ref, 'Khóa học của tôi', 0),
                  _buildNavItem(context, ref, 'Chương trình học', 1),
                  _buildNavItem(context, ref, 'Đề thi online', 3),
                  _buildNavItem(context, ref, 'Flashcards', 2),
                  _buildNavItem(context, ref, 'Tài khoản', 4),
                ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNavItem(
      BuildContext context, WidgetRef ref, String label, int index) {
    final isSelected =
        ref.watch(mainMenuViewModelProvider).currentTabIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          ref.read(mainMenuViewModelProvider.notifier).changeTab(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon(
              //   icon,
              //   color:
              //       isSelected ? Theme.of(context).primaryColor : Colors.grey,
              //   size: 20,
              // ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

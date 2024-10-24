import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/domain/entities/flash_card/flash_card.dart';
import 'package:speak_up/domain/entities/lesson/lesson.dart';
import 'package:speak_up/domain/entities/quiz/quiz.dart';
import 'package:speak_up/presentation/pages/chat/chat_view.dart';
import 'package:speak_up/presentation/pages/home/home_view.dart';
import 'package:speak_up/presentation/pages/ipa/ipa_view.dart';
import 'package:speak_up/presentation/pages/lesson/lessonview.dart';
import 'package:speak_up/presentation/pages/lessons/lessons_view.dart';
import 'package:speak_up/presentation/pages/pattern_lesson_detail/patern_lessson_view.dart';
import 'package:speak_up/presentation/pages/profile/profile_view.dart';
import 'package:speak_up/presentation/pages/quiz/quiz_view.dart';
import 'package:speak_up/presentation/pages/quiz/quiz_view_start.dart';
import 'main_menu_state.dart';
import 'main_menu_view_model.dart';

final mainMenuViewModelProvider =
    StateNotifierProvider.autoDispose<MainMenuViewModel, MainMenuState>(
  (ref) => MainMenuViewModel(),
);
List<Widget> _pageOptions = List.generate(5, (index) {
  switch (index) {
    case 0:
      return const HomeView();
    case 1:
      return const QuizScreenPath();
    case 2:
       return const QuizStartScreen();
    case 3:
      return LessonView1();
    case 4:
      return ProgressTrackingScreen();
    default:
      return const HomeView();
  }
});

class MainMenuView extends ConsumerWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainMenuViewModelProvider);

    try {
      return Scaffold(
        body: _pageOptions[state.currentTabIndex], // Kiểm tra giá trị này
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: state.currentTabIndex,
          onTap: (index) {
            ref.read(mainMenuViewModelProvider.notifier).changeTab(index);
          },
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: ScreenUtil().setHeight(24),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.record_voice_over,
                size: ScreenUtil().setHeight(24),
              ),
              label: 'Phonetic',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.quiz,
                size: ScreenUtil().setHeight(24),
              ),
              label: 'Quiz',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
                size: ScreenUtil().setHeight(24),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: ScreenUtil().setHeight(24),
              ),
              label: 'Profile',
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e'); // In lỗi ra console
      return Center(child: Text('An error occurred: $e'));
    }
  }
}

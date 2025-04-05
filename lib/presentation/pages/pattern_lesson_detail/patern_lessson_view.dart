import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/domain/entities/lesson/lesson.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:speak_up/domain/use_cases/youtube/get_youtube_playlist_by_id_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/chat/chat_view.dart';
import 'package:speak_up/presentation/pages/home/home_state.dart';
import 'dart:math';
import 'package:speak_up/presentation/pages/home/home_view_model.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import '../../../domain/use_cases/firestore/get_flash_card_list_use_case.dart';
import '../../../domain/use_cases/firestore/get_youtube_playlist_id_list_use_case.dart';
import '../../../domain/use_cases/local_database/get_category_list_use_case.dart';
import '../../../domain/use_cases/local_database/get_lesson_list_use_case.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) => HomeViewModel(
          injector.get<GetLessonListUseCase>(),
          injector.get<GetCategoryListUseCase>(),
          injector.get<GetFlashCardListUseCase>(),
          injector.get<GetYoutubePLayListIdListUseCase>(),
          injector.get<GetYoutubePlaylistByIdUseCase>(),
        ));

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade200.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3;
    const dashSpace = 5;

    double startY = 88;
    double endY = size.height / 1.3;

    for (double y = startY; y < endY; y += dashWidth + dashSpace) {
      canvas.drawLine(Offset(size.width / 2, y),
          Offset(size.width / 2, min(y + dashWidth, endY)), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class QuizScreenPath extends ConsumerStatefulWidget {
  const QuizScreenPath({super.key});

  @override
  ConsumerState<QuizScreenPath> createState() => _QuizScreenPathState();
}

class _QuizScreenPathState extends ConsumerState<QuizScreenPath> {
  double calcPosition(double y) {
    return 12 * sin(y / 1);
  }

  HomeViewModel get _viewModel => ref.read(homeViewModelProvider.notifier);
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  Future<void> _loadLessonsAndStates() async {
    await _viewModel.getLessonList();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_viewModel.lessons == null || _viewModel.lessons.isEmpty) {
      return;
    }

    for (var lesson in _viewModel.lessons) {
      lesson.isLearned =
          prefs.getBool('lesson_${lesson.lessonID}_isLearned') ?? false;
      print('Trạng thái của bài học ${lesson.lessonID}: ${lesson.isLearned}');
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _loadLessonsAndStates();
      _setupBannerTimer();
    });
  }

  void _setupBannerTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (!mounted) return;
        if (_currentBannerPage < 2) {
          _currentBannerPage++;
        } else {
          _currentBannerPage = 0;
        }
        if (_bannerController.hasClients) {
          _bannerController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  Future<void> _loadLessonStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var lesson in _viewModel.lessons) {
        lesson.isLearned =
            prefs.getBool('lesson_${lesson.lessonID}_isLearned') ?? false;
      }
    });
  }

  Future<void> _saveLessonState(Lesson lesson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'lesson_${lesson.lessonID}_isLearned', lesson.isLearned);
    print('Saved lesson ${lesson.lessonID} state: ${lesson.isLearned}');
  }

  void _navigateToLesson(Lesson lesson) async {
    setState(() {
      lesson.isLearned = true;
    });
    await _saveLessonState(lesson);

    if (!mounted) return;

    ref.read(appNavigatorProvider).navigateTo(
          AppRoutes.lesson,
          arguments: lesson,
        );
  }

  void completeLesson(Lesson lesson) async {
    lesson.isLearned = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lesson_${lesson.lessonID}_isLearned', true);

    await _loadLessonStates();

    setState(() {});
    print('Lưu trạng thái cho bài học ${lesson.lessonID}: ${lesson.isLearned}');
  }

  Widget buildLessonModal(Lesson lesson) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lesson.translation,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              lesson.imageURL,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveLessonState(lesson);
              _navigateToLesson(lesson);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade200,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadLessons() async {
    await _viewModel.getLessonList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var lesson in _viewModel.lessons) {
      lesson.isLearned =
          prefs.getBool('lesson_${lesson.lessonID}_isLearned') ?? false;
    }
    setState(() {});
  }

  Widget buildNode(int index, Lesson lesson) {
    // Kiểm tra xem ứng dụng đang chạy trên web hay không
    final isWeb = kIsWeb;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            return buildLessonModal(lesson);
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: isWeb ? 120 : 100, // Kích thước cho web lớn hơn một chút
        height: isWeb ? 80 : 60, // Tương tự cho chiều cao
        margin: EdgeInsets.only(
          top: isWeb ? 30 : 20, // Khoảng cách trên lớn hơn trên web
          left: (24 * calcPosition(index.toDouble()) <= 0)
              ? (24 * calcPosition(index.toDouble())).abs()
              : 0,
          right: (24 * calcPosition(index.toDouble()) >= 0)
              ? 24 * calcPosition(index.toDouble())
              : 0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade100,
              blurRadius: 19,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            lesson.isLearned
                ? 'assets/images/Screenshot_2024-10-24_153614-removebg-preview.png'
                : 'assets/images/Screenshot_2024-10-17_161446-removebg-preview.png',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final lessons = state.lessons;

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          'Lộ trình học',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.purple.shade100,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: const Text(
              'Unit 1: Lộ Trình học tiếng anh.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  bottom: 100,
                  child: SizedBox(
                    width: 200,
                    height: 199,
                    child: Image.asset(
                      'assets/images/Screenshot_2024-10-17_174845-removebg-preview.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 80,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/images/Screenshot_2024-10-17_174617-removebg-preview.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height),
                        painter: DottedLinePainter(),
                      ),
                      if (state.lessonsLoadingStatus == LoadingStatus.success)
                        ListView.builder(
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            return buildNode(index, lessons[index]);
                          },
                        )
                      else if (state.lessonsLoadingStatus ==
                          LoadingStatus.error) // Khi có lỗi tải dữ liệu
                        ListView.builder(
                          itemCount: 6, // Hiển thị 6 phần tử mẫu
                          itemBuilder: (context, index) {
                            // Tạo một bài học mẫu để hiển thị
                            Lesson sampleLesson = Lesson(
                              lessonID: 1, // ID giả
                              name: 'Phần tử mẫu ${index + 1}', // Tiêu đề giả
                              description:
                                  'Mô tả của phần tử mẫu ${index + 1}', // Mô tả giả
                              isLearned: false,
                              translation: '',
                              descriptionTranslation: '',
                              imageURL:
                                  'assets/images/banner4.png', // Có thể đặt trạng thái học
                            );
                            return buildNode(index,
                                sampleLesson); // Sử dụng hàm buildNode của bạn
                          },
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}

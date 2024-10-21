import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/data/providers/app_language_provider.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/data/providers/app_theme_provider.dart';
import 'package:speak_up/domain/entities/lesson/lesson.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:speak_up/domain/use_cases/firestore/get_flash_card_list_use_case.dart';
import 'package:speak_up/domain/use_cases/firestore/get_youtube_playlist_id_list_use_case.dart';
import 'package:speak_up/domain/use_cases/local_database/get_category_list_use_case.dart';
import 'package:speak_up/domain/use_cases/youtube/get_youtube_playlist_by_id_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/home/home_state.dart';
import 'package:speak_up/presentation/pages/home/home_view_model.dart';
import 'package:speak_up/presentation/pages/ipa/ipa_view.dart';
import 'package:speak_up/presentation/pages/lesson/test_view.dart';
import 'package:speak_up/presentation/utilities/enums/language.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';

import '../../../domain/use_cases/local_database/get_lesson_list_use_case.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeState>((ref) => HomeViewModel(
          injector.get<GetLessonListUseCase>(),
          injector.get<GetCategoryListUseCase>(),
          injector.get<GetFlashCardListUseCase>(),
          injector.get<GetYoutubePLayListIdListUseCase>(),
          injector.get<GetYoutubePlaylistByIdUseCase>(),
        ));

class LessonView1 extends ConsumerStatefulWidget {
  const LessonView1({super.key});

  @override
  ConsumerState<LessonView1> createState() => _LessonView1State();
}

class _LessonView1State extends ConsumerState<LessonView1> {
  HomeViewModel get _viewModel => ref.read(homeViewModelProvider.notifier);
  Future<void> _init() async {
    if (!mounted) return; // Kiểm tra widget đã được gắn vào cây hay chưa

    await _viewModel.getCategoryList();
    if (!mounted) return; // Kiểm tra lại sau mỗi hành động không đồng bộ
    await _viewModel.getLessonList();
    if (!mounted) return;
    await _viewModel.getFlashCardList();
    if (!mounted) return;
    await _viewModel.getYoutubeVideoLists();
    if (!mounted) return;
    await _viewModel.getYoutubeVideoLists();
  }

  String getBestThumbnailUrl(YoutubeVideoThumbnails? thumbnails) {
    return thumbnails?.maxresThumbnail?.url ??
        thumbnails?.standardThumbnail?.url ??
        thumbnails?.highThumbnail?.url ??
        thumbnails?.mediumThumbnail?.url ??
        thumbnails?.defaultThumbnail?.url ??
        '';
  }

  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;

  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _init();
      // Sử dụng addPostFrameCallback để đảm bảo widget đã được xây dựng
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bannerTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
          if (!mounted) return; // Kiểm tra nếu widget đã bị dispose

          if (_currentBannerPage < 2) {
            _currentBannerPage++;
          } else {
            _currentBannerPage = 0;
          }

          // Chỉ thực hiện animate khi widget còn tồn tại
          if (_bannerController.hasClients) {
            _bannerController.animateToPage(
              _currentBannerPage,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel(); // Hủy Timer khi widget bị dispose
    _bannerController.dispose(); // Hủy bỏ controller để tránh lỗi
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.red),
                SizedBox(width: 5),
                Text('1', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Khóa học'),
                Tab(text: 'Speak'),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  buildCoursesSection(state),
                  // buildExplore(state),
                  IpaView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExplore(HomeState state) {
    print('Lessons: ${state.lessons}'); // Kiểm tra số lượng bài học

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                "ELSA AI Conversations",
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     ref
            //         .read(appNavigatorProvider)
            //         .navigateTo(AppRoutes.lessons, arguments: state.lessons);
            //   },
            //   child: Text(
            //     AppLocalizations.of(context)!.viewAll,
            //     style: TextStyle(
            //       color: Theme.of(context).colorScheme.secondary,
            //       fontSize: ScreenUtil().setSp(14),
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(
          height: ScreenUtil().setHeight(8),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: ScreenUtil().screenHeight * 0.4,
          ),
          child: state.lessonsLoadingStatus == LoadingStatus.success
              ? PageView.builder(
                  itemCount: state.lessons.length,
                  controller: PageController(
                      viewportFraction: 0.9), // Điều chỉnh viewportFraction
                  itemBuilder: (context, index) =>
                      buildExploreItem(state.lessons[index]),
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget buildExploreItem(Lesson lesson) {
    print('Lessons: ${lesson.description}'); // Kiểm tra số lượng bài học

    final isDarkTheme = ref.watch(themeProvider);
    final language = ref.watch(appLanguageProvider);

    return GestureDetector(
      onTap: () {
        ref
            .read(appNavigatorProvider)
            .navigateTo(AppRoutes.lesson, arguments: lesson);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8), // Khoảng cách
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDarkTheme
                ? [Colors.grey[850]!, Colors.black]
                : [Colors.white, Colors.blueAccent.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: Image.asset(
                  lesson.imageURL,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDarkTheme ? Colors.black54 : Colors.white54,
                  ),
                  child: Text(
                    language == Language.english
                        ? lesson.name
                        : lesson.translation,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCoursesSection(HomeState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Khóa học phổ biến',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Kiểm tra trạng thái loading
          state.lessonsLoadingStatus == LoadingStatus.success
              ? SizedBox(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = state.lessons[index];
                      return buildCourseCard(lesson);
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator()),

          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Kiểm Tra',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 500, child: buildLevelFilterSection()),
        ],
      ),
    );
  }

// Cập nhật hàm buildCourseCard
  Widget buildCourseCard(Lesson lesson) {
    final isDarkTheme = ref.watch(themeProvider);
    final language = ref.watch(appLanguageProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          ref
              .read(appNavigatorProvider)
              .navigateTo(AppRoutes.lesson, arguments: lesson);
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Image.asset(lesson.imageURL,
                        fit: BoxFit.cover, width: double.infinity, height: 100),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.bookmark_border, color: Colors.white),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      lesson.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      lesson.translation,
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lesson.description,
                      style: TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLevelFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select an IELTS skill to test:',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(20)),
          Expanded(
            child: ListView(
              children: [
                buildSkillCard(
                    context,
                    'Listening',
                    'Test your listening skills',
                    Icons.headphones,
                    Colors.blue),
                buildSkillCard(context, 'Reading', 'Test your reading skills',
                    Icons.book, Colors.green),
                buildSkillCard(context, 'Writing', 'Test your writing skills',
                    Icons.edit, Colors.orange),
                buildSkillCard(context, 'Speaking', 'Test your speaking skills',
                    Icons.mic, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSkillCard(BuildContext context, String skillName,
      String description, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          skillName,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(18)),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Điều hướng tới trang kiểm tra của kỹ năng
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SkillDetailPage(skillName: skillName)),
          );
        },
      ),
    );
  }
}

Widget buildLevelChip(String label, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {},
      selectedColor: Colors.black,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    ),
  );
}

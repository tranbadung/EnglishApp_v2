import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/data/providers/app_language_provider.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/data/providers/app_theme_provider.dart';
import 'package:speak_up/domain/entities/category/category.dart';
import 'package:speak_up/domain/entities/lesson/lesson.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:speak_up/domain/use_cases/firestore/get_flash_card_list_use_case.dart';
import 'package:speak_up/domain/use_cases/firestore/get_youtube_playlist_id_list_use_case.dart';
import 'package:speak_up/domain/use_cases/local_database/get_category_list_use_case.dart';
import 'package:speak_up/domain/use_cases/local_database/get_lesson_list_use_case.dart';
import 'package:speak_up/domain/use_cases/youtube/get_youtube_playlist_by_id_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/home/home_state.dart';
import 'package:speak_up/presentation/pages/home/home_view_model.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/constant/category_icon_list.dart';
import 'package:speak_up/presentation/utilities/enums/language.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';

final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeState>(
        (ref) => HomeViewModel(
              injector.get<GetLessonListUseCase>(),
              injector.get<GetCategoryListUseCase>(),
              injector.get<GetFlashCardListUseCase>(),
              injector.get<GetYoutubePLayListIdListUseCase>(),
              injector.get<GetYoutubePlaylistByIdUseCase>(),
            ));

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  HomeViewModel get _viewModel => ref.read(homeViewModelProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _init();
      Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (_currentBannerPage < 2) {
          _currentBannerPage++;
        } else {
          _currentBannerPage = 0;
        }
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  Future<void> _init() async {
    await _viewModel.getCategoryList();
    await _viewModel.getLessonList();
    await _viewModel.getFlashCardList();
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

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildAppBar(),
            buildBanner(),
            // buildCategories(state),
            // buildExplore(state),
            buildConversations(state),
            // buildFlashCards(state),
            buildReels(state),
            buildSkillsEvaluationTable(),
          ],
        ),
      ),
    );
  }

  Widget buildSkillsEvaluationTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Skills Evaluation",
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(12)),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            border: TableBorder.all(color: Colors.grey, width: 0.5),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Skill",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Score",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Progress",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              buildSkillTableRow("Listening", 75),
              buildSkillTableRow("Speaking", 85),
              buildSkillTableRow("Reading", 65),
              buildSkillTableRow("Writing", 90),
            ],
          ),
        ],
      ),
    );
  }

  TableRow buildSkillTableRow(String skillName, int score) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(skillName),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("$score/100"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildFlashCards(HomeState state) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              AppLocalizations.of(context)!.review,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(appNavigatorProvider).navigateTo(
                    AppRoutes.flashCards,
                    arguments: state.flashCards,
                  );
            },
            child: Text(
              AppLocalizations.of(context)!.practiceNow,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: ScreenUtil().setSp(14),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: ScreenUtil().screenHeight * 0.25,
        child: PageView.builder(
            itemCount: state.flashCards.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final flashCard = state.flashCards[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).primaryColor,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text(flashCard.frontText,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil().setSp(20))),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text(flashCard.backText,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontSize: ScreenUtil().setSp(14))),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    ]);
  }

  Widget buildConversations(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ELSA AI Conversations',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Có 1 Cuộc Đàm Thoại',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ref.read(appNavigatorProvider).navigateTo(
                      AppRoutes.categories,
                      arguments: state.categories);
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: ScreenUtil().setSp(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        state.categoriesLoadingStatus == LoadingStatus.success
            ? SizedBox(
                height: ScreenUtil().screenHeight *
                    0.4, // Điều chỉnh chiều cao tương đối
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    return buildConversationItem(
                        state.categories[index], index);
                  },
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget buildConversationItem(Category category, int index) {
    final isDarkTheme = ref.watch(themeProvider);
    final language = ref.watch(appLanguageProvider);

    return GestureDetector(
      onTap: () {
        ref
            .read(appNavigatorProvider)
            .navigateTo(AppRoutes.category, arguments: category);
      },
      child: Container(
        width:
            ScreenUtil().screenWidth * 0.7, // Điều chỉnh chiều rộng tương đối
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      category.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Image.asset(
                            conversationImages[
                                index % conversationImages.length],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EASY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == Language.english
                        ? category.name
                        : category.translation,
                    style: TextStyle(
                      color: isDarkTheme ? Colors.white : Colors.black87,
                      fontSize: ScreenUtil().setSp(20),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3-5 Minutes',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                      fontSize: ScreenUtil().setSp(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// You might need to define these somewhere in your code
  final List<String> conversationImages = [
    'assets/images/fitness.jpg',
    'assets/images/cooking.jpg',
    'assets/images/account.jpg',
    // Add more image paths as needed
  ];

  Widget buildExplore(HomeState state) {
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
            TextButton(
              onPressed: () {
                ref
                    .read(appNavigatorProvider)
                    .navigateTo(AppRoutes.lessons, arguments: state.lessons);
              },
              child: Text(
                AppLocalizations.of(context)!.viewAll,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: ScreenUtil().setSp(14),
                ),
              ),
            ),
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

  Widget buildAppBar() {
    final user = FirebaseAuth.instance.currentUser!;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              ref.read(appNavigatorProvider).navigateTo(
                    AppRoutes.editProfile,
                  );
            },
            child: CircleAvatar(
              radius: ScreenUtil().setHeight(20),
              child: ClipOval(
                child: user.photoURL != null
                    ? Image.network(user.photoURL!)
                    : AppImages.avatar(),
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            '${AppLocalizations.of(context)!.hi} ${user.displayName}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/category');
            },
            icon: Icon(Icons.search,
                color: Theme.of(context).iconTheme.color,
                size: ScreenUtil().setHeight(24)),
          )
        ],
      ),
    );
  }

  Widget buildCategories(HomeState state) {
    final categories = state.categories;
    final maxVisibleCategories = 10; // Số lượng phần tử hiển thị tối đa

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.categories,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton(
                  onPressed: () {
                    ref.read(appNavigatorProvider).navigateTo(
                        AppRoutes.categories,
                        arguments: categories);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          state.categoriesLoadingStatus == LoadingStatus.success
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, //
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: categories.length > maxVisibleCategories
                        ? maxVisibleCategories + 1 //
                        : categories.length,
                    itemBuilder: (context, index) {
                      if (index == maxVisibleCategories) {
                        return GestureDetector(
                          onTap: () {
                            ref.read(appNavigatorProvider).navigateTo(
                                AppRoutes.categories,
                                arguments: categories);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: Text(
                                "More", // Dấu "..." để mở rộng
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return buildCategoryItem(categories[index], index);
                      }
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget buildCategoryItem(Category category, int index) {
    final isDarkTheme = ref.watch(themeProvider);
    final language = ref.watch(appLanguageProvider);
    return GestureDetector(
      onTap: () {
        ref
            .read(appNavigatorProvider)
            .navigateTo(AppRoutes.category, arguments: category);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: isDarkTheme ? Colors.grey[700]! : Colors.black12,
          ),
          color: isDarkTheme ? Colors.grey[800] : Colors.white,
        ),
        child: Row(
          children: [
            isDarkTheme ? categoryDarkIcons[index] : categoryIcons[index],
            const SizedBox(width: 8),
            Text(
              language == Language.english
                  ? category.name
                  : category.translation,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReels(HomeState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                'Reels',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(child: Container())
          ],
        ),
        SizedBox(
          height: ScreenUtil().setHeight(4),
        ),
        state.youtubeVideoListsLoadingStatus == LoadingStatus.success
            ? SizedBox(
                height: ScreenUtil().screenHeight * 0.3,
                child: ListView.builder(
                  itemCount: state.youtubeVideoLists.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(appNavigatorProvider).navigateTo(
                              AppRoutes.reels,
                              arguments: state.youtubeVideoLists[index]);
                        },
                        child: AspectRatio(
                          aspectRatio: 0.65,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black54),
                                  image: DecorationImage(
                                    image: NetworkImage(getBestThumbnailUrl(
                                        state.youtubeVideoLists[index].first
                                            .thumbnails)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom:
                                    12, // Adjust the position of the text as needed
                                left:
                                    16, // Adjust the position of the text as needed
                                right: 16,
                                child: Text(
                                  state.youtubeVideoLists[index].first.title ??
                                      '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(12),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : SizedBox(
                height: ScreenUtil().screenHeight * 0.3,
              ),
      ],
    );
  }

  Widget buildBanner() {
    const String _imagesPath = 'assets/images';

    final List<String> imagePaths = [
      '$_imagesPath/banner.png',
      '$_imagesPath/banner.png',
      '$_imagesPath/banner.png',
      '$_imagesPath/banner.png',
      '$_imagesPath/banner.png',
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height / 3.5, // Full screen height
      child: PageView.builder(
        controller: _bannerController,
        itemCount: imagePaths.length, //
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: AppImages.appBanner(
                imagePaths: [imagePaths[index]], //
                width: double.infinity, //
                boxFit: BoxFit.cover, // Adjust as necessary
              ),
            ),
          );
        },
      ),
    );
  }
}

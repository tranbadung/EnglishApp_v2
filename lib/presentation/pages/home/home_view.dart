import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/data/providers/app_language_provider.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/data/providers/app_theme_provider.dart';
import 'package:speak_up/domain/entities/category/category.dart';
import 'package:speak_up/domain/entities/youtube_video/youtube_video.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:speak_up/domain/use_cases/firestore/get_flash_card_list_use_case.dart';
import 'package:speak_up/domain/use_cases/firestore/get_youtube_playlist_id_list_use_case.dart';
import 'package:speak_up/domain/use_cases/local_database/get_category_list_use_case.dart';
import 'package:speak_up/domain/use_cases/local_database/get_lesson_list_use_case.dart';
import 'package:speak_up/domain/use_cases/youtube/get_youtube_playlist_by_id_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/home/home_state.dart';
import 'package:speak_up/presentation/pages/home/home_view_model.dart';
import 'package:speak_up/presentation/pages/reels/reels_state.dart';
import 'package:speak_up/presentation/pages/reels/reels_view_model.dart';
import 'package:speak_up/presentation/pages/search/search_view.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/constant/category_icon_list.dart';
import 'package:speak_up/presentation/utilities/enums/language.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import 'package:path/path.dart' as path;

import '../../../data/models/test.dart';

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

  Future<void> _init() async {
    if (!mounted) return;

    await _viewModel.getCategoryList();
    if (!mounted) return;
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
  List<String> savedScores = [];

  @override
  void initState() {
    super.initState();
    _loadScore();

    Future.delayed(Duration.zero, () async {
      await _init();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bannerTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
          if (!mounted) return;
          if (_currentBannerPage < 2) {
            _currentBannerPage++;
          } else {
            _currentBannerPage = 0;
          }

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
    _bannerTimer?.cancel();
    _bannerController.dispose();

    super.dispose();
  }

  Future<void> _loadScore() async {
    double scoreListening = await getLatestScore("listening");
    double scoreReading = await getLatestScore("reading");
    double scoreWriting = await getLatestScore("writing");
    double scoreSpeaking = await getLatestScore("speaking");

    setState(() {
      _listeningScore = scoreListening;
      _readingScore = scoreReading;
      _writingScore = scoreWriting;
      _speakingScore = scoreSpeaking;
    });

    await updateUserScore(
      listeningScore: _listeningScore,
      readingScore: _readingScore,
      writingScore: _writingScore,
      speakingScore: _speakingScore,
    );
  }

  Future<void> updateUserScore({
    double listeningScore = 0.0,
    double readingScore = 0.0,
    double writingScore = 0.0,
    double speakingScore = 0.0,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final today = DateTime.now().toIso8601String().split('T')[0];
      DocumentReference userActivityRef =
      FirebaseFirestore.instance.collection('users').doc(userId);

      print('Updating user score for user: $userId');
      print('Listening score: $listeningScore');
      print('Reading score: $readingScore');
      print('Writing score: $writingScore');
      print('Speaking score: $speakingScore');

      // Update the user's score information
      await userActivityRef.set({
        'userId': userId,
        'scores': {
          'listening': listeningScore,
          'reading': readingScore,
          'writing': writingScore,
          'speaking': speakingScore,
        },
      }, SetOptions(merge: true));

      print('User score updated successfully');
    }
  }

  double _listeningScore = 0.0;

  double _writingScore = 0.0;
  double _readingScore = 0.0;
  double _speakingScore = 0.0;

  Future<double> getLatestScore(String skill) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${skill}_scores';
    final List<String> savedScores = prefs.getStringList(key) ?? [];

    if (savedScores.isEmpty) {
      print("No scores found for $skill.");
      return 0.0;
    }

    String latestScore = savedScores[0];
    double percentage = double.tryParse(latestScore.split('%')[0]) ?? 0.0;
    print("Retrieved score for $skill: $percentage%");
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final reelsState = ref.watch(reelsViewModelProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildAppBar(),
            buildBanner(),
            buildConversations(state),
            buildReels(reelsState),
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
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Skill",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Score %",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Progress",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              buildSkillTableRow("Listenning ", _listeningScore.toInt()),
              buildSkillTableRow("Reading", _readingScore.toInt()),
              // buildSkillTableRow("Writing", _writingScore.toInt()),
              // buildSkillTableRow("Speaking", _speakingScore.toInt()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReels(ReelsState reelsState) {
    Future<bool> checkAssetExists(String assetPath) async {
      try {
        await rootBundle.load(assetPath);
        return true;
      } catch (e) {
        return false;
      }
    }

    final isWeb = kIsWeb;

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
                  fontSize: ScreenUtil().setSp(isWeb ? 20 : 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(4)),
        if (reelsState.localVideos == LoadingStatus.loading)
          SizedBox(
            height: ScreenUtil().screenHeight * (isWeb ? 0.4 : 0.3),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (reelsState.localVideos.isNotEmpty)
          SizedBox(
            height: ScreenUtil().screenHeight * (isWeb ? 0.4 : 0.3),
            child: ListView.builder(
              itemCount: reelsState.localVideos.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final videoPath = reelsState.localVideos[index];
                final videoName = path.basename(videoPath).split('.').first;
                final thumbnailPath = reelsState.videoThumbnails.isNotEmpty &&
                    index < reelsState.videoThumbnails.length
                    ? reelsState.videoThumbnails[index]
                    : 'assets/images/video_placeholder.png';

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: GestureDetector(
                    onTap: () async {
                      if (videoPath.startsWith('assets/')) {
                        final exists = await checkAssetExists(videoPath);
                        if (!exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                              Text('Video asset không tồn tại: $videoPath'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      } else {
                        final file = File(videoPath);
                        print('Checking file exists: ${file.path}');
                        if (!file.existsSync()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'File video không tồn tại: ${file.path}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      Navigator.pushNamed(
                        context,
                        AppRoutes.reels,
                        arguments: {
                          'videos': reelsState.localVideos,
                          'initialIndex': index,
                        },
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: isWeb ? 0.75 : 0.65,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black54),
                              color: Colors.grey[300],
                              image: DecorationImage(
                                image: AssetImage(thumbnailPath),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print(
                                      'Error loading placeholder: $exception');
                                },
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: isWeb ? 60 : 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            right: 16,
                            child: Text(
                              videoName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(isWeb ? 14 : 12),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
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
        else
          SizedBox(
            height: ScreenUtil().screenHeight * (isWeb ? 0.4 : 0.3),
            child: const Center(
              child: Text('Không có video'),
            ),
          ),
      ],
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
                    'Có ${state.categories.length} Cuộc Đàm Thoại',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(16),
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (!kIsWeb) // Chỉ hiển thị nếu không phải là web
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
          height: ScreenUtil().screenHeight * 0.4,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            // itemCount: state.categories.length,
            itemCount: categories.length,

            itemBuilder: (context, index) {
              final category = categories[index];
              return buildConversationItem(category, index);

              // return buildConversationItem(
              //     state.categories[index], index);
            },
          ),
        )
            : state.categoriesLoadingStatus == LoadingStatus.error
            ? SizedBox(
          height: ScreenUtil().screenHeight * 0.4,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return buildConversationItem(category, index);
            },
          ),
        )
            : Container(),
      ],
    );
  }

  Widget buildConversationItem(Category category, int index) {
    final isDarkTheme = ref.watch(themeProvider);
    final language = ref.watch(appLanguageProvider);

    return kIsWeb
        ? Container(
      width: ScreenUtil().screenWidth * 0.7,
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
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    conversationImages[index % conversationImages.length],
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    color:
                    isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                    fontSize: ScreenUtil().setSp(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        : GestureDetector(
      onTap: () {
        ref
            .read(appNavigatorProvider)
            .navigateTo(AppRoutes.category, arguments: category);
      },
      child: Container(
        width: ScreenUtil().screenWidth * 0.7,
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
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      conversationImages[
                      index % conversationImages.length],
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
                    padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      color: isDarkTheme
                          ? Colors.grey[400]
                          : Colors.grey[600],
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

  Widget buildAppBar() {
    final user = FirebaseAuth.instance.currentUser!;
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWeb = constraints.maxWidth > 800;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (!isWeb)
                InkWell(
                  onTap: () {
                    ref
                        .read(appNavigatorProvider)
                        .navigateTo(AppRoutes.editProfile);
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
              const Spacer(),
              if (!isWeb)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WordSearchPage()),
                    );
                  },
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color,
                    size: ScreenUtil().setHeight(24),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCategories(HomeState state) {
    final categories = state.categories;
    final maxVisibleCategories = 10;

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
                          "More",
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

  Widget buildBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double bannerHeight =
        kIsWeb ? 500 : MediaQuery.of(context).size.height / 4;
        double bannerWidth =
        kIsWeb && constraints.maxWidth > 800 ? 800 : constraints.maxWidth;

        return Center(
          child: SizedBox(
            width: bannerWidth,
            height: bannerHeight,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0) {
                  _bannerController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                } else if (details.delta.dx < 0) {
                  _bannerController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                }
              },
              child: PageView.builder(
                controller: _bannerController,
                itemCount: imagePaths.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

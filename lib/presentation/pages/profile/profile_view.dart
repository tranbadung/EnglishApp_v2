import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/data/providers/app_language_provider.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/data/providers/app_theme_provider.dart';
import 'package:speak_up/data/repositories/firestore/firestore_repository.dart';
import 'package:speak_up/domain/use_cases/account_settings/get_app_theme_use_case.dart';
import 'package:speak_up/domain/use_cases/account_settings/save_app_language_use_case.dart';
import 'package:speak_up/domain/use_cases/account_settings/switch_app_theme_use_case.dart';
import 'package:speak_up/domain/use_cases/authentication/sign_out_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/chat/chat_view.dart';
import 'package:speak_up/presentation/pages/profile/profile_state.dart';
import 'package:speak_up/presentation/pages/profile/profile_view_model.dart';
import 'package:speak_up/presentation/resources/app_icons.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/enums/language.dart';
import 'package:speak_up/presentation/widgets/loading_indicator/app_loading_indicator.dart';

import 'package:speak_up/data/repositories/local_database/local_dtb.dart';

import '../admin/management_screen.dart';

class ActivityViewModel extends StateNotifier<List<String>> {
  final UserActivityManager _userActivityManager;
  bool _isRecording = false;

  ActivityViewModel(this._userActivityManager) : super([]);

  Future<void> recordActivity() async {
    if (_isRecording) return;

    _isRecording = true;
    try {
      await _userActivityManager.recordUserActivity();
      await fetchUserActivity();
    } finally {
      _isRecording = false;
    }
  }

  Future<void> fetchUserActivity() async {
    final activityData = await _userActivityManager.getUserActivity();
    List<String> activities = [
      "Số ngày truy cập: ${activityData['daysVisited']}",
      "Tổng thời gian học: ${activityData['todayStudySeconds']}",
      'Ngày đăng nhập gần nhất: ${activityData['accessDates']}',
      'Study Streak: ${activityData['studyStreak']} ngày',
    ];
    state = activities;
  }
}

String _formatStudyTime(int seconds) {
  if (seconds < 60) {
    return '$seconds giây';
  } else if (seconds < 3600) {
    int minutes = seconds ~/ 60;

    int remainingSeconds = seconds % 60;
    return '$minutes phút ${remainingSeconds > 0 ? "$remainingSeconds giây" : ""}';
  } else {
    int hours = seconds ~/ 3600;
    int remainingMinutes = (seconds % 3600) ~/ 60;
    return '$hours giờ ${remainingMinutes > 0 ? "$remainingMinutes phút" : ""}';
  }
}

final activityViewModelProvider =
StateNotifierProvider<ActivityViewModel, List<String>>((ref) {
  final firestoreRepository = FirestoreRepository(FirebaseFirestore.instance);
  return ActivityViewModel(UserActivityManager(firestoreRepository));
});

class ProgressTrackingScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProgressTrackingScreen> createState() =>
      _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState
    extends ConsumerState<ProgressTrackingScreen> {
  late int todayIndex;

  @override
  void initState() {
    super.initState();
    todayIndex = DateTime.now().weekday % 7;
    Future.microtask(() {
      ref.read(activityViewModelProvider.notifier).recordActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userActivities = ref.watch(activityViewModelProvider);

    if (userActivities.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(context, userActivities),
    );
  }

  Widget _buildStreakCard(List<String> userActivities) {
    String streakText = userActivities.firstWhere(
          (activity) => activity.contains("Study Streak"),
      orElse: () => "Study Streak: 0 ngày",
    );

    final streak =
        int.tryParse(RegExp(r'\d+').firstMatch(streakText)?.group(0) ?? "0") ??
            0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[200]!.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Study Streak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '$streak ngày',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Giữ vững thành tích học tập!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Hoạt động',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileView()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, List<String> userActivities) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildStatsRow(userActivities),
            SizedBox(height: 20),
            _buildStreakCard(userActivities),
            SizedBox(height: 20),
            _buildRecentActivities(userActivities),
            SizedBox(height: 20),
            _buildDayBoxes(todayIndex),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  return Text(
    'Theo dõi tiến độ luyện tập!',
    style: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
}

Widget _buildStatsRow(List<String> userActivities) {
  String daysText = userActivities.firstWhere(
        (activity) => activity.contains("Số ngày truy cập"),
    orElse: () => "0",
  );

  String timeText = userActivities.firstWhere(
        (activity) => activity.contains("Tổng thời gian học"),
    orElse: () => "0",
  );

  final days =
      int.tryParse(RegExp(r'\d+').firstMatch(daysText)?.group(0) ?? "0") ?? 0;
  final studySeconds =
      int.tryParse(RegExp(r'\d+').firstMatch(timeText)?.group(0) ?? "0") ?? 0;

  String formattedTime = _formatStudyTime(studySeconds);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildStatCard(
        days.toString(),
        'Số ngày duy trì',
        Colors.blue[300]!,
      ),
      _buildStatCard(
        formattedTime,
        'Thời gian học hôm nay',
        Colors.orange[300]!,
      ),
    ],
  );
}

Widget _buildStatCard(String value, String label, Color color) {
  return Container(
    width: 150,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRecentActivities(List<String> activities) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          activities.isEmpty
              ? Text('Chưa có hoạt động nào.')
              : ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(activities[index]),
              );
            },
          ),
        ],
      ),
    ),
  );
}

int todayIndex = DateTime.now().weekday % 7; // 0 for Sunday, 1 for Monday, etc.
Widget _buildDayBoxes(int loginDayIndex) {
  final daysOfWeek = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return Row(
    mainAxisAlignment:
    kIsWeb ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
    children: List.generate(7, (index) {
      bool isToday = index == loginDayIndex;
      return Expanded(
        // Sử dụng Expanded để các phần tử tự động điều chỉnh kích thước
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 10.0 : 2.0,
          ),
          child: Container(
            height: kIsWeb ? 100 : 60,
            decoration: BoxDecoration(
              color: isToday ? Colors.purple[300] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                daysOfWeek[index],
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }),
  );
}

int _getHoursFromActivity(String activity) {
  final match = RegExp(r'(\d+) giờ').firstMatch(activity);
  return int.parse(match?.group(1) ?? "0");
}

final profileViewModelProvider =
StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) =>
    ProfileViewModel(
        injector.get<GetAppThemeUseCase>(),
        injector.get<SwitchAppThemeUseCase>(),
        injector.get<SignOutUseCase>()));

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ProfileViewState();
}

class ProfileViewState extends ConsumerState<ProfileView> {
  String userRole = 'user'; // Mặc định là 'user'

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      ref.read(profileViewModelProvider.notifier).getThemeData();
      _getUserRole(); // Gọi phương thức để lấy vai trò người dùng
    });
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'] ?? 'user'; // Lấy vai trò từ Firestore
        });
      }
    }
  }

  Future<void> _buildLogoutDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logOut),
          content: Text(
            AppLocalizations.of(context)!.areYouSureYouWantToLogOut,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(16.0),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ScreenUtil().setSp(14.0),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(profileViewModelProvider.notifier).signOut();
                Future.delayed(const Duration(seconds: 1), () {
                  ref
                      .read(appNavigatorProvider)
                      .navigateTo(AppRoutes.onboarding, shouldClearStack: true);
                });
              },
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                AppLocalizations.of(context)!.no,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(14.0),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onTapChangeLanguage(WidgetRef ref) async {
    final isDarkTheme = ref.watch(themeProvider);
    switch (await showDialog<Language>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(16.0),
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Language.english);
                },
                child: ListTile(
                    leading: AppImages.usFlag(),
                    title: Text(
                      Language.english.toLanguageString(),
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontSize: ScreenUtil().setSp(14.0),
                      ),
                    )),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Language.vietnamese);
                },
                child: ListTile(
                    leading: AppImages.vnFlag(),
                    title: Text(
                      Language.vietnamese.toLanguageString(),
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                        fontSize: ScreenUtil().setSp(14.0),
                      ),
                    )),
              ),
            ],
          );
        })) {
      case Language.english:
        ref.read(appLanguageProvider.notifier).state = Language.english;
        break;
      case Language.vietnamese:
        ref.read(appLanguageProvider.notifier).state = Language.vietnamese;
        break;
      case null:
        break;
    }
    injector
        .get<SaveAppLanguageUseCase>()
        .run(ref.read(appLanguageProvider.notifier).state);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final user = FirebaseAuth.instance.currentUser;

    // Sử dụng MediaQuery để xác định kích thước màn hình
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.accountSettings,
          style: TextStyle(fontSize: ScreenUtil().setSp(16)),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _buildLogoutDialogBuilder(context);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.red,
              size: ScreenUtil().setHeight(24),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(isWideScreen
                      ? 48.0
                      : 32.0), // Thay ��ổi padding dựa trên kích thước màn hình
                  child: CircleAvatar(
                    radius: isWideScreen
                        ? 48
                        : ScreenUtil()
                        .setHeight(24), // Thay đổi kích thước cho web
                    child: ClipOval(
                      child: user?.photoURL != null
                          ? Image.network(user!.photoURL!)
                          : AppImages.avatar(),
                    ),
                  ),
                ),
                Text(
                  user?.displayName ?? '',
                  style: TextStyle(
                    fontSize: isWideScreen
                        ? 32
                        : ScreenUtil()
                        .setSp(24.0), // Thay đổi kích thước cho web
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                buildOptionsSection(state, user,
                    isWideScreen), // Phân tách để xử lý các tùy chọn
              ],
            ),
          ),
          if (state.isSigningOut) const AppLoadingIndicator(),
        ],
      ),
    );
  }

  Widget buildOptionsSection(
      ProfileState state, User? user, bool isWideScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildListTile(
          AppIcons.avatar(
              size: isWideScreen ? 64 : 48), // Kích thước cho biểu tượng
          AppLocalizations.of(context)!.editProfile,
          onTap: () {
            ref.read(appNavigatorProvider).navigateTo(AppRoutes.editProfile);
          },
        ),
        if (user?.providerData[0].providerId == 'password')
          buildListTile(
            AppIcons.changePassword(size: isWideScreen ? 64 : 48),
            AppLocalizations.of(context)!.changePassword,
            onTap: () {
              ref
                  .read(appNavigatorProvider)
                  .navigateTo(AppRoutes.changePassword);
            },
          ),
        buildListTile(
          AppIcons.darkMode(size: isWideScreen ? 64 : 48),
          AppLocalizations.of(context)!.darkMode,
          trailing: Switch(
            value: state.isDarkMode,
            onChanged: (value) {
              ref
                  .read(profileViewModelProvider.notifier)
                  .changeThemeData(value);
              ref.read(themeProvider.notifier).state = value;
            },
          ),
        ),
        buildListTile(
          AppIcons.changeLanguage(size: isWideScreen ? 64 : 48),
          AppLocalizations.of(context)!.language,
          trailing: ref.watch(appLanguageProvider) == Language.english
              ? AppImages.usFlag()
              : AppImages.vnFlag(),
          onTap: () {
            _onTapChangeLanguage(ref);
            injector
                .get<SaveAppLanguageUseCase>()
                .run(ref.read(appLanguageProvider.notifier).state);
          },
        ),
        // buildListTile(
        //   AppIcons.about(size: isWideScreen ? 64 : 48),
        //   AppLocalizations.of(context)!.about,
        //   onTap: () {
        //     ref.read(appNavigatorProvider).navigateTo(AppRoutes.about);
        //   },
        // ),
        if (userRole == 'admin') // Kiểm tra vai trò
          buildListTile(
            AppIcons.about(size: isWideScreen ? 64 : 48),
            'Manager',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManagementScreen()));
            },
          ),
        buildListTile(
          AppIcons.logout(size: isWideScreen ? 64 : 46),
          AppLocalizations.of(context)!.logOut,
          onTap: () async {
            await _buildLogoutDialogBuilder(context);
          },
        ),
      ],
    );
  }

  Widget buildListTile(Widget icon, String title,
      {Widget? trailing, Function()? onTap}) {
    final darkTheme = ref.watch(themeProvider);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(),
      child: ListTile(
        leading: icon,
        contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(8),
            vertical: ScreenUtil().setHeight(4)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(16),
            color: darkTheme ? Colors.white : Colors.black,
          ),
        ),
        onTap: onTap,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_up/data/repositories/firestore/firestore_repository.dart';

import 'main_menu_state.dart';

class MainMenuViewModel extends StateNotifier<MainMenuState> {
  MainMenuViewModel() : super(const MainMenuState(currentTabIndex: 0));

  void changeTab(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  Future<void> fetchUserRole(String userId) async {
    try {
      String? role = await FirestoreRepository(FirebaseFirestore.instance)
          .getUserRole(userId);

      if (role != null) {
        state = state.copyWith(userRole: role);
      }
    } catch (e) {}
  }
}

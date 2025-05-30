import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_menu_state.freezed.dart';

@freezed
class MainMenuState with _$MainMenuState {
  const factory MainMenuState({
    String? userRole, // Thêm thuộc tính userRole vào state

    required int currentTabIndex,
  }) = _MainMenuState;
}

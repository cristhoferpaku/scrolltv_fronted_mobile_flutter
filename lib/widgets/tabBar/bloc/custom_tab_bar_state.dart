part of 'custom_tab_bar_bloc.dart';

@freezed
class CustomTabBarState with _$CustomTabBarState {
  const factory CustomTabBarState.initial() = _Initial;
  const factory CustomTabBarState.loaded(int currentIndex) = CustomTabBarStateLoaded;
}

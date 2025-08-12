part of 'custom_tab_bar_bloc.dart';

@freezed
class CustomTabBarEvent with _$CustomTabBarEvent {
  const factory CustomTabBarEvent.started() = _CustomTabBarEventStarted;
  const factory CustomTabBarEvent.changeTab(int index) = _CustomTabBarEventChangeTab;
}

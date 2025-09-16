part of 'tv_player_bloc.dart';

@freezed
class TvPlayerState with _$TvPlayerState {
  const factory TvPlayerState({
    required TVPlayerStatus status,
    required List<ChannelModel> channels,
    required ChannelModel? selectedChannelIndex,
    required bool showChannelList,
    required int selectedCategoryIndex,
    required FocusEnum focusEnum,
    required List<ChannelCategoryModel> categories,
    required List<ChannelModel> homeCategories,
    required List<ChannelModel> allChannels,
  }) = _TvPlayerState;
}

enum TVPlayerStatus {
  initial,
  loading,
  loadingChannels,
  loadingCategories,
  loaded,
  loadedCategories,
  loadedChannels,
  loadedChannelsByCategory,
  changeCategorySuccess,
  changeChannelSuccess,
  success,
  error,
  showPanelChannelByHomeSuccess,
}

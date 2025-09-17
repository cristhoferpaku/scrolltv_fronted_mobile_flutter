part of 'tv_player_bloc.dart';

@freezed
class TvPlayerEvent with _$TvPlayerEvent {
  const factory TvPlayerEvent.started() = _TVPlayerEventStarted;
  const factory TvPlayerEvent.loadChannels() = _TVPlayerEventLoadChannels;
  const factory TvPlayerEvent.loadCategories() = _TVPlayerEventLoadCategories;
  const factory TvPlayerEvent.changeChannel(ChannelModel channelIndex) = _TVPlayerEventChangeChannel;
  const factory TvPlayerEvent.changeNextChannel() = _TVPlayerEventChangeNextChannel;
  const factory TvPlayerEvent.changePreviousChannel() = _TVPlayerEventChangePreviousChannel;
  const factory TvPlayerEvent.changeCategory(int categoryIndex) = _TVPlayerEventChangeCategory;
  const factory TvPlayerEvent.loadChannelsByCategory(ChannelCategoryModel category) = _TVPlayerEventLoadChannelsByCategory;
  const factory TvPlayerEvent.showPanelChannel(bool value) = _TVPlayerEventShowPanelChannel;
  const factory TvPlayerEvent.changeFocus(FocusEnum focusEnum) = _TVPlayerEventChangeFocus;
  const factory TvPlayerEvent.showPanelChannelByHome() = _TVPlayerEventShowPanelChannelByHome;
  const factory TvPlayerEvent.showChannelChangeSuccess(bool value) = _TVPlayerEventShowChannelChangeSuccess;
}

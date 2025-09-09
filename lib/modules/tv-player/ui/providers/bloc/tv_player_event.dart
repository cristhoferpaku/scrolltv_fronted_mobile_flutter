part of 'tv_player_bloc.dart';

@freezed
class TvPlayerEvent with _$TvPlayerEvent {
  const factory TvPlayerEvent.started() = _TVPlayerEventStarted;
  const factory TvPlayerEvent.loadChannels() = _TVPlayerEventLoadChannels;
  const factory TvPlayerEvent.loadCategories() = _TVPlayerEventLoadCategories;
  const factory TvPlayerEvent.changeChannel(ChannelModel channelIndex) = _TVPlayerEventChangeChannel;
  const factory TvPlayerEvent.changeCategory(int categoryIndex) = _TVPlayerEventChangeCategory;
  const factory TvPlayerEvent.showPanelChannel(bool value) = _TVPlayerEventShowPanelChannel;
  const factory TvPlayerEvent.changeFocus(FocusEnum focusEnum) = _TVPlayerEventChangeFocus;
}

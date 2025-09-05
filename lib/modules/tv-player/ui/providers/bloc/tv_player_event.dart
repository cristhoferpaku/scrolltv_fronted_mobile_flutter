part of 'tv_player_bloc.dart';

@freezed
class TvPlayerEvent with _$TvPlayerEvent {
  const factory TvPlayerEvent.started() = _TVPlayerEventStarted;
  const factory TvPlayerEvent.changeChannel(int channelIndex) = _TVPlayerEventChangeChannel;
}

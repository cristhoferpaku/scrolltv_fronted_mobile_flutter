import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_player_bloc.freezed.dart';
part 'video_player_event.dart';
part 'video_player_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  VideoPlayerBloc() : super(_Initial()) {
    on<VideoPlayerEvent>((event, emit) {});
    on<_VideoPlayerEventStarted>((event, emit) {});
  }
}

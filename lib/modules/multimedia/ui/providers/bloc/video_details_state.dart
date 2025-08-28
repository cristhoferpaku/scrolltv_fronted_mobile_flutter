part of 'video_details_bloc.dart';

@freezed
class VideoDetailsState with _$VideoDetailsState {
  const factory VideoDetailsState.initial() = _Initial;
  const factory VideoDetailsState.loaded({
    required VideoDetailsStateStatus status,
    required VideoContentModel? videoContent,
    required GetHomeSectionModel? homeSectionData,
  }) = VideoDetailsStateLoaded;
}

enum VideoDetailsStateStatus {
  initial,
  loading,
  loadingVideo,
  loadingSection,
  loaded,
  error,
}

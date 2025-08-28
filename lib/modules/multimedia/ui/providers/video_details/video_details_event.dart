part of 'video_details_bloc.dart';

@freezed
class VideoDetailsEvent with _$VideoDetailsEvent {
  const factory VideoDetailsEvent.started(int videoId) = VideoDetailsEventStarted;
  const factory VideoDetailsEvent.getVideoById(int videoId) = VideoDetailsEventGetVideoById;
  const factory VideoDetailsEvent.getSectionContent(int sectionId) = VideoDetailsEventGetSectionContent;
  const factory VideoDetailsEvent.reset() = VideoDetailsEventReset;
}

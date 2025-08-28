import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/get_home_section_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';

part 'video_details_bloc.freezed.dart';
part 'video_details_event.dart';
part 'video_details_state.dart';

class VideoDetailsBloc extends Bloc<VideoDetailsEvent, VideoDetailsState> {
  VideoDetailsBloc() : super(_Initial()) {
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    VideoContentModel? videoContent;
    GetHomeSectionModel? homeSectionData;
    on<VideoDetailsEvent>((event, emit) {});
    on<VideoDetailsEventReset>((event, emit) {
      videoContent = null;
      homeSectionData = null;
    });
    on<VideoDetailsEventStarted>((event, emit) async {
      add(VideoDetailsEventReset());
      add(VideoDetailsEventGetVideoById(event.videoId));
    });
    on<VideoDetailsEventGetVideoById>((event, emit) async {
      emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loadingVideo, videoContent: videoContent, homeSectionData: homeSectionData));
      await Future.delayed(const Duration(seconds: 1));
      final response = await multimediaUseCase.getVideoContentById(event.videoId);
      if (response.success) {
        videoContent = response.data;

        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loaded, videoContent: videoContent, homeSectionData: homeSectionData));

        if (videoContent!.video!.sectionId != null) {
          add(VideoDetailsEvent.getSectionContent(videoContent!.video!.sectionId!));
        }
      }
    });
    on<VideoDetailsEventGetSectionContent>((event, emit) async {
      emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loadingSection, videoContent: videoContent, homeSectionData: homeSectionData));
      final response = await multimediaUseCase.getHomeSection(event.sectionId);
      if (response.success) {
        homeSectionData = response.data;
        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loaded, videoContent: videoContent, homeSectionData: homeSectionData));
      }
    });
  }
}

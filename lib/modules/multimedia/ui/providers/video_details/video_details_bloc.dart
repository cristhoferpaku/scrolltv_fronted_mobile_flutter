import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/collection_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_content_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/logger_manager.dart';

part 'video_details_bloc.freezed.dart';
part 'video_details_event.dart';
part 'video_details_state.dart';

class VideoDetailsBloc extends Bloc<VideoDetailsEvent, VideoDetailsState> {
  VideoDetailsBloc() : super(_Initial()) {
    final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
    VideoContentModel? videoContent;
    List<CollectionModel>? collections;
    on<VideoDetailsEvent>((event, emit) {});
    on<VideoDetailsEventReset>((event, emit) {
      videoContent = null;
      collections = null;
    });
    on<VideoDetailsEventStarted>((event, emit) async {
      if (event.videoId == 0) {
        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.error, videoContent: videoContent, collections: collections));
        return;
      }
      add(VideoDetailsEventReset());
      add(VideoDetailsEventGetVideoById(event.videoId));
    });
    on<VideoDetailsEventGetVideoById>((event, emit) async {
      try {
        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loadingVideo, videoContent: videoContent, collections: collections));
        final response = await multimediaUseCase.getVideoContentById(event.videoId);
        if (response.success) {
          videoContent = response.data;

          emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loaded, videoContent: videoContent, collections: collections));

          add(VideoDetailsEvent.getSectionContent(videoContent?.video?.id ?? 0));
        }
      } catch (e) {
        LoggerManager.log.e(e);
        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.error, videoContent: videoContent, collections: collections));
      }
    });
    on<VideoDetailsEventGetSectionContent>((event, emit) async {
      emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loadingSection, videoContent: videoContent, collections: collections));
      try {
        final response = await multimediaUseCase.getCollectionsByVideoId(videoContent?.video?.id ?? 0);
        if (response.success) {
          collections = response.data;
          emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loaded, videoContent: videoContent, collections: collections));
        }
      } catch (e) {
        LoggerManager.log.e(e);
        emit(VideoDetailsState.loaded(status: VideoDetailsStateStatus.loaded, videoContent: videoContent, collections: collections));
      }
    });
  }
}

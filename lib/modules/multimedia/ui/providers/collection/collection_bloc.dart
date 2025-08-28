import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/entities/video_model.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/domain/ports/inbound/multimedia_use_case.dart';

part 'collection_bloc.freezed.dart';
part 'collection_event.dart';
part 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final MultimediaUseCase multimediaUseCase = instance<MultimediaUseCase>();
  CollectionBloc() : super(_Initial()) {
    int collectionId = 0;
    String collectionName = "";
    List<VideoModel>? videos;
    on<CollectionEvent>((event, emit) {});
    on<_CollectionEventStarted>((event, emit) {
      collectionId = event.collectionId;
      collectionName = event.collectionName;
      add(_CollectionEventGetCollection(event.collectionId));
    });
    on<_CollectionEventGetCollection>((event, emit) async {
      emit(CollectionState.loaded(status: CollectionStateStatus.loading, collectionName: collectionName, videos: videos));
      await Future.delayed(const Duration(seconds: 3));
      try {
        final collectionResult = await multimediaUseCase.getVideosByCollectionId(collectionId);
        videos = collectionResult.data;
        emit(CollectionState.loaded(status: CollectionStateStatus.loaded, collectionName: collectionName, videos: videos));
      } catch (e) {
        emit(CollectionState.loaded(status: CollectionStateStatus.error, collectionName: collectionName, videos: []));
      }
    });
  }
}

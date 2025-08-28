part of 'collection_bloc.dart';

@freezed
class CollectionState with _$CollectionState {
  const factory CollectionState.initial() = _Initial;
  const factory CollectionState.loaded({
    required CollectionStateStatus status,
    required String collectionName,
    required List<VideoModel>? videos,
  }) = CollectionStateLoaded;
}

enum CollectionStateStatus {
  initial,
  loading,
  loaded,
  error,
}

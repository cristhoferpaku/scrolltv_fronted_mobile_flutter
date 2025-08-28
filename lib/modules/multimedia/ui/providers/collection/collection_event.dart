part of 'collection_bloc.dart';

@freezed
class CollectionEvent with _$CollectionEvent {
  const factory CollectionEvent.started(int collectionId, String collectionName) = _CollectionEventStarted;
  const factory CollectionEvent.getCollection(int collectionId) = _CollectionEventGetCollection;
}

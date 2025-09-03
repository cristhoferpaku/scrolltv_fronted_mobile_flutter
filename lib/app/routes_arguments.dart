class VideoDetailsPageArguments {
  final int videoId;
  VideoDetailsPageArguments({required this.videoId});
}

class CollectionPageArguments {
  final int collectionId;
  final String collectionName;
  CollectionPageArguments({required this.collectionId, required this.collectionName});
}

class VideoPageArguments {
  final int videoId;
  final String videoUrl;
  VideoPageArguments({required this.videoId, required this.videoUrl});
}

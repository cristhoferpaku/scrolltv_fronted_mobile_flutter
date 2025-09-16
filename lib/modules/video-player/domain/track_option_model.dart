import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_option_model.freezed.dart';
part 'track_option_model.g.dart';

@freezed
class TrackOptionModel with _$TrackOptionModel {
  factory TrackOptionModel({
    required int key,
    required String value,
  }) = _TrackOptionModel;

  factory TrackOptionModel.fromJson(Map<String, dynamic> json) => _$TrackOptionModelFromJson(json);
}

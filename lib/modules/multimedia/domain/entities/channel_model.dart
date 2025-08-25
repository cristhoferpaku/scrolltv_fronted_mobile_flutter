import 'package:freezed_annotation/freezed_annotation.dart';
part 'channel_model.freezed.dart';
part 'channel_model.g.dart';

@freezed
class ChannelModel with _$ChannelModel {
  factory ChannelModel({
    required String name,
    required Uri url,
  }) = _ChannelModel;

  factory ChannelModel.fromJson(Map<String, dynamic> json) =>
      _$ChannelModelFromJson(json);
}

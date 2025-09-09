import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/tv-player/domain/entities/channel_model.dart';

part 'channel_category_model.freezed.dart';
part 'channel_category_model.g.dart';

@freezed
class ChannelCategoryModel with _$ChannelCategoryModel {
  factory ChannelCategoryModel({
    required String name,
    required List<ChannelModel> channels,
  }) = _ChannelCategoryModel;

  factory ChannelCategoryModel.fromJson(Map<String, dynamic> json) => _$ChannelCategoryModelFromJson(json);
}

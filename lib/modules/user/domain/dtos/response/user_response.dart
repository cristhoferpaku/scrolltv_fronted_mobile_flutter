import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "username") String? username,
    @JsonKey(name: "platform_id") int? platformId,
    @JsonKey(name: "platform_name") String? platformName,
    @JsonKey(name: "package_user_id") int? packageUserId,
    @JsonKey(name: "package_user_name") String? packageUserName,
    @JsonKey(name: "status") int? status,
    @JsonKey(name: "service_started") bool? serviceStarted,
    @JsonKey(name: "start_date") String? startDate,
    @JsonKey(name: "expiration_date") String? expirationDate,
    @JsonKey(name: "can_change_package") bool? canChangePackage,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

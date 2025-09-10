part of 'date_time_bloc.dart';

@freezed
class DateTimeState with _$DateTimeState {
  const factory DateTimeState({required DateTimeStatus status, String? hourMinute, String? dayName, String? date}) = _DateTimeState;
}

enum DateTimeStatus {
  initial,
  loading,
  success,
  error,
}

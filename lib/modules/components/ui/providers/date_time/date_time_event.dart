part of 'date_time_bloc.dart';

@freezed
class DateTimeEvent with _$DateTimeEvent {
  const factory DateTimeEvent.started() = _DateTimeEventStarted;
  const factory DateTimeEvent.start() = _DateTimeEventStart;
  const factory DateTimeEvent.update() = _DateTimeEventUpdate;
}

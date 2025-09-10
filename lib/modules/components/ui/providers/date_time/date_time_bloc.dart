import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/constants/utils/date_time_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/constants/utils/string_utils.dart';

part 'date_time_bloc.freezed.dart';
part 'date_time_event.dart';
part 'date_time_state.dart';

class DateTimeBloc extends Bloc<DateTimeEvent, DateTimeState> {
  Timer? timer;
  DateTimeBloc() : super(DateTimeState(status: DateTimeStatus.initial, hourMinute: null, dayName: null, date: null)) {
    on<_DateTimeEventStarted>((event, emit) {
      add(const DateTimeEvent.start());
    });
    on<_DateTimeEventStart>((event, emit) {
      final now = DateTime.now();
      final hourMinute = getHourMinute(date: now);
      final dayName = getTextCapitalize(getDayName(date: now));
      final date = getDate(date: now);

      emit(DateTimeState(status: DateTimeStatus.success, hourMinute: hourMinute, dayName: dayName, date: date));
      _scheduleNextUpdate();
    });

    on<_DateTimeEventUpdate>((event, emit) {
      final now = DateTime.now();

      final hourMinute = getHourMinute(date: now);
      final dayName = getTextCapitalize(getDayName(date: now));
      final date = getDate(date: now);

      emit(DateTimeState(status: DateTimeStatus.success, hourMinute: hourMinute, dayName: dayName, date: date));
      _scheduleNextUpdate();
    });
  }

  void _scheduleNextUpdate() {
    timer?.cancel();
    final now = DateTime.now();

    final nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    final durationUntilNextMinute = nextMinute.difference(now);

    timer = Timer(durationUntilNextMinute, () {
      add(const DateTimeEvent.update());
    });
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}

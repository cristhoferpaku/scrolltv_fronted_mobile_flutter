import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/di.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/components/ui/providers/date_time/date_time_bloc.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class DateTimeDisplay extends StatefulWidget {
  const DateTimeDisplay({
    super.key,
  });

  @override
  State<DateTimeDisplay> createState() => _DateTimeDisplayState();
}

class _DateTimeDisplayState extends State<DateTimeDisplay> {
  final DateTimeBloc dateTimeBloc = instance<DateTimeBloc>();

  @override
  void initState() {
    super.initState();
    dateTimeBloc.add(const DateTimeEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DateTimeBloc, DateTimeState>(
      bloc: dateTimeBloc,
      listener: (context, state) {},
      builder: (context, state) {
        return Row(
          spacing: AppPadding.p8,
          children: [
            Text(state.hourMinute ?? "", style: Theme.of(context).textTheme.titleMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.dayName ?? "", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(state.date ?? "", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        );
      },
    );
  }
}

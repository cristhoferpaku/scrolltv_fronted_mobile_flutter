import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/top_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

class TopCardList extends StatelessWidget {
  final String title;
  const TopCardList({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: CustomGridTraversalPolicy(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppPadding.p16,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppPadding.p36,
              children: List.generate(
                10,
                (index) => TopCard(
                  title: index.toString(),
                  topNumber: index + 1,
                ),
              ),
            ).withPadding(vertical: AppPadding.p16),
          )
        ],
      ),
    );
  }
}

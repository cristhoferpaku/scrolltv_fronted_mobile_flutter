import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/multimedia/ui/components/molecules/section_card.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/focus_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/platform_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class SectionCardList extends StatelessWidget {
  final String title;
  const SectionCardList({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isTV = PlatformUtils.isTV;
    return FocusTraversalGroup(
      policy: CustomGridTraversalPolicy(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppPadding.p16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (!isTV)
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: ColorManager.onSurface,
                          )),
                  ],
                ),
              ),
              if (isTV)
                ElevatedButtonApp(
                  press: () {},
                  textStyleButton: Theme.of(context).textTheme.bodySmall,
                  textButton: 'Ver colección',
                  colorButton: ColorManager.transparent,
                  colorBorder: ColorManager.primaryContainer,
                  roundedButton: AppSize.s120,
                  paddingHorizontal: AppPadding.p40,
                  paddingVertical: AppPadding.p12,
                  widthBorder: 1.5,
                  isExpanded: false,
                )
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppPadding.p36,
              children: List.generate(
                10,
                (index) => SectionCard(title: index.toString()),
              ),
            ).withPadding(vertical: AppPadding.p16),
          )
        ],
      ),
    );
  }
}

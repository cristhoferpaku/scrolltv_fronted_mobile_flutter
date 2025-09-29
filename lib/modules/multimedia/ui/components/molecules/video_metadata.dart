import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/my_utils.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';

class VideoMetadata extends StatelessWidget {
  const VideoMetadata({
    super.key,
    required this.section,
    required this.year,
    required this.duration,
    required this.genre,
  });
  final String section;
  final String year;
  final String duration;
  final String genre;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppPadding.p8,
      children: [
        ExcludeFocus(
          child: ElevatedButtonApp(
            paddingHorizontal: 8,
            paddingVertical: 4,
            isExpanded: false,
            textButton: genre,
            colorButton: ColorManager.transparent,
            colorBorder: ColorManager.onSurface,
            textStyleButton: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ColorManager.onSurface,
                ),
            roundedButton: AppSize.s200,
            press: () async {},
          ),
        ),
        CircleAvatar(
          radius: 2,
          backgroundColor: ColorManager.neutro200,
        ),
        Text(
          year,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ColorManager.onSurface,
              ),
        ),
        CircleAvatar(
          radius: 2,
          backgroundColor: ColorManager.neutro200,
        ),
        Text(
          duration.isNotEmpty ? duration : "No hay duración",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ColorManager.onSurface,
              ),
        ),
        // CircleAvatar(
        //   radius: 2,
        //   backgroundColor: ColorManager.neutro200,
        // ),
        // Text(
        //   genre,
        //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
        //         color: ColorManager.onSurface,
        //       ),
        // ),
      ],
    );
  }
}

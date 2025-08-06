// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/small_rounded_button.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/enum_widgets.dart';

class AppDialogShake extends StatelessWidget {

  final AppDialogType typeDialog;
  final String title;
  final String description;
  final String labelCancel;
  final String labelAction;
  final Function? functionOk;
  final Function? functionCancel;
  final String pathImageDialog;
  final TypeImageAsset imageType;

  const AppDialogShake({
    this.typeDialog = AppDialogType.SUCCESS,
    this.title = '',
    this.description = '',
    this.labelCancel = 'Cancelar',
    this.labelAction = 'Hecho',
    this.pathImageDialog = '',
    this.imageType = TypeImageAsset.IMAGE,
    required this.functionOk,
    required this.functionCancel,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    var funcOk = functionOk ?? (){};
    var funcCancel = functionCancel ?? (){};

    return Dialog(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: AppEdgeInsets.all(AppMargin.m24),
        width: MediaQuery.of(context).size.width / 1.5,
        decoration: BoxDecoration(
          color: ColorManager.blueGrey,
          borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                offset: const Offset(12, 26),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.1)),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: getRegularStyle(color: ColorManager.primary, fontWeight: FontWeight.bold, fontsize: AppSize.s18),),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.cancel, color: ColorManager.primaryLight),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppPadding.p12, AppPadding.p20, AppPadding.p12, AppPadding.p12),
              child: imageType == TypeImageAsset.IMAGE ? Image(
                  height: AppSize.s120,
                  image: AssetImage(getImageByType(typeDialog, pathImageDialog)),
                  fit: BoxFit.fitWidth,
                ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                    effects: const [
                      ShakeEffect(delay: Duration(milliseconds: 1000), duration: Duration(milliseconds: 3000), hz: 2, offset: Offset(10, 0), curve: Curves.easeInOutCubic),
                    ]
                ) : SvgPicture.asset(
                  pathImageDialog,
                  height: AppSize.s120,
                  width: AppSize.s120,
                  fit: BoxFit.fitWidth,
                ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                    effects: const [
                      ShakeEffect(delay: Duration(milliseconds: 1000), duration: Duration(milliseconds: 3000), hz: 2, offset: Offset(10, 0), curve: Curves.easeInOutCubic),
                    ]
                ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppPadding.p10, 0, AppPadding.p10, 0),
              child: Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                functionCancel != null && labelCancel.isNotEmpty ? 
                SmallRoundedButton(
                  color: ColorManager.grayDisabled, 
                  text: labelCancel, 
                  press: () { funcCancel(); },
                ) : Container(),
                const SizedBox(width: 8),
                SmallRoundedButton(
                  color: getColorByType(typeDialog), 
                  text: labelAction, 
                  press: () { funcOk(); },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Color getColorByType(AppDialogType dialogType){
  switch (dialogType) {
    case AppDialogType.SUCCESS:
      return ColorManager.success;
    case AppDialogType.WARNING:
      return ColorManager.warning;
    case AppDialogType.ERROR:
      return ColorManager.error;
    default: return ColorManager.primary;
  }
}


String getImageByType(AppDialogType dialogType, String pathIcon){
  var customIconPath = ImageAssets.iconAlert;
  if (pathIcon.isNotEmpty) {
    customIconPath = pathIcon;
  } 
  switch (dialogType) {
    case AppDialogType.SUCCESS:
      return ImageAssets.iconSuccess;
    case AppDialogType.WARNING:
      return ImageAssets.iconAlert;
    case AppDialogType.ERROR:
      return ImageAssets.iconError;
    case AppDialogType.CUSTOM:
      return customIconPath;
    default: 
      return ImageAssets.iconSuccess;
  }
}
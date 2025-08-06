import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/font_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/enum_widgets.dart';

class AppStatusDialog extends StatelessWidget {
  final AppDialogType typeDialog;
  final String title;
  final String description;
  final String labelCancel;
  final String labelAction;
  final Function? functionOk;
  final Function? functionCancel;
  final String pathImageDialog;
  final TypeImageAsset imageType;
  final bool verticalButtons;
  final bool showCloseButton;
  final bool cancelBelowAction;

  const AppStatusDialog(
      {this.typeDialog = AppDialogType.SUCCESS,
      this.title = '',
      this.description = '',
      this.labelCancel = 'Cancelar',
      this.labelAction = 'Hecho',
      this.pathImageDialog = '',
      this.imageType = TypeImageAsset.IMAGE,
      required this.functionOk,
      this.functionCancel,
      this.verticalButtons = false,
      this.showCloseButton = true,
      this.cancelBelowAction = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    var funcOk = functionOk ?? () {};
    var funcCancel = functionCancel ?? () {};

    return Dialog(
      elevation: 2,
      insetPadding: const EdgeInsets.all(AppPadding.p20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: AppEdgeInsets.all(AppMargin.m24),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: ColorManager.background,
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
            Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                if (showCloseButton)
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.cancel,
                          color: ColorManager.grayBackground),
                    ),
                  ),
              ],
            ),
            Divider(color: getColorByType(typeDialog), thickness: 2)
                .withPadding(vertical: AppPadding.p8),
            if (pathImageDialog.isNotEmpty)
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppPadding.p20),
                child: imageType == TypeImageAsset.IMAGE
                    ? Image(
                        height: AppSize.s120,
                        image: AssetImage(
                            getImageByType(typeDialog, pathImageDialog)),
                        fit: BoxFit.fitWidth,
                      )
                    : SvgPicture.asset(
                        pathImageDialog,
                        height: AppSize.s120,
                        width: AppSize.s120,
                        fit: BoxFit.fitWidth,
                      ),
              ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppPadding.p10, 0, AppPadding.p10, 0),
              child: Text(description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(
              height: 15,
            ),
            if (verticalButtons) ...[
              if (functionCancel != null && labelCancel.isNotEmpty)
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: ColorManager.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.s12),
                      ),
                      foregroundColor: ColorManager.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize: const Size(double.infinity, 48.0),
                    ),
                    onPressed: () {
                      funcCancel();
                    },
                    child: Text(labelCancel,
                        style: getRegularStyle(
                            color: ColorManager.primary,
                            fontsize: FontSize.s16))),
              const SizedBox(height: 12),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: getRegularStyle(color: ColorManager.white),
                    backgroundColor: getColorByType(typeDialog),
                    foregroundColor: ColorManager.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.s12)),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    funcOk();
                  },
                  child: Text(labelAction,
                      style: getRegularStyle(
                          color: ColorManager.white, fontsize: FontSize.s16))),
            ] else if (cancelBelowAction) ...[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: getRegularStyle(color: ColorManager.white),
                    backgroundColor: getColorByType(typeDialog),
                    foregroundColor: ColorManager.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.s12)),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    funcOk();
                  },
                  child: Text(labelAction,
                      style: getRegularStyle(
                          color: ColorManager.white, fontsize: FontSize.s16))),
              const SizedBox(height: 12),
              functionCancel != null && labelCancel.isNotEmpty
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: ColorManager.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.s12),
                          ),
                          foregroundColor: ColorManager.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          minimumSize: const Size(double.infinity, 48.0)),
                      onPressed: () {
                        funcCancel();
                      },
                      child: Text(labelCancel,
                          style: getRegularStyle(
                              color: ColorManager.primary,
                              fontsize: FontSize.s16)))
                  : const SizedBox.shrink(),
            ] else
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  functionCancel != null && labelCancel.isNotEmpty
                      ? Flexible(
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: ColorManager.primary, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppSize.s12),
                                  ),
                                  foregroundColor: ColorManager.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0)),
                              onPressed: () {
                                funcCancel();
                              },
                              child: Text(labelCancel,
                                  style: getRegularStyle(
                                      color: ColorManager.primary,
                                      fontsize: FontSize.s16))))
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Flexible(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle:
                                getRegularStyle(color: ColorManager.white),
                            backgroundColor: getColorByType(typeDialog),
                            foregroundColor: ColorManager.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSize.s12)),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: () {
                            funcOk();
                          },
                          child: Text(labelAction,
                              style: getRegularStyle(
                                  color: ColorManager.white,
                                  fontsize: FontSize.s16))))
                ],
              )
          ],
        ),
      ),
    );
  }
}

Color getColorByType(AppDialogType dialogType) {
  switch (dialogType) {
    case AppDialogType.SUCCESS:
      return ColorManager.success;
    case AppDialogType.WARNING:
      return ColorManager.warning;
    case AppDialogType.ERROR:
      return ColorManager.error;
    default:
      return ColorManager.primary;
  }
}

String getImageByType(AppDialogType dialogType, String pathIcon) {
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

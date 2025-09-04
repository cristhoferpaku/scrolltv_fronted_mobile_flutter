import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/assets_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/style_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/buttons/elevated_button.dart';
import 'package:scrolltv_frontend_mobile_flutter/widgets/enum_widgets.dart';

class AppDialog extends StatelessWidget {
  final AppDialogType typeDialog;
  final String title;
  final String description;
  final String labelCancel;
  final String labelAction;
  final Function? functionOk;
  final Function? functionCancel;
  final String pathImageDialog;
  final TypeImageAsset imageType;

  const AppDialog(
      {this.typeDialog = AppDialogType.SUCCESS,
      this.title = '',
      this.description = '',
      this.labelCancel = 'Cancelar',
      this.labelAction = 'Hecho',
      this.pathImageDialog = '',
      this.imageType = TypeImageAsset.IMAGE,
      required this.functionOk,
      required this.functionCancel,
      super.key});

  @override
  Widget build(BuildContext context) {
    var funcOk = functionOk ?? () {};
    var funcCancel = functionCancel ?? () {};

    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: AppEdgeInsets.all(AppMargin.m20),
          width: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(border: Border.all(color: getColorByType(typeDialog), width: 2), color: ColorManager.neutro800, borderRadius: BorderRadius.circular(15.0), boxShadow: [
            BoxShadow(offset: const Offset(12, 26), blurRadius: 50, spreadRadius: 0, color: Colors.grey.withValues(alpha: .1)),
          ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisAlignment: MainAxisAlignment.end,
              //   children: [
              //     Expanded(
              //       child: Text(
              //         title,
              //         style: getRegularStyle(color: ColorManager.primary, fontWeight: FontWeight.bold, fontsize: AppSize.s18),
              //       ),
              //     ),
              //     InkWell(
              //       onTap: () => Navigator.pop(context),
              //       child: const Icon(Icons.cancel, color: ColorManager.primaryLight),
              //     )
              //   ],
              // ),
              Container(
                padding: const EdgeInsets.fromLTRB(AppPadding.p12, AppPadding.p20, AppPadding.p12, AppPadding.p12),
                child: imageType == TypeImageAsset.IMAGE
                    ? Image(
                        height: AppSize.s120,
                        image: AssetImage(getImageByType(typeDialog, pathImageDialog)),
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
              Text(
                title,
                style: getBoldStyle(color: ColorManager.white, fontWeight: FontWeight.bold, fontsize: AppSize.s24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(AppPadding.p10, 0, AppPadding.p10, 0),
                child: Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: AppSize.s16)),
              ),
              const SizedBox(height: 15),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButtonApp(
                    colorButton: getColorByType(typeDialog),
                    colorBorder: getColorByType(typeDialog),
                    textButton: labelAction,
                    press: () {
                      funcOk();
                    },
                    isExpanded: true,
                    hasShadow: false,
                  ),
                  const SizedBox(height: 8),
                  functionCancel != null && labelCancel.isNotEmpty
                      ? ElevatedButtonApp(
                          colorButton: ColorManager.neutro700,
                          colorBorder: getColorByType(typeDialog),
                          widthBorder: 2,
                          textButton: labelCancel,
                          press: () {
                            funcCancel();
                          },
                          isExpanded: true,
                          hasShadow: false,
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Color getColorByType(AppDialogType dialogType) {
  switch (dialogType) {
    case AppDialogType.SUCCESS:
      return ColorManager.primary;
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

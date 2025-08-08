import 'package:flutter/material.dart';
import 'package:scrolltv_frontend_mobile_flutter/app/extensions_widgets.dart';
import 'package:scrolltv_frontend_mobile_flutter/modules/app/ui/constants/colors/color_manager.dart';
import 'package:scrolltv_frontend_mobile_flutter/util/values_manager.dart';

// ignore: must_be_immutable
class TextFormFieldIconSmall extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onEditingComplete;
  bool isPassword;
  TextEditingController? controller;
  Function? validatorFunction;
  String valueData;
  IconData? leftIcon;
  IconData? rightIcon;
  String? label;
  String? hint;
  String? labelText;
  bool? enabled;
  Color? background;
  Color borderColor;
  int? maxLines;
  bool readOnly;

  TextFormFieldIconSmall({
    super.key,
    this.background = ColorManager.surfaceContainer,
    this.borderColor = ColorManager.outline,
    required this.onChanged,
    this.isPassword = false,
    this.leftIcon,
    this.labelText,
    this.label,
    this.hint,
    required this.controller,
    required this.validatorFunction,
    this.valueData = '',
    this.enabled,
    this.maxLines = 1,
    this.readOnly = false,
    this.onEditingComplete,
    this.rightIcon,
  });

  @override
  State<TextFormFieldIconSmall> createState() => _TextFormFieldIconSmallState();
}

class _TextFormFieldIconSmallState extends State<TextFormFieldIconSmall> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null)
        Text(
          widget.label ?? "",
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: ColorManager.white),
        ).withPadding(bottom: AppPadding.p8),
      TextFormField(
        onEditingComplete: widget.onEditingComplete,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        obscureText: widget.isPassword && !_isPasswordVisible,
        controller: widget.controller,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: ColorManager.white),
        cursorColor: ColorManager.primary,
        onSaved: (value) {
          widget.valueData = value!;
        },
        enabled: widget.enabled ?? true,
        validator: widget.validatorFunction != null
            ? (value) => widget.validatorFunction!(value)
            : null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
              left: widget.leftIcon != null ? 44 : 16,
              top: 12,
              bottom: 12,
              right: 8),
          hintText: widget.hint,
          labelText: widget.labelText,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: ColorManager.neutro300),
          filled: true,
          fillColor:
              widget.readOnly ? ColorManager.disabled : widget.background,
          prefixIcon: widget.leftIcon != null
              ? Icon(widget.leftIcon, color: ColorManager.secondary)
              : null,
          suffixIcon: widget.rightIcon != null
              ? IconButton(
                  icon: Icon(
                      widget.isPassword
                          ? _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility
                          : widget.rightIcon,
                      color: ColorManager.secondary),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s12)),
            borderSide: BorderSide(
              color: widget.borderColor,
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s12)),
            borderSide: BorderSide(
              color: ColorManager.primary,
              width: 1,
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSize.s12)),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
        ),
      )
    ]);
  }
}

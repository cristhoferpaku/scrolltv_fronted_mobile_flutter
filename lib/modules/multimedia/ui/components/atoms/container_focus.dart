import 'package:flutter/material.dart';

class ContainerFocus extends StatefulWidget {
  const ContainerFocus({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
    this.focusNode,
  });

  final FocusNode? focusNode;
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<ContainerFocus> createState() => _ContainerFocusState();
}

class _ContainerFocusState extends State<ContainerFocus> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.focusNode?.hasFocus ?? false, // true si quieres que al iniciar tenga foco
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: InkWell(
        autofocus: widget.focusNode?.hasFocus ?? false,
        canRequestFocus: true,
        focusNode: widget.focusNode,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isFocused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: _isFocused ? Border.all(color: Colors.blueAccent, width: 2) : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

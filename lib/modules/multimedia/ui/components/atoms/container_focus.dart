import 'package:flutter/material.dart';

class ContainerFocus extends StatefulWidget {
  const ContainerFocus({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12,
  });

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
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: _isFocused ? Border.all(color: Colors.blueAccent, width: 2) : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Baseline(
          baseline: 16.r,
          baselineType: TextBaseline.alphabetic,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16.r,
                ),
          ),
        ),
        Baseline(
          baseline: 16.r, // 🔑 mismo valor para alinear ambos abajo
          baselineType: TextBaseline.alphabetic,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.r,
                ),
          ),
        ),
      ],
    );
  }
}

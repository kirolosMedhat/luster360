import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';

class LusterToolbar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const LusterToolbar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        color: LusterColors.panel,
        border: Border(
          top: BorderSide(color: LusterColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}

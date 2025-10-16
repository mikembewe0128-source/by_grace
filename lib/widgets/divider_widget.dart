import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  final double height;
  final double thickness;
  final Color color;
  final double indent;
  final double endIndent;

  const DividerWidget({
    super.key,
    this.height = 20,
    this.thickness = 1,
    this.color = Colors.grey,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

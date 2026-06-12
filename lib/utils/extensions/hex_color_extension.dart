import 'package:flutter/material.dart';

extension HexColorExtension on String {
  Color toColor() {
    String hex = replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // agrega opacidad si falta
    return Color(int.parse(hex, radix: 16));
  }
}

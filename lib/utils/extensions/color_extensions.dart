import 'package:flutter/material.dart';
import 'package:worklink_local/utils/logger.dart';

extension ColorExtensions on Color? {
  // Get the luminance of a color to know if is dark
  bool isDark() {
    if (this == null) {
      return false;
    }
    return this!.computeLuminance() < 0.5;
  }

  // Darken a color
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this!);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  // Lighten a color
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this!);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );

    return hslLight.toColor();
  }

  Color withOpacity(double opacity) {
    if (this == null) {
      return Colors.transparent;
    }
    return this!.withValues(alpha: opacity);
  }

  Color withTint(Color tint) {
    if (this == null) {
      return Colors.transparent;
    }
    return Color.fromARGB(
      this!.a.toInt(),
      (this!.r + tint.r) ~/ 2,
      (this!.g + tint.g) ~/ 2,
      (this!.b + tint.b) ~/ 2,
    );
  }
}

// Function to get the brightness of the color
String getColorBrightness(Color color) {
  // Calculate the brightness of the color
  double brightness = color.computeLuminance();
  logSuccess('Brightness: $brightness');

  // Check if the brightness is greater than 0.5
  if (brightness > 0.5) {
    return 'bright';

    // Check if the brightness is less than 0.15
  } else if (brightness < 0.15) {
    return 'dark';
  } else {
    return 'ok';
  }
}

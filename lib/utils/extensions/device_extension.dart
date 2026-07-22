import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool get isWeb => kIsWeb;

bool get isMobile => !isWeb && (Platform.isIOS || Platform.isAndroid);

bool get isDesktop =>
    !isWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

bool get isApple => !isWeb && (Platform.isIOS || Platform.isMacOS);

bool get isGoogle => !isWeb && (Platform.isAndroid || Platform.isFuchsia);

bool get isAndroid => !isWeb && Platform.isAndroid;

bool get isIos => !isWeb && Platform.isIOS;

bool get isMacOS => !isWeb && Platform.isMacOS;

bool get isLinux => !isWeb && Platform.isLinux;

bool get isWindows => !isWeb && Platform.isWindows;

String get operatingSystemName => Platform.operatingSystem;

String get operatingSystemVersion => Platform.operatingSystemVersion;

/// Whether the current window is in landscape orientation.
///
/// MediaQuery isn't available here (no BuildContext), so we infer
/// orientation from the window physical size divided by devicePixelRatio.
bool get isLanscape {
  try {
    final window = WidgetsBinding.instance.window;
    final physical = window.physicalSize;
    final dp = window.devicePixelRatio;
    final logicalSize = physical / dp;
    return logicalSize.width > logicalSize.height;
  } catch (_) {
    return false;
  }
}

// Function to set the orientation of the screen
void setDeviceOrientation(int orientation) {
  if (orientation == 0) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else if (orientation == 1) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else if (orientation == 2) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

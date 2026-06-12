import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

// Blue text
void logInfo(String msg) {
  if (!kDebugMode) dev.log('\x1B[34m$msg\x1B[0m');
}

// White text
void logImportant(String msg) {
  if (kDebugMode)  dev.log('\x1B[37m$msg\x1B[0m');
}

// Black text
void logSuperError(String msg) {
  if (kDebugMode)  dev.log('\x1B[30m$msg\x1B[0m');
}

// Green text
void logSuccess(String msg) {
  if (kDebugMode) dev.log('\x1B[32m$msg\x1B[0m');
}

// Yellow text
void logWarning(String msg) {
  if (kDebugMode) dev.log('\x1B[33m$msg\x1B[0m');
}

// Red text
void logError(String msg) {
  dev.log('\x1B[31m$msg\x1B[0m');
}

// Cyan text
void logDebug(String msg) {
  if (kDebugMode) dev.log('\x1B[36m$msg\x1B[0m');
}

// Magenta text
void logVerbose(String msg) {
  if (kDebugMode) dev.log('\x1B[35m$msg\x1B[0m');
}

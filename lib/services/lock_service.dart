import 'package:flutter/services.dart';

class LockService {
  static const MethodChannel _channel = MethodChannel('com.eskalasi.safeexam/lock');

  Future<bool> startLockTask() async {
    try {
      final bool result = await _channel.invokeMethod('startLockTask');
      return result;
    } on PlatformException catch (e) {
      print("Failed to start lock task: '${e.message}'.");
      return false;
    }
  }

  Future<bool> stopLockTask() async {
    try {
      final bool result = await _channel.invokeMethod('stopLockTask');
      return result;
    } on PlatformException catch (e) {
      print("Failed to stop lock task: '${e.message}'.");
      return false;
    }
  }

  Future<bool> disableGestureNavigation() async {
    try {
      final bool result = await _channel.invokeMethod('disableGestureNavigation');
      return result;
    } on PlatformException catch (e) {
      print("Failed to disable gesture navigation: '${e.message}'.");
      return false;
    }
  }

  Future<bool> enableGestureNavigation() async {
    try {
      final bool result = await _channel.invokeMethod('enableGestureNavigation');
      return result;
    } on PlatformException catch (e) {
      print("Failed to enable gesture navigation: '${e.message}'.");
      return false;
    }
  }

  Future<bool> isLockModeActive() async {
    try {
      final bool result = await _channel.invokeMethod('isLockTaskModeActive');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check lock mode status: '${e.message}'.");
      return false;
    }
  }

  Future<bool> disablePictureInPicture() async {
    try {
      final bool result = await _channel.invokeMethod('disablePictureInPicture');
      return result;
    } on PlatformException catch (e) {
      print("Failed to disable PiP: '${e.message}'.");
      return false;
    }
  }

  Future<bool> disableSplitScreen() async {
    try {
      final bool result = await _channel.invokeMethod('disableSplitScreen');
      return result;
    } on PlatformException catch (e) {
      print("Failed to disable split screen: '${e.message}'.");
      return false;
    }
  }

  Future<bool> preventFloatingWindows() async {
    try {
      final bool result = await _channel.invokeMethod('preventFloatingWindows');
      return result;
    } on PlatformException catch (e) {
      print("Failed to prevent floating windows: '${e.message}'.");
      return false;
    }
  }
}

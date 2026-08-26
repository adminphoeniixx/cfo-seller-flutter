import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A stable, human-readable device identifier sent as `device_name` on
/// login/register/refresh. Sanctum keys a token to this name — signing in
/// again with the same name replaces that device's token rather than
/// piling up a new one every launch, so this must be generated once and
/// persisted, not recomputed per call.
class DeviceNameProvider {
  static const _key = 'seller_device_name';
  final FlutterSecureStorage _storage;

  DeviceNameProvider({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String> get() async {
    final existing = await _storage.read(key: _key);
    if (existing != null) return existing;

    final generated = _generate();
    await _storage.write(key: _key, value: generated);
    return generated;
  }

  String _generate() {
    final platform = Platform.isIOS
        ? 'iOS'
        : Platform.isAndroid
        ? 'Android'
        : Platform.isMacOS
        ? 'macOS'
        : 'device';
    final suffix = Random.secure()
        .nextInt(0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0');
    return '$platform-$suffix';
  }
}

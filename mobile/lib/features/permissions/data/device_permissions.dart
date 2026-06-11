import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

final devicePermissionsProvider = Provider<DevicePermissionsService>((ref) {
  return const PlatformDevicePermissionsService();
});

class PermissionSnapshot {
  const PermissionSnapshot({
    required this.notificationsAllowed,
    required this.usageAccessAllowed,
    required this.overlayAllowed,
    required this.isAndroid,
  });

  final bool notificationsAllowed;
  final bool usageAccessAllowed;
  final bool overlayAllowed;
  final bool isAndroid;

  bool get requiredPermissionsReady {
    if (!isAndroid) {
      return true;
    }

    return notificationsAllowed && usageAccessAllowed && overlayAllowed;
  }
}

abstract class DevicePermissionsService {
  Future<PermissionSnapshot> load();

  Future<void> requestNotifications();

  Future<void> openUsageAccessSettings();

  Future<void> openOverlaySettings();
}

class PlatformDevicePermissionsService implements DevicePermissionsService {
  const PlatformDevicePermissionsService();

  static const MethodChannel _channel = MethodChannel('focus/permissions');

  @override
  Future<PermissionSnapshot> load() async {
    final notificationsAllowed = await _areNotificationsAllowed();

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return PermissionSnapshot(
        notificationsAllowed: notificationsAllowed,
        usageAccessAllowed: true,
        overlayAllowed: true,
        isAndroid: false,
      );
    }

    return PermissionSnapshot(
      notificationsAllowed: notificationsAllowed,
      usageAccessAllowed: await _invokeBool('hasUsageAccess'),
      overlayAllowed: await _invokeBool('canDrawOverlays'),
      isAndroid: true,
    );
  }

  @override
  Future<void> requestNotifications() async {
    await ph.Permission.notification.request();
  }

  @override
  Future<void> openUsageAccessSettings() async {
    await _invokeVoid('openUsageAccessSettings');
  }

  @override
  Future<void> openOverlaySettings() async {
    await _invokeVoid('openOverlaySettings');
  }

  Future<bool> _areNotificationsAllowed() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  Future<bool> _invokeBool(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> _invokeVoid(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      await ph.openAppSettings();
    } on PlatformException {
      await ph.openAppSettings();
    }
  }
}

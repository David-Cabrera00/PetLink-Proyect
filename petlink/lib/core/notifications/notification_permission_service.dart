import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  const NotificationPermissionService._();

  static Future<bool> request() async {
    final status = await Permission.notification.request();
    return status.isGranted || status.isLimited;
  }
}

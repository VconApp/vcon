//notification_total.dart
import 'package:flutter/foundation.dart';

class NotificationTotal {
  static final NotificationTotal _instance = NotificationTotal._internal();

  factory NotificationTotal() {
    return _instance;
  }

  NotificationTotal._internal();

  int _totalUnreadCount = 0;
  final ValueNotifier<int> totalUnreadNotifier = ValueNotifier(0);

  int get totalUnreadCount => _totalUnreadCount;

  set totalUnreadCount(int value) {
    _totalUnreadCount = value;
    totalUnreadNotifier.value = value;
  }
}

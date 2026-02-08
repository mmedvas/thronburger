import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initialize() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // v20 API uses named parameters
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Request Android permissions (Android 13+)
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showOrderStatusNotification(Order order) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'order_updates',
          'Order Updates',
          channelDescription: 'Notifications for order status changes',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    String title = 'Order #${order.orderNumber} Update';
    String body = '';

    switch (order.status) {
      case OrderStatus.preparing:
        body = 'Your order is being prepared!';
        break;
      case OrderStatus.ready:
        body = 'Your order is ready for pickup/delivery!';
        break;
      case OrderStatus.completed:
        body = 'Order completed. Enjoy your meal!';
        break;
      case OrderStatus.cancelled:
        body = 'Your order has been cancelled.';
        break;
      default:
        return; // Don't notify for pending or unknown
    }

    // v20 API uses named parameters
    await _notificationsPlugin.show(
      id: order.hashCode,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}

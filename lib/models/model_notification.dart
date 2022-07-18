import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationAction { alert, created, updated }

NotificationAction exportType(String type) {
  switch (type) {
    case "create_post_listar":
      return NotificationAction.created;
    case "update_post_listar":
      return NotificationAction.updated;
    default:
      return NotificationAction.alert;
  }
}

class NotificationModel {
  final NotificationAction action;
  final String title;
  final int id;

  NotificationModel({
    required this.action,
    required this.title,
    required this.id,
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      action: exportType(message.data['action'] ?? 'Unknown'),
      title: message.data['title'] ?? 'Unknown',
      id: int.tryParse(message.data['id'].toString()) ?? 0,
    );
  }
}

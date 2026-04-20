import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Basic_Modules/notification/notification_api.dart';

class NotificationController extends ChangeNotifier {
  NotificationApi provider = NotificationApi();

  bool isLoading = false;
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String notificationId = '';

  List<NotificationModel> notificationList = [];

  Future<void> getNotifications(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.notificationsDetails();
      final parsed = json.decode(value.toString());

      setLoader(false);

      if (parsed["success"] == true) {
        notificationList.clear();

        if (parsed['data'] != null &&
            parsed['data']['notifications'] != null &&
            parsed['data']['notifications'] is List) {
          for (var data in parsed['data']['notifications']) {
            // 👇 Store id in single string variable
            notificationId = data['id'].toString();

            notificationList.add(
              NotificationModel(
                id: notificationId,
                title: data['log_name'].toString(),
                message: data['description'].toString(),
                event: data['event'].toString(),
                isRead: data['is_read_by_user'] == 1,
                createdAt: data['created_at'].toString(),
              ),
            );
          }
        }

        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['email', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  clearOnDismiss(int id) {
    notificationList.removeAt(id);
    notifyListeners();
  }

  Future<void> clearNotificationDetails(BuildContext context) async {
    setLoader(true);
    if (!context.mounted) return;
    setLoader(false);

    try {
      final value = await provider.clearNotificationDetails();
      final parsed = json.decode(value.toString());

      setLoader(false);

      if (parsed["success"] == true) {
        getNotifications(context);
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['email', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> clearDetails(BuildContext context, String id) async {
    setLoader(true);

    try {
      final value = await provider.clearDetails({"id": id});

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
        getNotifications(context);
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['id', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String event;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.event,
    required this.isRead,
    required this.createdAt,
  });
}

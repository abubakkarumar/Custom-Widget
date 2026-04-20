import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/support_api.dart';

class SupportController extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final supportFormKey = GlobalKey<FormState>();

  // ------------------------ Loader ------------------------
  bool isLoading = false;
  bool isSuccess = false;

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  setTicketUploadImage(XFile value) {
    ticketUploadImage = value;
    notifyListeners();
  }

  XFile? ticketUploadImage;
  XFile? file;

  String ticketImageURL = "";

  resetData() {
    titleController.clear();
    messageController.clear();
    ticketUploadImage = file;
    ticketImageURL = "";

    notifyListeners();
  }

  SupportAPI provider = SupportAPI();

  List<TicketModel> ticketList = [];

  Future<void> getSupportTickets(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getSupportChatList();
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        ticketList.clear();

        if (parsed["data"].toString() != "[]") {
          for (var data in parsed["data"]) {
            ticketList.add(
              TicketModel(
                id: data["id"],
                ticketId: data["ticket_id"].toString(),
                subject: data["subject"].toString(),
                message: data["message"].toString(),
                status: data["status"].toString(),
                createdAt: data["created_at"].toString(),
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

  Future<void> doCreateSupportTicket(BuildContext context) async {
    setLoader(true);

    dio.FormData formData;

    if (ticketUploadImage != null) {
      formData = dio.FormData.fromMap({
        "title": titleController.text,
        "message": messageController.text,
        "support_image": await dio.MultipartFile.fromFile(
          ticketUploadImage!.path,
          filename: 'ticket_image.png',
        ),
      });
    } else {
      formData = dio.FormData.fromMap({
        "title": titleController.text,
        "message": messageController.text,
      });
    }
    await provider
        .doCreateSupportTicket(formData: formData)
        .then((value) async {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (!context.mounted) return;
          if (parsed['success'] == true) {
            isSuccess = true;
            resetData();
            getSupportTickets(context);
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
              errorKeys: ['title', 'message', 'error'],
            );
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  List<TicketChatModel> chatList = [];

  ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> getSupportChat(BuildContext context, String ticketId) async {
    setLoader(true);
    await provider
        .getSupportChat(ticketId: ticketId)
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          setLoader(false);
          if (!context.mounted) return;
          if (parsed["success"] == true) {
            chatList.clear();

            if (parsed['data']['chats'].toString() != "[]") {
              for (var data in parsed['data']['chats']) {
                chatList.add(
                  TicketChatModel(
                    id: data["id"],
                    ticketId: data["ticket_id"].toString(),
                    message: data["message"] ?? '',
                    replyMessage: data["reply_message"] ?? '',
                    imageUrl: data["image_url"].toString(),
                    isReadByUser: data["is_read_by_user"],
                    isReadByAdmin: data["is_read_by_admin"],
                    createdAt: data["created_at"].toString(),
                  ),
                );
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                scrollToBottom();
              });
              ticketImageURL = parsed['data']['ticket']['support_image']
                  .toString();

              // ticketStatus = parsed['data']['ticket']['status'];
              // ticketImageURL =
              //     (ticketImage != null && ticketImage.toString().isNotEmpty)
              //     ? "${AppServices.baseURLForImage}$ticketImage"
              //     : "";

              notifyListeners();
            }
          } else {
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: ['error'],
            );
          }
        })
        .catchError((e) {
          isSuccess = false;
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  List<SupportChatList> supportChatLists = [];

  Future<void> doSendMessage(
    BuildContext context,
    String ticketId,
    String message,
  ) async {
    setLoader(true);

    try {
      final value = await provider.doSendMessage({
        "ticket_id": ticketId,
        "message": message,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        messageController.clear();
        supportChatLists.clear();
        if (parsed['data'].toString() != "[]") {
          for (var data in parsed['data']) {
            supportChatLists.add(
              SupportChatList(
                createdAt: data['created_at'].toString(),
                id: data['id'].toString(),
                message: data['message'].toString(),
                replyMessage: data['reply_message'].toString(),
                ticketId: data['ticket_id'].toString(),
              ),
            );
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            scrollToBottom();
          });

          notifyListeners();
        }
      } else {
        isSuccess = false;
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['message', 'ticket_id', 'error'],
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

class TicketModel {
  final int? id;
  final String? ticketId;
  final String? subject;
  final String? message;
  final String? status;
  final String? createdAt;

  TicketModel({
    this.id,
    this.ticketId,
    this.subject,
    this.message,
    this.status,
    this.createdAt,
  });
}

class TicketChatModel {
  final int? id;
  final String? ticketId;
  final String? message;
  final String? replyMessage;
  final String? imageUrl;
  final int? isReadByUser;
  final int? isReadByAdmin;
  final String? createdAt;

  TicketChatModel({
    this.id,
    this.ticketId,
    this.message,
    this.replyMessage,
    this.imageUrl,
    this.isReadByUser,
    this.isReadByAdmin,
    this.createdAt,
  });
}

class SupportChatList {
  final String? id, ticketId, message, replyMessage, createdAt;

  SupportChatList({
    this.id,
    this.ticketId,
    this.message,
    this.replyMessage,
    this.createdAt,
  });
}

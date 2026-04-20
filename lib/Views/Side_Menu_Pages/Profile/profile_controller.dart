// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'profile_api.dart';

class ProfileController extends ChangeNotifier {
  ProfileAPI profileApi = ProfileAPI();

  String profileName = "";
  String profileUid = "";
  bool isVerified = false;

  AutovalidateMode nickNameAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode bioAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode dateOfBirthAutoValidate = AutovalidateMode.disabled;

  enableAutoValidate() {
    nickNameAutoValidate = AutovalidateMode.onUserInteraction;
    bioAutoValidate = AutovalidateMode.onUserInteraction;
    dateOfBirthAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  diableAutoValidate() {
    nickNameAutoValidate = AutovalidateMode.disabled;
    bioAutoValidate = AutovalidateMode.disabled;
    dateOfBirthAutoValidate = AutovalidateMode.disabled;
  }

  // ------------------------ Text Controllers ------------------------

  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // ------------------------ Focus Nodes ------------------------

  final FocusNode nickNameFocusNode = FocusNode();

  final FocusNode bioFocusNode = FocusNode();

  // ------------------------ Validation Modes ------------------------

  AutovalidateMode bioValidation = AutovalidateMode.onUserInteraction;
  AutovalidateMode dateOfBirthValidation = AutovalidateMode.onUserInteraction;

  // ------------------------ Profile State ------------------------
  bool isLoading = false;
  String userName = AppStorage.getUserName() ?? '';
  String userEmail = AppStorage.getUserEmail() ?? '';
  String userBio = AppStorage.getBio() ?? '';
  String profileImageUrl = AppStorage.getProfileImage() ?? '';
  //String phoneNumber = AppStorage.getPhoneNumber() ?? '';
  String emailDetails = '';
  String userDetails = '';
  String nickName = '';

  // ------------------------ Profile Picture ------------------------
  XFile? profilePictureFile;
  XFile? documentFile;
  void setProfilePicture(XFile file) {
    profilePictureFile = file;
    notifyListeners();
  }

  // ------------------------ Loader ------------------------
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ------------------------ Date Picker ------------------------
  DateTime selectedDate = DateTime.now();

  // ------------------------ Load Initial Data ------------------------
  void loadInitialData() {
    userName = AppStorage.getUserName() ?? '';
    userEmail = AppStorage.getUserEmail() ?? '';
    userBio = AppStorage.getBio() ?? '';
    profileImageUrl = AppStorage.getProfileImage() ?? '';
    //phoneNumber = AppStorage.getPhoneNumber() ?? '';
    notifyListeners();
  }

  // ------------------------ Update Profile Details ------------------------
  Future<void> doProfile(BuildContext context) async {
    setLoader(true);

    Map<String, dynamic> data = {
      "nick_name": nickNameController.text.trim(),
      "dob": dateOfBirthController.text.trim(),
      "bio": bioController.text.trim(),
    };

    try {
      final response = await profileApi.doUpdateProfileDetails(data);
      final parsed = json.decode(response.toString());

      debugPrint("🔁 Profile Update Response: $parsed");

      if (parsed['success'] == true) {
        setLoader(false);
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['nick_name', 'dob', 'bio', 'error'],
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

  // ------------------------ Update Profile Picture ------------------------
  Future<void> updateProfilePicture(BuildContext context) async {
    if (profilePictureFile == null) return;

    setLoader(true);

    try {
      final formData = dio.FormData.fromMap({
        "profile_image": await dio.MultipartFile.fromFile(
          profilePictureFile!.path,
          filename: 'profile_image.png',
        ),
      });

      final response = await profileApi.doUpdateProfileImage(formData);
      final parsed = json.decode(response.toString());

      debugPrint("📸 Profile Picture Update Response: $parsed");

      if (parsed['success'] == true) {
        setLoader(false);
        profileImageUrl = parsed['data']['profile_image']?.toString() ?? '';
        AppStorage.storeProfileImage(profileImageUrl);
        AppStorage.storeUserName(parsed['data']['user_name']?.toString() ?? '');
        notifyListeners();

        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['profile_image', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  // ------------------------ Get Profile ------------------------
  Future<void> getProfile(BuildContext context) async {
    setLoader(true);

    try {
      final response = await profileApi.showProfileDetails();
      final parsed = json.decode(response.toString());

      debugPrint("🔍 PROFILE API RESPONSE: $parsed");

      if (parsed['success'] == true) {
        setLoader(false);
        final data = parsed['data'];

        await AppStorage.storeUserName(data['name'] ?? '');
        await AppStorage.storeUserEmail(data['email'] ?? '');
        await AppStorage.storeBio(data['bio'] ?? '');
        await AppStorage.storeUserNickName(data['nickname'] ?? '');

        await AppStorage.storeProfileImage(data['profile_image'] ?? '');

        userDetails = data['name'] ?? '';
        emailDetails = data['email'] ?? '';
        userBio = data['bio'] ?? '';
        nickNameController.text = data['nickname'] ?? '';

        profileImageUrl = data['profile_image'] ?? '';
        dateOfBirthController.text = data['dob'] ?? '';
        bioController.text = data['bio'] ?? '';

        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

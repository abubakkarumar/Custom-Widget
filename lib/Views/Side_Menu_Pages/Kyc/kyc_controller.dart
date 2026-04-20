import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'kyc_api.dart';

class KycController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Text Controllers
  // ---------------------------------------------------------------------------

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController documentTypeController = TextEditingController();
  final TextEditingController documentNumberController =
      TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  final GlobalKey<FormState> kycFormKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // Loader & Status
  // ---------------------------------------------------------------------------

  bool isLoading = false;
  bool isSuccess = false;

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Autovalidate Modes
  // ---------------------------------------------------------------------------

  AutovalidateMode firstNameAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode lastNameAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode countryAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode documentTypeAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode documentNumberAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode expiryDateAutoValidate = AutovalidateMode.disabled;

  void enableAutoValidate() {
    firstNameAutoValidate = AutovalidateMode.onUserInteraction;
    lastNameAutoValidate = AutovalidateMode.onUserInteraction;
    countryAutoValidate = AutovalidateMode.onUserInteraction;
    documentTypeAutoValidate = AutovalidateMode.onUserInteraction;
    documentNumberAutoValidate = AutovalidateMode.onUserInteraction;
    expiryDateAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  void diableAutoValidate() {
    firstNameAutoValidate = AutovalidateMode.disabled;
    lastNameAutoValidate = AutovalidateMode.disabled;
    countryAutoValidate = AutovalidateMode.disabled;
    documentTypeAutoValidate = AutovalidateMode.disabled;
    documentNumberAutoValidate = AutovalidateMode.disabled;
    expiryDateAutoValidate = AutovalidateMode.disabled;
  }

  // ---------------------------------------------------------------------------
  // Date & Selection
  // ---------------------------------------------------------------------------

  DateTime selectedExpiryDate = DateTime.now();
  CountryModel? selectedCountry;
  DocumentTypeModel? selectedDocument;

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  XFile? docFrontImage;
  XFile? docBackImage;

  String docFrontImageURL = "";
  String docBackImageURL = "";

  void setDocFrontImage(XFile value) {
    docFrontImage = value;
    notifyListeners();
  }

  void setDocBackImage(XFile value) {
    docBackImage = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  clearData(){
    countryList.clear();
    firstNameController.clear();
    lastNameController.clear();
    countryController.clear();
    documentTypeController.clear();
    documentNumberController.clear();
    expiryDateController.clear();
    docFrontImage = null;
    docBackImage = null;
    docFrontImageURL = "";
    docBackImageURL = "";
    selectedCountry = null;

  }
  void resetData() {
    countryList.clear();
    firstNameController.clear();
    lastNameController.clear();
    countryController.clear();
    documentTypeController.clear();
    documentNumberController.clear();
    expiryDateController.clear();
    docFrontImage = null;
    docBackImage = null;
    docFrontImageURL = "";
    docBackImageURL = "";
    selectedCountry = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Country
  // ---------------------------------------------------------------------------

  KycAPI provider = KycAPI();
  List<CountryModel> countryList = [];

  void selectCountry(CountryModel country) {
    selectedCountry = country;
    countryController.text = country.name;
    notifyListeners();
  }

  Future<void> getCountryList(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.getCountryList();
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        countryList.clear();

        if (parsed["data"].toString() != "[]") {
          for (var data in parsed["data"]) {
            countryList.add(
              CountryModel(
                id: data["id"],
                name: data["name"].toString(),
                code: data["code"].toString(),
                dialCode: data["dial_code"].toString(),
                phoneLimit:
                    int.tryParse(data["phone_number_limit"].toString()) ?? 0,
                imageUrl: data["image_url"].toString(),
              ),
            );
          }
        }
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

  // ---------------------------------------------------------------------------
  // Document Types
  // ---------------------------------------------------------------------------

  List<String> documentTypeList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.select,
      AppLocalizations.of(context)!.passport,
      AppLocalizations.of(context)!.drivingLicense,
      AppLocalizations.of(context)!.government_ID,
    ];
  }

  List<String> documentTypeListFormat = [
    "",
    "passport",
    "driving_license",
    "government_id",
  ];

  int docTypeIndex = 0;

  void setDocTypeDetails({required String type, required int id}) {
    docTypeIndex = id;
    documentTypeController.text = type;
    notifyListeners();
  }

  void selectDocument(DocumentTypeModel document) {
    selectedDocument = document;
    documentTypeController.text = document.name;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Get KYC Details
  // ---------------------------------------------------------------------------

  Future getKYCDetails(BuildContext context) async {
    setLoader(true);

    await provider
        .getKYCDetails()
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            print("before ${parsed["data"].runtimeType}" );
            if(parsed["data"].runtimeType == String){
              AppStorage.storeKYCStatus(3);
              resetData();
              return;
            }
            AppStorage.storeKYCStatus(parsed["data"]["status"] ?? 3);
            print("after");
            if (AppStorage.getKYCStatus() == 2) {
              resetData();
              return;
            }

            firstNameController.text = parsed["data"]["firstname"].toString();
            lastNameController.text = parsed["data"]["lastname"].toString();
            countryController.text = parsed["data"]["country"].toString();

            int index = documentTypeListFormat.indexOf(
              parsed["data"]["document_type"].toString(),
            );
            documentTypeController.text = documentTypeList(context)[index];

            documentNumberController.text = parsed["data"]["document_number"]
                .toString();

            expiryDateController.text = parsed["data"]["document_expiry_date"]
                .toString();

            docFrontImageURL = parsed["data"]["id_front_document"];
            docBackImageURL = parsed["data"]["id_back_document"];

            notifyListeners();
          } else {
            AppStorage.storeKYCStatus(3);
            resetData();
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: ['error'],
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

  // ---------------------------------------------------------------------------
  // Update KYC
  // ---------------------------------------------------------------------------

  Future<void> doUpdateKYCDetails(BuildContext context) async {
    setLoader(true);

    dio.FormData formData = dio.FormData.fromMap({
      "firstname": firstNameController.text,
      "lastname": lastNameController.text,
      "country": countryController.text,
      "document_type": documentTypeListFormat[docTypeIndex],
      "document_number": documentNumberController.text,
      "document_expiry_date": expiryDateController.text,
      "id_front_document": await dio.MultipartFile.fromFile(
        docFrontImage!.path,
        filename: 'doc_front.png',
      ),
      "id_back_document": await dio.MultipartFile.fromFile(
        docBackImage!.path,
        filename: 'doc_back.png',
      ),
    });

    await provider
        .doUpdateKYCDetails(formData: formData)
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          isSuccess = parsed['success'];

          if (parsed['success'] == true) {
            resetData();
            AppStorage.storeKYCStatus(1);
            AppToast.show(
              context: context,
              message: parsed['message'].toString(),
              type: ToastType.success,
            );
          } else {
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: [
                'firstname',
                'lastname',
                'country',
                'document_type',
                'document_number',
                'document_expiry_date',
                'id_front_document',
                'id_back_document',
                'error',
              ],
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
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

class DocumentTypeModel {
  final String id;
  final String name;

  DocumentTypeModel({required this.id, required this.name});
}

class CountryModel {
  final int id;
  final String name;
  final String code;
  final String dialCode;
  final int phoneLimit;
  final String imageUrl;

  CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.dialCode,
    required this.phoneLimit,
    required this.imageUrl,
  });
}

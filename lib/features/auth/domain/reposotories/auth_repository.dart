import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/module_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/screens/otp_controller.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepository({required this.sharedPreferences, required this.apiClient});

  @override
  bool isSharedPrefNotificationActive() {
    return sharedPreferences.getBool(AppConstants.notification) ?? true;
  }

  // userId

  @override
  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async {
    Response response = await apiClient.postData(
        AppConstants.registerUri, signUpBody.toJson(),
        handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body["token"]);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<Response> login({String? phone}) async {
    try {
      if (phone == null || phone.isEmpty) {
        throw Exception("Phone number cannot be empty");
      }

      Map<String, String> data = {
        "phone": phone,
        "user_type": "User",
      };

      Response response = await apiClient.postData(
        '/api/v1/auth/sendOtpuser',
        data,
        handleError: false,
      );
      print('Ganesh ${response.body} : ${response.statusCode}');

      if (response.body == null) {
        throw Exception("API returned null response");
      }

      if (response.statusCode != 200) {
        throw Exception("API Error: Status Code ${response.statusCode}");
      }

      final Map<String, dynamic> responseData = response.body;
      final controller = Get.put(OtpController());

      controller.correctOtp.value = "${responseData['otp'] ?? ''}";
      //controller.userExit.value = responseData['phone_exists'] ?? false;
      controller.numberWithCountryCode.value = phone;

      if (responseData.containsKey("user_id")) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_id", "${responseData["user_id"]}");
        await prefs.setString('otp', '${responseData['otp']}');
        await prefs.setString('token', '${responseData['token']}');
      }

      if (responseData['phone_exists'] == false) {
        Get.offAllNamed(RouteHelper.otpScreen);
      } else {
        Get.offAllNamed(RouteHelper.otpScreen);
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setBool(AppConstants.isOtpVerified, true);
        // Get.toNamed(RouteHelper.getInitialRoute());
      }

      return response;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send OTP. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  @override
  Future<ResponseModel> guestLogin() async {
    ResponseModel responseModel;
    String? deviceToken = await saveDeviceToken();
    Response response = await apiClient
        .postData(AppConstants.guestLoginUri, {'fcm_token': deviceToken});
    if (response.statusCode == 200) {
      await saveSharedPrefGuestId(response.body['guest_id'].toString());
      responseModel = ResponseModel(true, '${response.body['guest_id']}');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<Response> loginWithSocialMedia(SocialLogInBody socialLogInBody, int timeout) async {
    return await apiClient.postData(AppConstants.socialLoginUri, socialLogInBody.toJson(),timeout: timeout);
  }

  @override
  Future<Response> registerWithSocialMedia(
      SocialLogInBody socialLogInBody) async {
    return await apiClient.postData(
        AppConstants.socialRegisterUri, socialLogInBody.toJson());
  }

  @override
  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    if (sharedPreferences.getString(AppConstants.userAddress) != null) {
      AddressModel? addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
      apiClient.updateHeader(
        token,
        addressModel.zoneIds,
        addressModel.areaIds,
        sharedPreferences.getString(AppConstants.languageCode),
        ModuleHelper.getModule()?.id,
        addressModel.latitude,
        addressModel.longitude,
      );
    } else {
      apiClient.updateHeader(
          token,
          null,
          null,
          sharedPreferences.getString(AppConstants.languageCode),
          ModuleHelper.getModule()?.id,
          null,
          null);
    }
    return await sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  Future<Response> updateToken({String notificationDeviceToken = ''}) async {
    String? deviceToken;
    if (notificationDeviceToken.isEmpty) {
      if (GetPlatform.isIOS && !GetPlatform.isWeb) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
        NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          deviceToken = await saveDeviceToken();
        }
      } else {
        deviceToken = await saveDeviceToken();
      }
      if (!GetPlatform.isWeb) {
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
        FirebaseMessaging.instance.subscribeToTopic(
            'zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
      }
    }
    return await apiClient.postData(
        AppConstants.tokenUri,
        {
          "_method": "put",
          "cm_firebase_token": notificationDeviceToken.isNotEmpty
              ? notificationDeviceToken
              : deviceToken
        },
        handleError: false);
  }

  @override
  Future<String?> saveDeviceToken() async {
    String? deviceToken = '@';
    if (!GetPlatform.isWeb) {
      try {
        deviceToken = (await FirebaseMessaging.instance.getToken())!;
      } catch (_) {}
    }
    if (deviceToken != null) {
      if (kDebugMode) {
        print('--------Device Token---------- $deviceToken');
      }
    }
    return deviceToken;
  }

  @override
  bool isLoggedIn() {
    bool otpVerified =
        sharedPreferences.getBool(AppConstants.isOtpVerified) ?? false;
    return otpVerified;
  }

  @override
  Future<bool> saveSharedPrefGuestId(String id) async {
    return await sharedPreferences.setString(AppConstants.guestId, id);
  }

  @override
  String getSharedPrefGuestId() {
    return sharedPreferences.getString(AppConstants.guestId) ?? "";
  }

  @override
  Future<bool> clearSharedPrefGuestId() async {
    return await sharedPreferences.remove(AppConstants.guestId);
  }

  @override
  bool isGuestLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.guestId);
  }

  @override
  Future<bool> clearSharedAddress() async {
    await sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

  @override
  Future<bool> clearSharedData({bool removeToken = true}) async {
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      FirebaseMessaging.instance.unsubscribeFromTopic(
          'zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
      if (removeToken) {
        apiClient.postData(
            AppConstants.tokenUri, {"_method": "put", "cm_firebase_token": '@'},
            handleError: false);
      }
    }
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.guestId);
    sharedPreferences.setStringList(AppConstants.cartList, []);
    sharedPreferences.remove(AppConstants.isOtpVerified);
    sharedPreferences.remove("user_id");
    // sharedPreferences.remove(AppConstants.userAddress);
    apiClient.token = null;
    // apiClient.updateHeader(null, null, null, null, null, null, null);
    await guestLogin();
    if (sharedPreferences.getString(AppConstants.userAddress) != null) {
      AddressModel? addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
      apiClient.updateHeader(
        null,
        addressModel.zoneIds,
        null,
        sharedPreferences.getString(AppConstants.languageCode),
        null,
        addressModel.latitude,
        addressModel.longitude,
      );
    }
    return true;
  }

  @override
  Future<void> saveUserNumberAndPassword(
      String number, String password, String countryCode) async {
    try {
      await sharedPreferences.setString(AppConstants.userPassword, password);
      await sharedPreferences.setString(AppConstants.userNumber, number);
      await sharedPreferences.setString(
          AppConstants.userCountryCode, countryCode);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.userNumber) ?? "";
  }

  @override
  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.userCountryCode) ?? "";
  }

  @override
  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.userPassword) ?? "";
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return await sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  String getUserToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }

  @override
  Future<Response> updateZone() async {
    return await apiClient.getData(AppConstants.updateZoneUri);
  }

  @override
  Future<bool> saveGuestContactNumber(String number) async {
    return await sharedPreferences.setString(AppConstants.guestNumber, number);
  }

  @override
  String getGuestContactNumber() {
    return sharedPreferences.getString(AppConstants.guestNumber) ?? "";
  }

  ///Todo:
  @override
  Future<bool> saveDmTipIndex(String index) async {
    return await sharedPreferences.setString(AppConstants.dmTipIndex, index);
  }

  @override
  String getDmTipIndex() {
    return sharedPreferences.getString(AppConstants.dmTipIndex) ?? "";
  }

  @override
  Future<bool> saveEarningPoint(String point) async {
    return await sharedPreferences.setString(AppConstants.earnPoint, point);
  }

  @override
  String getEarningPint() {
    return sharedPreferences.getString(AppConstants.earnPoint) ?? "";
  }

  @override
  Future<void> setNotificationActive(bool isActive) async {
    if (isActive) {
      await updateToken();
    } else {
      if (!GetPlatform.isWeb) {
        await updateToken(notificationDeviceToken: '@');
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
        if (isLoggedIn()) {
          FirebaseMessaging.instance.unsubscribeFromTopic(
              'zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer');
        }
      }
    }
    sharedPreferences.setBool(AppConstants.notification, isActive);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}

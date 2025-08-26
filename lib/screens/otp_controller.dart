import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';

class OtpController extends GetxController {
  final int otpCodeLength = 4;
  final textEditingController = TextEditingController();

  RxBool userExit = false.obs;
  var numberWithCountryCode = ''.obs;
  RxString countryCode = ''.obs;
  RxString token = ''.obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState>? get formKeyLogin => formKey;

  ResponseModel? _status;
  ResponseModel? get statusValue => _status;
  set status(ResponseModel? value) => _status = value;

  AuthController? _auth;
  AuthController? get auth => _auth;
  set authController(AuthController? value) => _auth = value;

  var otpCode = ''.obs;
  RxString correctOtp = ''.obs;

  var isLoadingButton = false.obs;
  var enableButton = false.obs;
  var seconds = 30.obs;

  Timer? _timer;
  RxBool valid = false.obs;
  var number = ''.obs;

  final RegExp intRegex = RegExp(r'^\d+$');

  @override
  void onInit() {
    super.onInit();
    // resetOtpState();
    startTimer();
  }

  void onOtpChanged(String code) {
    otpCode.value = code;
    final isValid = code.length == otpCodeLength && intRegex.hasMatch(code);
    enableButton.value = isValid;
  }

  void onSubmitOtp(BuildContext context) {
    if (otpCode.value.length != otpCodeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please enter the OTP')),
      );
      return;
    }
    verifyOtpCode(context: context);
  }

  void verifyOtpCode({BuildContext? context}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authService = Get.find<AuthRepositoryInterface>();
    String? otp = prefs.getString('otp');
    token.value = prefs.getString('token') ?? '';
    correctOtp.value = otp ?? '';
    isLoadingButton.value = true;
    Future.delayed(const Duration(seconds: 1), () async {
      isLoadingButton.value = false;
      debugPrint(
          'Entered OTP: ${otpCode.value}, Correct OTP: ${correctOtp.value}');

      if (otpCode.value == correctOtp.value) {
        debugPrint("✅ OTP Verified: ${otpCode.value}");

        Get.snackbar(
          "Verification Successful",
          '✅ OTP Verified: ${otpCode.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.black,
        );

        await prefs.setBool(AppConstants.isOtpVerified, true);
        authService.saveUserToken(token.value);
        authService.updateToken();
        authService.clearSharedPrefGuestId();
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));

        //  if (userExit == true) {
        // exitsUser(statusValue!, auth!, numberWithCountryCode.value);
        //  } else {
        // Get.offAllNamed(RouteHelper.getInitialRoute());
        // }
        //   resetOtpState();
      } else {
        Get.snackbar(
          "Verification Failed",
          '❌ Incorrect OTP: ${otpCode.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.black,
        );
      }
    });
  }

  void retry() {
    //   resetOtpState();
    startTimer();
  }

  void startTimer() {
    seconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value <= 0) {
        timer.cancel();
      } else {
        seconds.value--;
      }
    });
  }

  /// Reset all OTP values
  // void resetOtpState() {
  //   textEditingController.clear();
  //   otpCode.value = '';
  //   enableButton.value = false;
  //   seconds.value = 0;
  //   _timer?.cancel();
  // }

  @override
  void onClose() {
    //resetOtpState();
    //  textEditingController.dispose();
    super.onClose();
  }
}

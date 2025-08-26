import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/screens/sign_in_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'otp_controller.dart';
import 'button_widgte.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Get.back(),
              child: const Row(children: [
                Icon(Icons.arrow_back, size: 30, color: Color(0xFF215A92)),
                Spacer(),
              ]),
            ),
            const SizedBox(height: 8),
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF215A92),
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 25),
            Obx(() => Text(
              'Enter the verification code we just sent to your WhatsApp number: ${controller.numberWithCountryCode.value}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            )),
            const SizedBox(height: 30),
            Obx(() => PinFieldAutoFill(
              controller: controller.textEditingController,
              codeLength: controller.otpCodeLength,
              decoration: UnderlineDecoration(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                colorBuilder: FixedColorBuilder(Colors.grey.shade500),
                lineHeight: 2.0,
              ),
              currentCode: controller.otpCode.value,
              onCodeChanged: (code) => controller.onOtpChanged(code ?? ''),
              onCodeSubmitted: (code) => controller.onOtpChanged(code),
              cursor: Cursor(
                width: 2,
                height: 20,
                color: Colors.blue,
                enabled: true,
              ),
            )),
            const SizedBox(height: 8),
            Center(
              child: Obx(() {
                return controller.otpCode.value.length ==
                    controller.otpCodeLength
                    ? const SizedBox.shrink()
                    : Text(
                  controller.seconds.value == 30
                      ? 'Resend OTP'
                      : '00:${controller.seconds.value.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: controller.seconds.value == 00
                        ? Colors.redAccent
                        : const Color(0xFFA8B3BE),
                    fontSize: 18,
                  ),
                );
              }),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Didn’t receive the code?',
                  style: TextStyle(
                    color: Color(0xFF4D7195),
                    fontSize: 16,
                  ),
                ),
                Obx(() => TextButton(
                  onPressed: controller.seconds.value == 0
                      ? () {
                    final auth = Get.find<AuthController>();
                    verify(
                      auth,
                      controller.numberWithCountryCode.value,
                      controller.countryCode.value,
                    );
                  }
                      : null,
                  child: Text(
                    'Resend',
                    style: TextStyle(
                      color: controller.seconds.value == 00
                          ? Colors.black87
                          : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() => ButtonWidget(
              isDisabled: !controller.enableButton.value,
              isLoading: controller.isLoadingButton.value,
              onTap: () async {
                //     bool result =
                controller.verifyOtpCode(context: context);
              },
              label: 'VERIFY',
            )),
          ],
        ),
      ),
    );
  }
}

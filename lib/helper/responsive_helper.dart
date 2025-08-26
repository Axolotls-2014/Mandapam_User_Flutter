
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  static bool isMobilePhone() {
    // log("In ResponsiveHelper::::::::::isMobilePhone");
    if (!kIsWeb) {
      // log("In ResponsiveHelper::::::::::isMobilePhone::::::::!kIsWeb");
      return true;
    } else {
      // log("In ResponsiveHelper::::::::::isMobilePhone::::::kIsWeb");
      return false;
    }
  }

  static bool isWeb() {
    // log("In ResponsiveHelper::::::::::isWeb");
    return kIsWeb;
  }

  static bool isMobile(context) {
    // log("In ResponsiveHelper::::::::::isMobile");
    final size = MediaQuery.of(context).size.width;
    if (size < 650 || !kIsWeb) {
      // log("In ResponsiveHelper::::::::::isMobile::::::::size<650");
      return true;
    } else {
      // log("In ResponsiveHelper::::::::::isMobile::::::::size>=650");
      return false;
    }
  }

  static bool isTab(context) {
    // log("In ResponsiveHelper::::::::::isTab");
    final size = MediaQuery.of(context).size.width;
    if (size < 1300 && size >= 650) {
      // log("In ResponsiveHelper::::::::::isTab::::::::size>=650&&size<1300");
      return true;
    } else {
      // log("In ResponsiveHelper::::::::::isTab::::::::size<650||size>=1300");
      return false;
    }
  }

  static bool isDesktop(context) {
    // log("In ResponsiveHelper::::::::::isDesktop");
    final size = MediaQuery.of(context).size.width;
    if (size >= 1300) {
      // log("In ResponsiveHelper::::::::::isDesktop::::::::size>=1300");
      return true;
    } else {
      // log("In ResponsiveHelper::::::::::isDesktop::::::::size<1300");
      return false;
    }
  }
}

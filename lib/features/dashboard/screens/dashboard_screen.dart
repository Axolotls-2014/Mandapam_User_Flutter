import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/features/FavoriteMedia/get_favorite_list.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/dashboard/widgets/store_registration_success_bottom_sheet.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/media/view_media.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/address/screens/address_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_dialog.dart';
import 'package:sixam_mart/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:sixam_mart/features/dashboard/widgets/address_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/favourite/screens/favourite_screen.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/menu/screens/menu_screen.dart';
import 'package:sixam_mart/features/order/screens/order_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen({super.key, required this.pageIndex, this.fromSplash = false});
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = AuthHelper.isLoggedIn();
    _showRegistrationSuccessBottomSheet();

    if(_isLogin) {
      if(Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && Get.find<AuthController>().getEarningPint().isNotEmpty
          && !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(const Duration(seconds: 1), () => showAnimatedDialog(Get.context!, const CongratulationDialogue()));
      }
      suggestAddressBottomSheet();
      Get.find<OrderController>().getRunningOrders(1, fromDashboard: true);
    }

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const FavouriteScreen(),
      const MenuScreen(),
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  Future<void> _navigateToViewMediaScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.to(() => ViewMediaScreen(
      sharedPreferences: prefs,
      selectedEventId: Get.find<CategoryController>().categoryList![0].id.toString(),
    ));
  }

  _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<HomeController>().getRegistrationSuccessfulSharedPref();
    if(canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        ResponsiveHelper.isDesktop(Get.context) ? Get.dialog(const Dialog(child: StoreRegistrationSuccessBottomSheet())).then((value) {
          Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<HomeController>().saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        }) : showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const StoreRegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<HomeController>().saveRegistrationSuccessfulSharedPref(false);
          Get.find<HomeController>().saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  Future<void> suggestAddressBottomSheet() async {
    active = await Get.find<LocationController>().checkLocationActive();
    if(widget.fromSplash && Get.find<LocationController>().showLocationSuggestion && active) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => const AddressBottomSheetWidget(),
        ).then((value) {
          Get.find<LocationController>().hideSuggestedLocation();
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
        builder: (splashController) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (_pageIndex != 0) {
                _setPage(0);
              } else {
                if(!ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.module == null) {
                  Get.find<SplashController>().setModule(null);
                  Get.find<StoreController>().resetStoreData();
                } else {
                  if(_canExit) {
                    if (GetPlatform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (GetPlatform.isIOS) {
                      exit(0);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    ));
                    _canExit = true;
                    Timer(const Duration(seconds: 2), () {
                      _canExit = false;
                    });
                  }
                }
              }
            },
            child: Scaffold(
              key: _scaffoldKey,
              body: PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _screens[index];
                },
              ),
              bottomNavigationBar: Container(
                height: GetPlatform.isIOS ? 80 : 65,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BottomNavItemWidget(
                      title: 'home'.tr,
                      selectedIcon: Images.homeSelect,
                      unSelectedIcon: Images.homeUnselect,
                      isSelected: _pageIndex == 0,
                      onTap: () => _setPage(0),
                    ),
                    BottomNavItemWidget(
                      title: 'favorite'.tr,
                      selectedIcon: Images.favouriteSelect,
                      unSelectedIcon: Images.favouriteUnselect,
                      isSelected: _pageIndex == 1,
                      onTap: () {
                        _setPage2(1);
                        _navigateToViewMediaScreen();
                      },
                    ),
                    BottomNavItemWidget(
                      title: 'menu'.tr,
                      selectedIcon: Images.menu,
                      unSelectedIcon: Images.menu,
                      isSelected: _pageIndex == 2,
                      onTap: () => _setPage(2),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  void _setPage2(int pageIndex) {
    setState(() {
      _pageIndex = pageIndex;
    });
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  Widget trackView(BuildContext context, {required bool status}) {
    return Container(height: 3, decoration: BoxDecoration(color: status ? Theme.of(context).primaryColor
        : Theme.of(context).disabledColor.withOpacity(0.5), borderRadius: BorderRadius.circular(Dimensions.radiusDefault)));
  }
}

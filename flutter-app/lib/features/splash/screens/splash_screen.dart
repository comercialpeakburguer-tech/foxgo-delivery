import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  final String? deeplinkUrl;
  const SplashScreen({super.key, required this.body, required this.deeplinkUrl});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          print('=========here coming-----1-->> ${Get.find<SplashController>().deeplinkRoute}');
          if(Get.find<SplashController>().deeplinkRoute == null) {
            Get.find<SplashController>().getConfigData(notificationBody: widget.body);
          }
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) && Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();
    }
    // _route();
    print('=========here coming-----2-->> ${Get.find<SplashController>().deeplinkRoute == null}');
    if(Get.find<SplashController>().deeplinkRoute == null) {
      Get.find<SplashController>().getConfigData(notificationBody: widget.body);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  // void _route() {
  //   Get.find<SplashController>().getConfigData().then((isSuccess) {
  //     if(isSuccess) {
  //       Timer(const Duration(seconds: 1), () async {
  //         double? minimumVersion = _getMinimumVersion();
  //         bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
  //         bool needsUpdate = AppConstants.appVersion < minimumVersion!;
  //
  //         if(needsUpdate || isMaintenanceMode) {
  //           Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  //         }else {
  //           if(widget.body != null) {
  //             _forNotificationRouteProcess(widget.body);
  //           }else {
  //             _handleUserRouting();
  //           }
  //         }
  //       });
  //     }
  //   });
  // }
  //
  // double? _getMinimumVersion() {
  //   if (GetPlatform.isAndroid) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
  //   } else if (GetPlatform.isIOS) {
  //     return Get.find<SplashController>().configModel!.appMinimumVersionIos;
  //   }
  //   return 0;
  // }
  //
  // void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  //   final notificationType = notificationBody?.notificationType;
  //
  //   final Map<NotificationType, Function> notificationActions = {
  //     NotificationType.order: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(widget.body!.orderId, fromNotification: true)),
  //     NotificationType.block: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.unblock: () => Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.notification)),
  //     NotificationType.message: () =>  Get.toNamed(RouteHelper.getChatRoute(notificationBody: widget.body, conversationID: widget.body!.conversationId, fromNotification: true)),
  //     NotificationType.otp: () => null,
  //     NotificationType.add_fund: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.referral_earn: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.cashback: () => Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true)),
  //     NotificationType.loyalty_point: () => Get.toNamed(RouteHelper.getLoyaltyRoute(fromNotification: true)),
  //     NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
  //   };
  //
  //   notificationActions[notificationType]?.call();
  // }
  //
  // Future<void> _forLoggedInUserRouteProcess() async {
  //   Get.find<AuthController>().updateToken();
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     if(Get.find<SplashController>().module != null) {
  //       await Get.find<FavouriteController>().getFavouriteList();
  //     }
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // void _newlyRegisteredRouteProcess() {
  //   if(AppConstants.languages.length > 1) {
  //     Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  //   }else {
  //     Get.offNamed(RouteHelper.getOnBoardingRoute());
  //   }
  // }
  //
  // void _forGuestUserRouteProcess() {
  //   if (AddressHelper.getUserAddressFromSharedPref() != null) {
  //     Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
  //   } else {
  //     Get.find<LocationController>().navigateToLocationScreen('splash', offNamed: true);
  //   }
  // }
  //
  // Future<void> _handleUserRouting() async {
  //   if (AuthHelper.isLoggedIn()) {
  //     _forLoggedInUserRouteProcess();
  //   } else if (Get.find<SplashController>().showIntro() == true) {
  //     _newlyRegisteredRouteProcess();
  //   } else if (AuthHelper.isGuestLoggedIn()) {
  //     _forGuestUserRouteProcess();
  //   } else {
  //     await Get.find<AuthController>().guestLogin();
  //     _forGuestUserRouteProcess();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if(AddressHelper.getUserAddressFromSharedPref() != null && AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      backgroundColor: const Color(0xFFFCFCFC),
      body: GetBuilder<SplashController>(builder: (splashController) {
        return splashController.hasConnection
            ? Stack(
                children: [
                  Positioned(
                    top: -120,
                    left: -120,
                    right: -120,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF6B00).withValues(alpha: 0.10),
                            const Color(0xFFFF6B00).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF6B00).withValues(alpha: 0.08),
                            const Color(0xFFFF6B00).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFFF0F0F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B00).withValues(alpha: 0.20),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Image.asset(Images.logo, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A2E),
                              letterSpacing: -1,
                              height: 1,
                            ),
                            children: [
                              TextSpan(text: 'Fox'),
                              TextSpan(text: 'Delivery', style: TextStyle(color: Color(0xFFFF6B00))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'FOXGODELIVERY.COM.BR',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 12,
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Carregando...',
                          style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : NoInternetScreen(child: SplashScreen(body: widget.body, deeplinkUrl: widget.deeplinkUrl));
      }),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:Asknc_user/constants/api.dart';
import 'package:Asknc_user/constants/app_routes.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/extensions/dynamic.dart';
import 'package:Asknc_user/models/user.dart';
import 'package:Asknc_user/requests/auth.request.dart';
import 'package:Asknc_user/services/auth.service.dart';
import 'package:Asknc_user/view_models/payment.view_model.dart';
import 'package:Asknc_user/views/pages/loyalty/loyalty_point.page.dart';
import 'package:Asknc_user/views/pages/profile/account_delete.page.dart';
import 'package:Asknc_user/views/pages/splash.page.dart';
import 'package:Asknc_user/widgets/bottomsheets/referral.bottomsheet.dart';
import 'package:Asknc_user/widgets/cards/language_selector.view.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileViewModel extends PaymentViewModel {
  //
  String appVersionInfo = "";
  bool authenticated = false;
  User? currentUser;

  //
  AuthRequest _authRequest = AuthRequest();
  StreamSubscription? authStateListenerStream;

  ProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    appVersionInfo = "$versionName($versionCode)";
    authenticated = await AuthServices.authenticated();
    if (authenticated) {
      currentUser = await AuthServices.getCurrentUser(force: true);
    } else {
      listenToAuthChange();
    }
    notifyListeners();
  }

  dispose() {
    super.dispose();
    authStateListenerStream?.cancel();
  }

  listenToAuthChange() {
    authStateListenerStream?.cancel();
    authStateListenerStream =
        AuthServices.listenToAuthState().listen((event) async {
      if (event != null && event) {
        authenticated = event;
        currentUser = await AuthServices.getCurrentUser(force: true);
        notifyListeners();
        authStateListenerStream?.cancel();
      }
    });
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }

//
  openRefer() async {
    await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReferralBottomsheet(this),
    );
  }

  //
  openLoyaltyPoint() {
    viewContext.nextPage(LoyaltyPointPage());
  }

  openWallet() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirmBtnTap: () {
        Navigator.of(viewContext).pop();
        processLogout();
      },
    );
  }

  void processLogout() async {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.loading,
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    Navigator.of(viewContext).pop();

    if (!apiResponse.allGood && apiResponse.code != 401) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout".tr(),
        text: apiResponse.message,
      );
    } else {
      //
      await AuthServices.logout();
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    try {
      if (Platform.isAndroid) {
        // For Android, try in-app review first, then fallback to Play Store
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          // After in-app review, give option to go to Play Store
          await _showStoreReviewOption("online.asknc.user");
        } else {
          // Fallback to Play Store - use your actual Android package name
          await inAppReview.openStoreListing(
            appStoreId: "online.asknc.user", // Your Android package name
          );
        }
      } else if (Platform.isIOS) {
        // For iOS, try in-app review first, then fallback to App Store
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          // After in-app review, give option to go to App Store
          await _showStoreReviewOption("123456789");
        } else {
          // Fallback to App Store - use your actual iOS App ID
          await inAppReview.openStoreListing(
            appStoreId: "123456789", // Replace with your actual iOS App ID
          );
        }
      }
    } catch (e) {
      // Handle any errors gracefully
      print("Error opening review: $e");
      // Fallback to store listing on error
      await _showStoreReviewOption(Platform.isAndroid ? "online.asknc.user" : "123456789");
    }
  }

  _showStoreReviewOption(String appStoreId) async {
    // Show dialog asking if user wants to review on app store
    final result = await showDialog<bool>(
      context: viewContext,
      builder: (context) => AlertDialog(
        title: Text("Rate Our App".tr()),
        content: Text("Would you like to rate us on the app store?".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No, Thanks".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Rate Us".tr()),
          ),
        ],
      ),
    );

    if (result == true) {
      final InAppReview inAppReview = InAppReview.instance;
      await inAppReview.openStoreListing(appStoreId: appStoreId);
    }
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(
        title: 'Faqs'.tr(),
        link: Api.baseUrl + Api.faqs,
      ),
    );
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  openRefundPolicy() async {
    final url = Api.returnPolicy;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    final result = await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return AppLanguageSelector();
      },
    );

    //
    if (result != null) {
      //pop all screen and open splash screen
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
  }

  openLogin() async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.loginRoute,
    );
    //
    initialise();
  }

  void shareReferralCode() {
    Share.share(
      "%s is inviting you to join %s via this referral code: %s".tr().fill(
            [
              currentUser!.name,
              AppStrings.appName,
              currentUser!.code,
            ],
          ) +
          "\nActivate your account using this link:" +
          AppStrings.androidDownloadLink +
          "\nhttps://play.google.com/store/apps/details?id=online.asknc.user&pcampaignid=web_share" +
          AppStrings.iOSDownloadLink +
          "\n",
    );
  }

  //
  deleteAccount() {
    viewContext.nextPage(AccountDeletePage());
  }
}

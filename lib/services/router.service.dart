import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_routes.dart';
import 'package:Asknc_user/models/checkout.dart';
import 'package:Asknc_user/models/delivery_address.dart';
import 'package:Asknc_user/models/notification.dart';
import 'package:Asknc_user/models/order.dart';
import 'package:Asknc_user/models/product.dart';
import 'package:Asknc_user/models/search.dart';
import 'package:Asknc_user/models/vendor.dart';
import 'package:Asknc_user/views/pages/auth/forgot_password.page.dart';
import 'package:Asknc_user/views/pages/auth/login.page.dart';
import 'package:Asknc_user/views/pages/auth/register.page.dart';
import 'package:Asknc_user/views/pages/checkout/checkout.page.dart';
import 'package:Asknc_user/views/pages/delivery_address/delivery_addresses.page.dart';
import 'package:Asknc_user/views/pages/delivery_address/edit_delivery_addresses.page.dart';
import 'package:Asknc_user/views/pages/delivery_address/new_delivery_addresses.page.dart';
import 'package:Asknc_user/views/pages/favourite/favourites.page.dart';
import 'package:Asknc_user/views/pages/home.page.dart';
import 'package:Asknc_user/views/pages/order/orders_tracking.page.dart';
import 'package:Asknc_user/views/pages/profile/change_password.page.dart';
import 'package:Asknc_user/views/pages/vendor_details/vendor_details.page.dart';
import 'package:Asknc_user/views/pages/notification/notification_details.page.dart';
import 'package:Asknc_user/views/pages/notification/notifications.page.dart';
import 'package:Asknc_user/views/pages/onboarding.page.dart';
import 'package:Asknc_user/views/pages/order/orders_details.page.dart';
import 'package:Asknc_user/views/pages/product/product_details.page.dart';
import 'package:Asknc_user/views/pages/profile/edit_profile.page.dart';
import 'package:Asknc_user/views/pages/search/search.page.dart';
import 'package:Asknc_user/views/pages/wallet/wallet.page.dart';
import 'package:Asknc_user/views/shared/location_fetch.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.welcomeRoute:
      return MaterialPageRoute(builder: (context) => OnboardingPage());

    case AppRoutes.loginRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case AppRoutes.registerRoute:
      return MaterialPageRoute(builder: (context) => RegisterPage());

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => LocationFetchPage(
          child: HomePage(),
        ),
      );

    //SEARCH
    case AppRoutes.search:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.search),
        builder: (context) => SearchPage(search: settings.arguments as Search),
      );

    //Product details
    case AppRoutes.product:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.product),
        builder: (context) =>
            ProductDetailsPage(product: settings.arguments as Product),
      );

    //Vendor details
    case AppRoutes.vendorDetails:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.vendorDetails),
        builder: (context) =>
            VendorDetailsPage(vendor: settings.arguments as Vendor),
      );

    //Checkout page
    case AppRoutes.checkoutRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.checkoutRoute),
        builder: (context) => CheckoutPage(
          checkout: settings.arguments as CheckOut,
        ),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder: (context) => OrderDetailsPage(
          order: settings.arguments as Order,
        ),
      );
    //order tracking page
    case AppRoutes.orderTrackingRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.orderTrackingRoute),
        builder: (context) => OrderTrackingPage(
          order: settings.arguments as Order,
        ),
      );
    //chat page
    case AppRoutes.chatRoute:
      return FirestoreChat().chatPageWidget(
        settings.arguments as ChatEntity,
      );

    //
    case AppRoutes.editProfileRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.editProfileRoute),
        builder: (context) => EditProfilePage(),
      );

    //change password
    case AppRoutes.changePasswordRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.changePasswordRoute),
        builder: (context) => ChangePasswordPage(),
      );

    //Delivery addresses
    case AppRoutes.deliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.deliveryAddressesRoute),
        builder: (context) => DeliveryAddressesPage(),
      );
    case AppRoutes.newDeliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.newDeliveryAddressesRoute),
        builder: (context) => NewDeliveryAddressesPage(),
      );
    case AppRoutes.editDeliveryAddressesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.editDeliveryAddressesRoute),
        builder: (context) => EditDeliveryAddressesPage(
          deliveryAddress: settings.arguments as DeliveryAddress,
        ),
      );

    //wallets
    case AppRoutes.walletRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.walletRoute),
        builder: (context) => WalletPage(),
      );

    //favourites
    case AppRoutes.favouritesRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.favouritesRoute),
        builder: (context) => FavouritesPage(),
      );

    //profile settings/actions
    case AppRoutes.notificationsRoute:
      return MaterialPageRoute(
        settings:
            RouteSettings(name: AppRoutes.notificationsRoute, arguments: Map()),
        builder: (context) => NotificationsPage(),
      );

    //
    case AppRoutes.notificationDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
            name: AppRoutes.notificationDetailsRoute, arguments: Map()),
        builder: (context) => NotificationDetailsPage(
          notification: settings.arguments as NotificationModel,
        ),
      );

    default:
      return MaterialPageRoute(builder: (context) => OnboardingPage());
  }
}

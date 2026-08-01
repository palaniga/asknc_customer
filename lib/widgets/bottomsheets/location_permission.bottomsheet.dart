import 'dart:io';

import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/extensions/dynamic.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/widgets/buttons/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../services/app.service.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({
    Key? key,
    required this.onResult,
  }) : super(key: key);

  final Function(bool allow) onResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SafeArea(
        child: VStack(
          [
            "Location Permission Request".tr().text.semiBold.xl.make().py12(),

            "Thank you for using %s. To provide the best experience, our app needs access to your location for nearby vendors, delivery address setup, and live order tracking. We do not share your location with third parties."
                .tr()
                .fill([AppStrings.appName])
                .text
                .make(),

            UiSpacer.verticalSpace(),

            // NEXT → allow = true
            CustomButton(
              title: "Next".tr(),
              onPressed: () {
                Navigator.of(AppService().navigatorKey.currentContext!).pop();
                onResult(true);
              },
            ).py12(),

            // CANCEL → allow = false (Android only)
            Visibility(
              visible: !Platform.isIOS,
              child: CustomButton(
                title: "Cancel".tr(),
                color: Colors.grey[400],
                onPressed: () {
                  Navigator.of(AppService().navigatorKey.currentContext!).pop();
                  onResult(false);
                },
              ),
            ),
          ],
        ).p20().scrollVertical(),
      ),
    );
  }
}

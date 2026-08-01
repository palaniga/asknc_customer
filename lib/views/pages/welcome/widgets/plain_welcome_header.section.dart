import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Asknc_user/constants/app_colors.dart';
import 'package:Asknc_user/constants/home_screen.config.dart';
import 'package:Asknc_user/models/address.dart';
import 'package:Asknc_user/services/alert.service.dart';
import 'package:Asknc_user/services/app.service.dart';
import 'package:Asknc_user/services/auth.service.dart';
import 'package:Asknc_user/services/location.service.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/view_models/welcome.vm.dart';
import 'package:Asknc_user/widgets/cards/custom.visibility.dart';
import 'package:Asknc_user/widgets/custom_image.view.dart';
import 'package:Asknc_user/widgets/finance/plain_wallet_management.view.dart';
import 'package:Asknc_user/widgets/inputs/search_bar.input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PlainWelcomeHeaderSection extends StatelessWidget {
  const PlainWelcomeHeaderSection(
    this.vm, {
    Key? key,
  }) : super(key: key);

  final WelcomeViewModel vm;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //location section
        HStack(
          [
            HStack(
              [
                Icon(
                  FlutterIcons.location_pin_ent,
                  size: 24,
                  color: Utils.textColorByTheme(),
                ),
                UiSpacer.hSpace(5),
                VStack(
                  [
                    "Deliver To"
                        .tr()
                        .text
                        .thin
                        .light
                        .color(Utils.textColorByTheme())
                        .sm
                        .make(),
                    StreamBuilder<Address?>(
                      stream: LocationService.currenctAddressSubject,
                      builder: (conxt, snapshot) {
                        return (snapshot.hasData
                                ? "${snapshot.data?.addressLine}"
                                : "Current Location".tr())
                            .text
                            .color(Utils.textColorByTheme())
                            .medium
                            .maxLines(1)
                            .ellipsis
                            .make();
                      },
                    ).flexible(),
                  ],
                ).flexible(),
                UiSpacer.hSpace(5),
                Icon(
                  FlutterIcons.chevron_down_ent,
                  size: 20,
                  color: Utils.textColorByTheme(),
                ),
              ],
            ).expand(),

            UiSpacer.hSpace(),
            //profile is login
            StreamBuilder<dynamic>(
              stream: AuthServices.listenToAuthState(),
              initialData: false,
              builder: (ctx, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data is bool &&
                    snapshot.data) {
                  return CustomImage(
                    imageUrl: AuthServices.currentUser?.photo ?? "",
                  )
                      .wh(35, 35)
                      .box
                      .roundedFull
                      .clip(Clip.antiAlias)
                      .make()
                      .onInkTap(
                    () {
                      AppService().homePageIndex.add(3);
                    },
                  );
                } else {
                  return UiSpacer.emptySpace();
                }
              },
            ),
          ],
        ).onTap(
          () async {
            await onLocationSelectorPressed();
          },
        ),

        //search button
        UiSpacer.vSpace(),
        SearchBarInput(
          onTap: () {
            AppService().homePageIndex.add(2);
          },
        ),
        UiSpacer.vSpace(5),

        //wallet UI for login user
        //finance section
        StreamBuilder<dynamic>(
          stream: AuthServices.listenToAuthState(),
          initialData: false,
          builder: (ctx, snapshot) {
            if (snapshot.hasData && snapshot.data is bool && snapshot.data) {
              return CustomVisibilty(
                visible: HomeScreenConfig.showWalletOnHomeScreen,
                child: PlainWalletManagementView().py(15),
              );
            } else {
              return UiSpacer.emptySpace();
            }
          },
        ),

        //
        UiSpacer.vSpace(120),
      ],
    )
        .wFull(context)
        .safeArea()
        .p12()
        .box
        .bottomRounded(value: 25)
        .color(AppColor.primaryColor)
        .make();
  }

  Future<void> onLocationSelectorPressed() async {
    try {
      vm.pickDeliveryAddress(onselected: () {
        vm.pageKey = GlobalKey<State>();
        vm.notifyListeners();
      });
    } catch (error) {
      AlertService.stopLoading();
    }
  }
}

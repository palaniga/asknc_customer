import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/extensions/dynamic.dart';
import 'package:Asknc_user/resources/resources.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/view_models/profile.vm.dart';
import 'package:Asknc_user/widgets/base.page.dart';
import 'package:Asknc_user/widgets/cards/profile.card.dart';
import 'package:Asknc_user/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (model) => model.initialise(),
        disposeViewModel: false,
        builder: (context, model, child) {
          return BasePage(
            body: VStack(
              [
                //
                "Settings".tr().text.xl2.semiBold.make(),
                "Profile & App Settings".tr().text.lg.light.make(),
                //profile card
                ProfileCard(model).py12(),
                //menu
                VStack(
                  [
                    //
                    MenuItem(
                      title: "Notifications".tr(),
                      onPressed: model.openNotification,
                      ic: AppIcons.bell,
                    ),

                    //
                    MenuItem(
                      title: "Rate & Review".tr(),
                      onPressed: model.openReviewApp,
                      ic: AppIcons.rating,
                    ),

                    //
                    MenuItem(
                      title: "Faqs".tr(),
                      onPressed: model.openFaqs,
                      ic: AppIcons.compliant,
                    ),
                    //
                    MenuItem(
                      title: "Privacy Policy".tr(),
                      onPressed: model.openPrivacyPolicy,
                      ic: AppIcons.compliant,
                    ),
                    //
                    MenuItem(
                      title: "Refund_policy".tr(),
                      onPressed: model.openRefundPolicy,
                      ic: AppIcons.compliant,
                    ),
                    MenuItem(
                      title: "Terms & Conditions".tr(),
                      onPressed: model.openTerms,
                      ic: AppIcons.termsAndConditions,
                    ),
                    //
                    MenuItem(
                      title: "Contact Us".tr(),
                      onPressed: model.openContactUs,
                      ic: AppIcons.communicate,
                    ),
                    //
                    MenuItem(
                      title: "Live Support".tr(),
                      onPressed: model.openLivesupport,
                      ic: AppIcons.livesupport,
                    ),
                    //
                    MenuItem(
                      title: "Language".tr(),
                      divider: false,
                      ic: AppIcons.translation,
                      onPressed: model.changeLanguage,
                    ),
                    model.authenticated?  MenuItem(
                      child: "Delete Account".tr().text.red500.make(),
                      onPressed: model.deleteAccount,
                      suffix: Icon(
                        FlutterIcons.delete_ant,
                        size: 16,
                        color: Vx.red400,
                      ),
                    ):SizedBox(),
                    //
                    MenuItem(
                      title: "Version".tr(),
                      suffix: model.appVersionInfo.text.make(),
                    ),
                  ],
                ),
                //
                "Copyright ©%s %s all right reserved"
                    .tr()
                    .fill([
                      "${DateTime.now().year}",
                      AppStrings.companyName,
                    ])
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
                //
                UiSpacer.verticalSpace(space: context.percentHeight * 10),
              ],
            ).p20().scrollVertical(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

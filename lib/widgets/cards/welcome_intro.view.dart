import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_images.dart';
import 'package:Asknc_user/models/user.dart';
import 'package:Asknc_user/services/auth.service.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WelcomeIntroView extends StatefulWidget {
  const WelcomeIntroView({Key? key}) : super(key: key);

  @override
  State<WelcomeIntroView> createState() => _WelcomeIntroViewState();
}

class _WelcomeIntroViewState extends State<WelcomeIntroView> {
  bool isNotLogin = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: VStack(
        [
          VStack([
            HStack([
              VStack([
                StreamBuilder(
                  stream: AuthServices.listenToAuthState(),
                  builder: (ctx, snapshot) {
                    //
                    String introText = "Welcome to Asknc".tr();
                    String fullIntroText = introText;

                    //
                    if (snapshot.hasData) {
                      return FutureBuilder<User>(
                        future: AuthServices.getCurrentUser(),
                        builder: (ctx, snapshot) {
                          if (snapshot.hasData) {
                            fullIntroText = "$introText ";
                            final user = snapshot.data;
                            isNotLogin = true;
                            return HStack(
                              [
                                CustomImage(
                                  imageUrl: user!.photo,
                                ).box.roundedFull.shadowSm.make().wh(50, 50),
                                UiSpacer.hSpace(15),
                                //

                                VStack(
                                  [
                                    //name
                                    fullIntroText.text
                                        .color(Utils.textColorByTheme())
                                        .xl
                                        .semiBold
                                        .make(),
                                    //email
                                    '${snapshot.data?.name}'
                                        .text
                                        .color(Utils.textColorByTheme())
                                        .sm
                                        .thin
                                        .make(),
                                    // "${user.email}"
                                    //     .hidePartial(
                                    //       begin: 3,
                                    //       end: "${user.email}".length - 8,
                                    //     )!
                                    //     .text
                                    //     .color(Utils.textColorByTheme())
                                    //     .sm
                                    //     .thin
                                    //     .make(),
                                  ],
                                ).expand(),

                                Image.asset(
                                  AppImages.appLogo,
                                  scale: 11.5,
                                )
                                    .h(50)
                                    .w(50)
                                    .box
                                    .roundedSM
                                    .color(Colors.white)
                                    .clip(Clip.antiAlias)
                                    .make(),
                              ],
                            ).pOnly(bottom: 10);
                          } else {
                            //auth but not data received
                            return fullIntroText.text.white.xl3.semiBold.make();
                          }
                        },
                      );
                    }
                    return fullIntroText.text.white.xl3.semiBold.make();
                  },
                ),
                //
                "How can I help you today?".tr().text.white.xl.medium.make(),
              ]).expand(),
              isNotLogin
                  ? SizedBox()
                  : Image.asset(
                      AppImages.appLogo,
                      scale: 11.5,
                    )
                      .h(50)
                      .w(50)
                      .box
                      .roundedSM
                      .color(Colors.white)
                      .clip(Clip.antiAlias)
                      .make(),
            ]),
          ]),

          //welcome intro and loggedin account name
        ],
      ).p20(),
    );
  }
}

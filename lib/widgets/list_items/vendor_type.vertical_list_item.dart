import 'package:Asknc_user/constants/app_ui_styles.dart';
import 'package:Asknc_user/models/vendor_type.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/widgets/custom_image.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';

import 'container_cliper.dart';

class VendorTypeVerticalListItem extends StatelessWidget {
  const VendorTypeVerticalListItem(
    this.vendorType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final Function onPressed;
  @override
  Widget build(BuildContext context) {
    //
    final textColor =
        Utils.textColorByColor(context.theme.colorScheme.background);
    //
    return AnimationConfiguration.staggeredList(
      position: vendorType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: () => onPressed(),
            child: Container(
              height: 200,
              width: 125,
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.white12 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade500.withOpacity(0.35),
                      blurRadius: 3,
                      offset: const Offset(0, 0),
                      spreadRadius: 3)
                ],
                border: Border.all(color: Colors.grey.shade500, width: 1),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: ClipPath(
                      clipper: ContainerClipper(),
                      child: Container(
                        height: 180,
                        width: 200,
                        decoration: BoxDecoration(
                          color:
                              Vx.hexToColor(vendorType.color).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: CustomImage(
                      imageUrl: vendorType.logo,
                      boxFit: AppUIStyles.vendorTypeImageStyle,
                      height: 115,
                      width: AppUIStyles.vendorTypeWidth,
                    ).p12().centered(),
                  ),
                  Positioned(
                      left: 12,
                      top: 10,
                      child: SizedBox(
                        width: 100,
                        child: VStack(
                          [
                            vendorType.name.text.lg
                                .color(textColor)
                                .semiBold
                                .center
                                .makeCentered(),
                            Visibility(
                              visible: vendorType.description.isNotEmpty,
                              child: "${vendorType.description}"
                                  .text
                                  .color(textColor)
                                  .center
                                  .sm
                                  .makeCentered()
                                  .pOnly(top: 5),
                            ),
                          ],
                        ).py4(),
                      )),
                ],
              ),
            ),
            // child: VStack(
            //   [
            //     //image + details
            //     Visibility(
            //       visible: !AppStrings.showVendorTypeImageOnly,
            //       child: VStack(
            //         [
            //           //
            //           CustomImage(
            //             imageUrl: vendorType.logo,
            //             boxFit: AppUIStyles.vendorTypeImageStyle,
            //             height: AppUIStyles.vendorTypeHeight,
            //             width: AppUIStyles.vendorTypeWidth,
            //           ).p12().centered(),
            //           //
            //           VStack(
            //             [
            //               vendorType.name.text.lg
            //                   .color(textColor)
            //                   .semiBold
            //                   .center
            //                   .makeCentered(),
            //               Visibility(
            //                 visible: vendorType.description.isNotEmpty,
            //                 child: "${vendorType.description}"
            //                     .text
            //                     .color(textColor)
            //                     .center
            //                     .sm
            //                     .makeCentered()
            //                     .pOnly(top: 5),
            //               ),
            //             ],
            //           ).py4(),
            //         ],
            //       ).p12().centered(),
            //     ),
            //
            //     //image only
            //     Visibility(
            //       visible: AppStrings.showVendorTypeImageOnly,
            //       child: CustomImage(
            //         imageUrl: vendorType.logo,
            //         boxFit: AppUIStyles.vendorTypeImageStyle,
            //         height: AppUIStyles.vendorTypeHeight,
            //         width: AppUIStyles.vendorTypeWidth,
            //       ),
            //     ),
            //   ],
            // ),
          )
              .box
              .clip(Clip.antiAlias)
              .withRounded(value: 10)
              .outerShadow
              .color(Vx.hexToColor(vendorType.color))
              .border(color: Vx.hexToColor(vendorType.color))
              .make(),
        ),
      ),
    );
  }
}

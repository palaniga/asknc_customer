import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_colors.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/view_models/product_details.vm.dart';
import 'package:Asknc_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class BuyNowButton extends StatelessWidget {
  const BuyNowButton(this.model, {Key? key}) : super(key: key);

  final ProductDetailsViewModel model;

  //
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      color: AppColor.primaryColorDark,
      loading: model.isBusy,
      child: "Buy Now"
          .tr()
          .text
          .color(Utils.textColorByTheme())
          .semiBold
          .make()
          .p12(),
      onPressed: model.buyNow,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_colors.dart';
import 'package:Asknc_user/models/product.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class DiscountPositiedView extends StatelessWidget {
  const DiscountPositiedView(this.product, {Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    //fav icon
    return Positioned(
      left: !Utils.isArabic ? 10 : null,
      right: !Utils.isArabic ? null : 10,
      child: Visibility(
        visible: product.showDiscount,
        child: VxBox(
          child:
              "-${product.discountPercentage}%".text.xs.semiBold.white.make(),
        ).p4.bottomRounded(value: 5).color(AppColor.primaryColor).make(),
      ),
    );
  }
}

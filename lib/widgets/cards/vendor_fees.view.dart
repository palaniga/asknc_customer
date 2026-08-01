import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/extensions/dynamic.dart';
import 'package:Asknc_user/extensions/string.dart';
import 'package:Asknc_user/models/fee.dart';
import 'package:Asknc_user/views/pages/cart/widgets/amount_tile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorFeesView extends StatelessWidget {
  const VendorFeesView({
    this.fees = const [],
    this.subTotal = 0,
    this.mCurrencySymbol,
    Key? key,
  }) : super(key: key);

  final List<Fee> fees;
  final double subTotal;
  final String? mCurrencySymbol;
  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        mCurrencySymbol != null ? mCurrencySymbol : AppStrings.currencySymbol;

    return Visibility(
      visible: fees.isNotEmpty,
      child: VStack(
        [
          ...(fees.map((fee) {
            //fixed
            if ((fee.percentage != 1)) {
              return AmountTile(
                "${fee.name}".tr(),
                "+ " +
                    " $currencySymbol ${fee.value}"
                        .currencyFormat(currencySymbol),
              ).py2();
            } else {
              //percentage
              return AmountTile(
                "${fee.name} (%s)".tr().fill(["${fee.value.round()}%"]),
                "+ " +
                    " $currencySymbol ${fee.getRate(subTotal).toStringAsFixed(2)}"
                        .currencyFormat(currencySymbol),
              ).py2();
            }
          }).toList()),
        ],
      ),
    );
  }
}

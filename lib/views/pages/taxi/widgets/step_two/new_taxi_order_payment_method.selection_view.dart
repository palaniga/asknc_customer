import 'package:Asknc_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:Asknc_user/widgets/custom_image.view.dart';
import 'package:Asknc_user/widgets/directional_chevron.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderPaymentMethodSelectionView extends StatelessWidget {
  const NewTaxiOrderPaymentMethodSelectionView({
    required this.vm,
    Key? key,
  }) : super(key: key);

  final NewTaxiOrderSummaryViewModel vm;
  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        CustomImage(
          imageUrl: vm.taxiViewModel.selectedPaymentMethod!.photo,
        ).wh(40, 40),
        "${vm.taxiViewModel.selectedPaymentMethod!.name}"
            .text
            .make()
            .px12()
            .expand(),
        DirectionalChevron(),
      ],
    )
        .onInkTap(
          vm.openPaymentMethodSelection,
        )
        .box
        .roundedSM
        .px8
        .make();
  }
}

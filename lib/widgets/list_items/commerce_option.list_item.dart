import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_colors.dart';
import 'package:Asknc_user/extensions/string.dart';
import 'package:Asknc_user/models/option.dart';
import 'package:Asknc_user/models/option_group.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/view_models/product_details.vm.dart';
import 'package:Asknc_user/widgets/bottomsheets/option_details.bottomsheet.dart';
import 'package:velocity_x/velocity_x.dart';

class CommerceOptionListItem extends StatelessWidget {
  const CommerceOptionListItem({
    required this.option,
    required this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final Option option;
  final OptionGroup optionGroup;
  final ProductDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    //
    return "${option.name}${option.price > 0 ? ' (+${option.price.currencyValueFormat()})' : ''}"
        .text
        .medium
        .lg
        .make()
        .box
        .p8
        .roundedSM
        .border(
            color: model.isOptionSelected(option)
                ? AppColor.primaryColor
                : Colors.grey,
            width: model.isOptionSelected(option) ? 1.4 : 1)
        .make()
        .pOnly(left: !Utils.isArabic ? 0 : 10, right: Utils.isArabic ? 0 : 10)
        .onInkTap(() => model.toggleOptionSelection(optionGroup, option))
        .onInkLongPress(
      () {
        //open the option details
        showOptionDetails(context, option);
      },
    );
  }

  void showOptionDetails(BuildContext ctx, Option option) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx) {
        return OptionDetailsBottomSheet(option);
      },
    );
  }
}

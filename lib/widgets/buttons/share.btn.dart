import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Asknc_user/constants/app_colors.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:Asknc_user/view_models/product_details.vm.dart';
import 'package:Asknc_user/view_models/service_details.vm.dart';
import 'package:Asknc_user/view_models/vendor_details.vm.dart';
import 'package:Asknc_user/widgets/buttons/custom_outline_button.dart';
import 'package:velocity_x/velocity_x.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    this.model,
    Key? key,
  }) : super(key: key);

  final dynamic model;

  @override
  Widget build(BuildContext context) {
    return CustomOutlineButton(
      loading: model.busy((model is ProductDetailsViewModel)
          ? model.shareProduct
          : (model is VendorDetailsViewModel)
              ? model.shareVendor
              : model.shareService),
      color: Colors.transparent,
      child: Icon(
        FlutterIcons.share_fea,
        color: AppColor.primaryColorDark,
      ),
      onPressed: () {
        if (model is ProductDetailsViewModel) {
          model.shareProduct(model.product);
        } else if (model is VendorDetailsViewModel) {
          model.shareVendor(model.vendor);
        } else if (model is ServiceDetailsViewModel) {
          model.shareService(model.service);
        }
      },
    ).p2().box.color(Utils.textColorByTheme()).roundedFull.make();
  }
}

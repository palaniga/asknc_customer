import 'package:flutter/material.dart';
import 'package:Asknc_user/models/vendor.dart';
import 'package:Asknc_user/view_models/vendor_details.vm.dart';
import 'package:Asknc_user/views/pages/vendor_details/widgets/vendor_with_menu.view.dart';
import 'package:stacked/stacked.dart';

import 'widgets/vendor_plain_details.view.dart';

class VendorDetailsPage extends StatelessWidget {
  VendorDetailsPage({
    required this.vendor,
    Key? key,
  }) : super(key: key);

  final Vendor vendor;

  Widget build(BuildContext context) {
    return ViewModelBuilder<VendorDetailsViewModel>.reactive(
      viewModelBuilder: () => VendorDetailsViewModel(context, vendor),
      onViewModelReady: (model) => model.getVendorDetails(),
      builder: (context, model, child) {
        return (!model.vendor!.hasSubcategories && !model.vendor!.isServiceType)
            ? VendorDetailsWithMenuPage(vendor: model.vendor!)
            : VendorPlainDetailsView(model);
      },
    );
  }
}

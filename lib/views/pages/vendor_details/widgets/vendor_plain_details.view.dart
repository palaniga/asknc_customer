import 'package:flutter/material.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/view_models/vendor_details.vm.dart';
import 'package:Asknc_user/views/pages/vendor_details/service_vendor_details.page.dart';
import 'package:Asknc_user/views/pages/vendor_details/widgets/upload_prescription.btn.dart';
import 'package:Asknc_user/views/pages/vendor_details/widgets/vendor_with_subcategory.view.dart';
import 'package:Asknc_user/widgets/base.page.dart';
import 'package:Asknc_user/widgets/buttons/custom_leading.dart';
import 'package:Asknc_user/widgets/buttons/share.btn.dart';
import 'package:Asknc_user/widgets/cards/custom.visibility.dart';
import 'package:Asknc_user/widgets/cart_page_action.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPlainDetailsView extends StatelessWidget {
  const VendorPlainDetailsView(this.model, {Key? key}) : super(key: key);
  final VendorDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      elevation: 0,
      extendBodyBehindAppBar: true,
      appBarColor: Colors.transparent,
      backgroundColor: context.theme.colorScheme.background,
      leading: CustomLeading(),
      fab: UploadPrescriptionFab(model),
      actions: [
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(
            child: ShareButton(
              model: model,
            ),
          ),
        ),
        UiSpacer.hSpace(10),
        PageCartAction(),
      ],
      body: VStack(
        [
          //subcategories && hide for service vendor type
          CustomVisibilty(
            visible: (model.vendor!.hasSubcategories &&
                !model.vendor!.isServiceType),
            child: VendorDetailsWithSubcategoryPage(
              vendor: model.vendor!,
            ),
          ),

          //show for service vendor type
          CustomVisibilty(
            visible: model.vendor!.isServiceType,
            child: ServiceVendorDetailsPage(
              model,
              vendor: model.vendor!,
            ),
          ),
        ],
      ),
    );
  }
}

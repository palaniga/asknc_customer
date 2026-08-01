import 'package:Asknc_user/constants/app_routes.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/models/product.dart';
import 'package:Asknc_user/models/vendor.dart';
import 'package:Asknc_user/requests/vendor.request.dart';
import 'package:Asknc_user/view_models/base.view_model.dart';
import 'package:Asknc_user/views/pages/pharmacy/pharmacy_upload_prescription.page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class VendorDetailsViewModel extends MyBaseViewModel {
  //
  VendorDetailsViewModel(
    BuildContext context,
    this.vendor,
  ) {
    this.viewContext = context;
  }

  //
  VendorRequest _vendorRequest = VendorRequest();

  //
  Vendor? vendor;
  TabController? tabBarController;
  final currencySymbol = AppStrings.currencySymbol;

  RefreshController refreshContoller = RefreshController();
  List<RefreshController> refreshContollers = [];
  List<int> refreshContollerKeys = [];

  //
  Map<int, List> menuProducts = {};
  Map<int, int> menuProductsQueryPages = {};

  //
  void getVendorDetails() async {
    //
    setBusy(true);

    try {
      vendor = await _vendorRequest.vendorDetails(
        vendor!.id,
        params: {
          "type": "small",
        },
      );

      clearErrors();
    } catch (error) {
      setError(error);
      print("error ==> ${error}");
    }
    setBusy(false);
  }

  void productSelected(Product product) async {
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.product,
      arguments: product,
    );

    //
    notifyListeners();
  }

  //
  void uploadPrescription() {
    //
    Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => PharmacyUploadPrescription(vendor!),
        ));
    // viewContext.push(
    //   (context) => PharmacyUploadPrescription(vendor!),
    // );
  }

  openVendorSearch() {
    Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => PharmacyUploadPrescription(vendor!),
        ));
  }
}

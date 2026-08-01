import 'package:flutter/material.dart';
import 'package:Asknc_user/models/product.dart';
import 'package:Asknc_user/models/vendor_type.dart';
import 'package:Asknc_user/requests/product.request.dart';
import 'package:Asknc_user/view_models/base.view_model.dart';

class BestSellingProductsViewModel extends MyBaseViewModel {
  //
  ProductRequest _productRequest = ProductRequest();
  //
  List<Product> products = [];
  VendorType? vendorType;

  BestSellingProductsViewModel(BuildContext context, this.vendorType) {
    this.viewContext = context;
  }

  //
  initialise() async {
    setBusy(true);
    try {
      products = await _productRequest.bestProductsRequest(
        queryParams: {
          "vendor_type_id": vendorType?.id,
        },
      );
      clearErrors();
    } catch (error) {
      print("BestSellingProductsViewModel Error ==> $error");
      setError(error);
    }
    setBusy(false);
  }
}

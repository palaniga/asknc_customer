import 'package:flutter/material.dart';
import 'package:Asknc_user/models/checkout.dart';
import 'package:Asknc_user/view_models/checkout_base.vm.dart';

class CheckoutViewModel extends CheckoutBaseViewModel {
  //

  //
  CheckoutViewModel(
    BuildContext context,
    CheckOut checkout,
  ) {
    this.viewContext = context;
    this.checkout = checkout;
  }


}

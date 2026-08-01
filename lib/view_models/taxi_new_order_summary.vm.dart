import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_ui_sizes.dart';
import 'package:Asknc_user/requests/taxi.request.dart';
import 'package:Asknc_user/services/geocoder.service.dart';
import 'package:Asknc_user/view_models/base.view_model.dart';
import 'package:Asknc_user/view_models/taxi.vm.dart';
import 'package:Asknc_user/views/shared/payment_method_selection.page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class NewTaxiOrderSummaryViewModel extends MyBaseViewModel {
  //
  NewTaxiOrderSummaryViewModel(BuildContext context, this.taxiViewModel) {
    this.viewContext = context;
  }

  TaxiRequest taxiRequest = TaxiRequest();
  GeocoderService geocoderService = GeocoderService();
  final TaxiViewModel taxiViewModel;
  PanelController panelController = PanelController();
  double customViewHeight = AppUISizes.taxiNewOrderSummaryHeight;

  initialise() {}

  //
  updateLoadingheight() {
    customViewHeight = AppUISizes.taxiNewOrderHistoryHeight;
    notifyListeners();
  }

  resetStateViewheight([double height = 0]) {
    customViewHeight = AppUISizes.taxiNewOrderIdleHeight + height;
    notifyListeners();
  }

  closePanel() async {
    clearFocus();
    await panelController.close();
    notifyListeners();
  }

  clearFocus() {
    FocusScope.of(taxiViewModel.viewContext).requestFocus(new FocusNode());
  }

  openPanel() async {
    await panelController.open();
    notifyListeners();
  }

  void openPaymentMethodSelection() async {
    //
    if (taxiViewModel.paymentMethods.isEmpty) {
      await taxiViewModel.fetchTaxiPaymentOptions();
    }
    final mPaymentMethod = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionPage(
          list: taxiViewModel.paymentMethods,
        ),
      ),
    );
    if (mPaymentMethod != null) {
      taxiViewModel.changeSelectedPaymentMethod(
        mPaymentMethod,
        callTotal: false,
      );
    }

    notifyListeners();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:Asknc_user/models/api_response.dart';
import 'package:Asknc_user/models/user.dart';
import 'package:Asknc_user/models/wallet.dart';
import 'package:Asknc_user/requests/wallet.request.dart';
import 'package:Asknc_user/traits/qrcode_scanner.trait.dart';
import 'package:Asknc_user/view_models/payment.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class WalletTransferViewModel extends PaymentViewModel with QrcodeScannerTrait {
  //
  WalletTransferViewModel(BuildContext context, this.wallet) {
    this.viewContext = context;
  }

  //
  WalletRequest walletRequest = WalletRequest();
  Wallet? wallet;
  User? selectedUser;
  TextEditingController amountTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  //
  Future<List<User>> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      return [];
    }
    //
    ApiResponse apiResponse = await walletRequest.getWalletAddress(keyword);
    if (apiResponse.allGood) {
      //
      return (apiResponse.body["users"] as List)
          .map((e) => User.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  void userSelected(suggestion) {
    selectedUser = suggestion;
    notifyListeners();
  }

  scanWalletAddress() async {
    final walletCode = await openScanner(viewContext);
    if (walletCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      selectedUser = User.fromJson(jsonDecode(walletCode));
      notifyListeners();
    }
  }

  //
  initiateWalletTransfer() async {
    //
    if (formKey.currentState!.validate()) {
      setBusy(true);
      try {
        //
        ApiResponse apiResponse = await walletRequest.transferWallet(
          amountTEC.text,
          selectedUser!.walletAddress,
          passwordTEC.text,
        );
        //
        if (apiResponse.allGood) {
          toastSuccessful(apiResponse.message ?? "Operation successful".tr());
          Navigator.of(viewContext).pop(true);
        } else {
          toastError(apiResponse.message ?? "Operation failed".tr());
        }
      } catch (error) {
        toastError("$error");
      }
      setBusy(false);
    } else if (selectedUser == null) {
      toastError("Please select reciepent".tr());
    }
  }
}

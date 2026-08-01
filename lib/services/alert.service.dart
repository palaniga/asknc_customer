import 'dart:async';

import 'package:Asknc_user/services/app.service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class AlertService {
  static BuildContext get _ctx => AppService().navigatorKey.currentContext!;

  /// Safe dialog pop - ensures dialog is closed only once
  static void _safePop() {
    Future.microtask(() {
      if (Navigator.canPop(_ctx)) {
        Navigator.pop(_ctx);
      }
    });
  }

  // -------------------------------
  // CONFIRM DIALOG
  // -------------------------------
  static Future<bool> showConfirm({
    String? title,
    String? text,
    String cancelBtnText = "Cancel",
    String confirmBtnText = "Ok",
    Function? onConfirm,
  }) async {
    bool result = false;

    await CoolAlert.show(
      context: _ctx,
      type: CoolAlertType.confirm,
      title: title,
      text: text,
      cancelBtnText: cancelBtnText.tr(),
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: () {
        result = true;

        // Run user action
        if (onConfirm != null) onConfirm();

        // Close dialog safely
        _safePop();
      },
    );

    return result;
  }

  // -------------------------------
  // SUCCESS DIALOG
  // -------------------------------
  static Future<bool> success({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
  }) async {
    bool result = false;

    await CoolAlert.show(
      context: _ctx,
      type: CoolAlertType.success,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: () {
        result = true;
        _safePop();
      },
    );

    return result;
  }

  // -------------------------------
  // ERROR DIALOG
  // -------------------------------
  static Future<bool> error({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
  }) async {
    bool result = false;

    await CoolAlert.show(
      context: _ctx,
      type: CoolAlertType.error,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: () {
        result = true;
        _safePop();
      },
    );

    return result;
  }

  // -------------------------------
  // WARNING DIALOG
  // -------------------------------
  static Future<bool> warning({
    String? title,
    String? text,
    String confirmBtnText = "Ok",
  }) async {
    bool result = false;

    await CoolAlert.show(
      context: _ctx,
      type: CoolAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText.tr(),
      onConfirmBtnTap: () {
        result = true;
        _safePop();
      },
    );

    return result;
  }

  // -------------------------------
  // LOADING DIALOG
  // -------------------------------
  static void showLoading() {
    CoolAlert.show(
      context: _ctx,
      type: CoolAlertType.loading,
      title: "",
      text: "Processing. Please wait...".tr(),
      barrierDismissible: false,
    );
  }

  static void stopLoading() {
    _safePop();
  }
}

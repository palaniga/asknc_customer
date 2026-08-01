import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Asknc_user/constants/api.dart';
import 'package:Asknc_user/constants/app_file_limit.dart';
import 'package:Asknc_user/models/api_response.dart';
import 'package:Asknc_user/models/checkout.dart';
import 'package:Asknc_user/models/package_checkout.dart';
import 'package:Asknc_user/models/payment_method.dart';
import 'package:Asknc_user/models/service.dart';
import 'package:Asknc_user/models/vendor.dart';
import 'package:Asknc_user/services/http.service.dart';
import 'package:Asknc_user/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CheckoutRequest extends HttpService {
  //
  Future<List<PaymentMethod>> getPaymentOptions() async {
    final apiResult = await get(Api.paymentMethods);

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return PaymentMethod.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> newOrder(
    CheckOut checkout, {
    String note = "",
    String tip = "",
    List<Map>? fees = const [],
  }) async {
    final apiResult = await post(
      Api.orders,
      {
        "tip": tip,
        "note": note,
        "coupon_code": checkout.coupon?.code ?? "",
        "pickup_date": checkout.deliverySlotDate,
        "pickup_time": checkout.deliverySlotTime,
        "products": checkout.cartItems,
        "vendor_id": checkout.cartItems?.first.product?.vendorId,
        "delivery_address_id": checkout.deliveryAddress?.id,
        "payment_method_id": checkout.paymentMethod?.id,
        "sub_total": checkout.subTotal,
        "discount": checkout.discount,
        "delivery_fee": checkout.deliveryFee,
        "tax": checkout.tax,
        "fees": fees,
        "total": checkout.total,
      },
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> newMultipleVendorOrder(
    CheckOut checkout, {
    String note = "",
    String tip = "",
    required Map payload,
  }) async {
    Map<String, dynamic> orderPayload = {
      ...payload,
      "tip": tip,
      "note": note,
      "coupon_code": checkout.coupon?.code ?? "",
      "pickup_date": checkout.deliverySlotDate,
      "pickup_time": checkout.deliverySlotTime,
      "delivery_address_id": checkout.deliveryAddress?.id,
      "payment_method_id": checkout.paymentMethod?.id,
      "sub_total": checkout.subTotal,
      "discount": checkout.discount,
      "delivery_fee": checkout.deliveryFee,
      "tax": checkout.tax,
      "total": checkout.total,
    };

    log("Multiple Vendor Order Payload: $orderPayload");

    final apiResult = await post(
      Api.orders,
      orderPayload,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> newPackageOrder(
    PackageCheckout packageCheckout, {
    String? note,
  }) async {
    //fees
    List<Map> feesObjects = [];
    for (var fee in packageCheckout.vendor?.fees ?? []) {
      double calFee = 0;
      String feeName = fee.name;
      if (fee.isPercentage) {
        calFee = fee.getRate(packageCheckout.subTotal!);
        feeName = "$feeName (${fee.value}%)";
      } else {
        calFee = fee.value;
      }

      //
      feesObjects.add({
        "id": fee.id,
        "name": feeName,
        "amount": calFee.toStringAsFixed(2),
      });
      //
    }

    Map<String, dynamic> payload = {
      "type": "package",
      "note": note,
      "coupon_code": packageCheckout.coupon?.code ?? "",
      "package_type_id": packageCheckout.packageType?.id,
      "vendor_id": packageCheckout.vendor?.id,
      "pickup_date": packageCheckout.date,
      "pickup_time": packageCheckout.time,
      "stops": packageCheckout.allStops?.map((e) {
        return e?.toJson();
      }).toList(),
      "pickup_location": packageCheckout.allStops![0]!.deliveryAddress,
      "dropoff_location": packageCheckout
          .allStops![packageCheckout.allStops!.length - 1]!.deliveryAddress,
      "recipient_name": packageCheckout.recipientName,
      "recipient_phone": packageCheckout.recipientPhone,
      "weight": packageCheckout.weight,
      "width": packageCheckout.width,
      "length": packageCheckout.length,
      "height": packageCheckout.height,
      "payment_method_id": packageCheckout.paymentMethod?.id,
      "sub_total": (packageCheckout.subTotal! - (packageCheckout.deliveryFee))
          .toDouble()
          .toStringAsFixed(2),
      "discount": packageCheckout.discount!.toStringAsFixed(2),
      "delivery_fee": packageCheckout.deliveryFee.toStringAsFixed(2),
      "tax": packageCheckout.tax!.toStringAsFixed(2),
      "tax_rate": packageCheckout.taxRate!.toStringAsFixed(2),
      "token": packageCheckout.token,
      "payer": packageCheckout.payer,
      "fees": feesObjects,
      "total": packageCheckout.total!.toStringAsFixed(2),
    };

    if (kDebugMode) {
      log("Package Order Payload: ${jsonEncode(payload)}");
    }

    final apiResult = await post(
      Api.orders,
      payload,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> newServiceOrder(
    CheckOut checkout, {
    List<Map>? fees,
    required Service service,
    double? service_amount,
    String? note,
  }) async {
    //
    final params = {
      "type": "service",
      "note": note,
      "service_id": service.id,
      "vendor_id": service.vendor.id,
      "delivery_address_id": checkout.deliveryAddress?.id,
      "pickup_date": checkout.deliverySlotDate,
      "pickup_time": checkout.deliverySlotTime,
      "hours": service.selectedQty,
      "service_price": service_amount != null
          ? service_amount
          : service.showDiscount
              ? service.discountPrice
              : service.price,
      "payment_method_id": checkout.paymentMethod?.id,
      "sub_total": checkout.subTotal,
      "discount": checkout.discount,
      "delivery_fee": checkout.deliveryFee,
      "tax": checkout.tax,
      "total": checkout.total,
      "coupon_code": checkout.coupon?.code ?? "",
      "fees": fees,
    };

    //if there is selected options
    if (service.selectedOptions.isNotEmpty) {
      String optionFlatten = "";
      List<int> optionIds = [];
      for (var option in service.selectedOptions) {
        optionFlatten += "${option.name}";
        //add , if its not the last option
        if (service.selectedOptions.last.id != option.id) {
          optionFlatten += ", ";
        }

        optionIds.add(option.id);
      }

      //
      params.addAll({
        "options_flatten": optionFlatten,
        "options_ids": optionIds,
      });
    }
    //
    final apiResult = await post(
      Api.orders,
      params,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> newPrescriptionOrder(
    CheckOut checkout,
    Vendor vendor, {
    List<File>? photos,
    String note = "",
  }) async {
    final Map<String, dynamic> postBody = {
      "type": vendor.vendorType.slug,
      "note": note,
      "pickup_date": checkout.deliverySlotDate,
      "pickup_time": checkout.deliverySlotTime,
      "vendor_id": vendor.id,
      "delivery_address_id": checkout.deliveryAddress?.id,
      "sub_total": checkout.subTotal,
      "discount": checkout.discount,
      "delivery_fee": checkout.deliveryFee,
      "tax": checkout.tax,
      "total": checkout.total,
    };

    final formData = FormData.fromMap(postBody);

    if (photos != null && photos.isNotEmpty) {
      for (final File original in photos) {
        File file = original;

        // XFile: use .length()
        final fileSizeKB = (await file.length()) / 1024;

        // compress if needed
        if (fileSizeKB > AppFileLimit.prescriptionFileSizeLimit) {
          final compressedFile = await Utils.compressFile(
            file: File(file.path), // convert to File
            quality: 60,
          );

          if (compressedFile != null) {
            file = File(compressedFile.path); // convert compressed File → XFile
          }
        }

        formData.files.add(
          MapEntry(
            "photos[]",
            await MultipartFile.fromFile(file.path),
          ),
        );
      }
    }

    // send request
    return ApiResponse(); // replace with actual request logic
  }

  Future<double> orderSummary(
      {required int deliveryAddressId, required int vendorId}) async {
    final params = {
      "vendor_id": "${vendorId}",
      "delivery_address_id": "${deliveryAddressId}",
    };

    //
    final apiResult = await get(
      Api.generalOrderSummary,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return PackageCheckout.fromJson(apiResponse.body).deliveryFee;
    }

    throw apiResponse.message!;
  }
}

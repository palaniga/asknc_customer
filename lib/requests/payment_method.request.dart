import 'package:Asknc_user/constants/api.dart';
import 'package:Asknc_user/models/api_response.dart';
import 'package:Asknc_user/models/payment_method.dart';
import 'package:Asknc_user/services/http.service.dart';

class PaymentMethodRequest extends HttpService {
  //
  Future<List<PaymentMethod>> getPaymentOptions({
    int? vendorId,
    Map<String, dynamic>? params,
  }) async {
    //
    Map<String, dynamic> queryParameters = {
      ...(params != null ? params : {}),
      "vendor_id": vendorId,
    };

    final apiResult = await get(
      Api.paymentMethods,
      queryParameters: queryParameters,
    );

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

  Future<List<PaymentMethod>> getTaxiPaymentOptions() async {
    final apiResult = await get(
      Api.paymentMethods,
      queryParameters: {
        "use_taxi": 1,
      },
    );

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
}

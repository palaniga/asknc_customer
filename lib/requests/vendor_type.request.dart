import 'package:Asknc_user/constants/api.dart';
import 'package:Asknc_user/models/api_response.dart';
import 'package:Asknc_user/models/vendor_type.dart';
import 'package:Asknc_user/services/http.service.dart';
import 'package:Asknc_user/services/location.service.dart';

class VendorTypeRequest extends HttpService {
  //
  Future<List<VendorType>> index() async {
    final apiResult = await get(
      Api.vendorTypes,
      queryParameters: {
        "latitude": LocationService.currenctAddress?.coordinates?.latitude,
        "longitude": LocationService.currenctAddress?.coordinates?.longitude,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List)
          .map((e) => VendorType.fromJson(e))
          .toList();
    }

    throw apiResponse.message!;
  }
}

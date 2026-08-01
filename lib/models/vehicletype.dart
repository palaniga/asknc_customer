import 'package:Asknc_user/extensions/dynamic.dart';

class VehicleType {
  VehicleType({
    required this.id,
    required this.name,
    required this.slug,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.minFare,
    required this.isActive,
    required this.formattedDate,
    required this.photo,
  });

  int id;
  String name;
  String slug;
  double baseFare;
  double distanceFare;
  double timeFare;
  double minFare;
  int isActive;
  String formattedDate;
  String photo;

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    baseFare: json["base_fare"].toString().toDouble(),
    distanceFare: json["distance_fare"].toString().toDouble(),
    timeFare: json["time_fare"].toString().toDouble(),
    minFare: json["min_fare"].toString().toDouble(),
    isActive: json["is_active"],
    formattedDate: json["formatted_date"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "base_fare": baseFare,
    "distance_fare": distanceFare,
    "time_fare": timeFare,
    "min_fare": minFare,
    "is_active": isActive,
    "formatted_date": formattedDate,
    "photo": photo,
  };
}
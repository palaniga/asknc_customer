import 'dart:async';

import 'package:Asknc_user/models/order.dart';
import 'package:Asknc_user/models/payment_method.dart';
import 'package:Asknc_user/models/vehicle_type.dart';
import 'package:Asknc_user/requests/payment_method.request.dart';
import 'package:Asknc_user/requests/taxi.request.dart';
import 'package:Asknc_user/view_models/taxi_google_map.vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../models/delivery_address.dart';

class TripTaxiViewModel extends TaxiGoogleMapViewModel {
  // === Requests ===
  final TaxiRequest taxiRequest = TaxiRequest();
  final PaymentMethodRequest paymentOptionRequest = PaymentMethodRequest();

  // === Trip & state ===
  Order? onGoingOrderTrip;
  double newTripRating = 3.0;
  TextEditingController tripReviewTEC = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  bool _driverTrackingActive = false;
  bool _erasePolylineOnMove = false;
  bool _driverHasStartedMoving = false;
  StreamSubscription? tripUpdateStream;
  StreamSubscription<DocumentSnapshot>? driverLocationStream;

  LatLng? driverPosition;
  double driverPositionRotation = 0;
  bool _driverPolylineDrawn = false;
  Timer? _zoomDebounce;

  List<PaymentMethod> paymentMethods = [];
  PaymentMethod? selectedPaymentMethod;
  List<VehicleType> vehicleTypes = [];
  VehicleType? selectedVehicleType;

  // === Helper ===
  void _debounceZoomFocusDriver() {
    _zoomDebounce?.cancel();
    _zoomDebounce = Timer(const Duration(seconds: 2), () {
      startZoomFocusDriver();
    });
  }

  // === On app/window resume ===
  Future<void> resumeDriverTrackingIfNeeded() async {
    if (_driverTrackingActive) return;
    final status = onGoingOrderTrip?.status;
    if (status == "preparing") {
      debugPrint("Resuming driver tracking...");
      _startDriverTracking();
    } else if (onGoingOrderTrip == null) {
      // Refresh trip info if not loaded
      getOnGoingTrip();
    }
  }

  // === Get ongoing trip ===
  void getOnGoingTrip() async {
    setBusyForObject(onGoingOrderTrip, true);
    try {
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      if (onGoingOrderTrip != null) {
        await loadTripUIByOrderStatus(initial: true);
      } else {
        clearMapData();
      }
    } catch (error) {
      debugPrint("getOnGoingTrip error: $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  // === Cancel trip ===
  void cancelTrip() async {
    setBusyForObject(onGoingOrderTrip, true);
    try {
      final apiResponse = await taxiRequest.cancelTrip(onGoingOrderTrip!.id);
      if (apiResponse.allGood) {
        toastSuccessful(
            apiResponse.message ?? "Trip cancelled successfully".tr());
        setCurrentStep(1);
        clearMapData();
      } else {
        toastError(apiResponse.message ?? "Failed to cancel trip".tr());
      }
    } catch (error) {
      debugPrint("cancelTrip error: $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  // === Load UI based on order status ===
  Future<void> loadTripUIByOrderStatus({bool initial = false}) async {
    if (initial) {
      pickupLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.pickupLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.pickupLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.pickupAddress,
      );

      dropoffLocation = DeliveryAddress(
        latitude: onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull(),
        longitude:
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull(),
        address: onGoingOrderTrip?.taxiOrder?.dropoffAddress,
      );

      await drawTripPolyLines();
      startHandlingOnGoingTrip();

      // ✅ Auto-resume driver tracking if reopening app in "preparing" state
      resumeDriverTrackingIfNeeded();
      return;
    }

    if (onGoingOrderTrip == null) {
      setCurrentStep(1);
      clearMapData();
      stopAllListeners();
      closeOrderSummary();
      return;
    }

    switch (onGoingOrderTrip?.status) {
      case "pending":
        setCurrentStep(3);
        break;

      case "preparing":
        setCurrentStep(4);
        _startDriverTracking();
        break;

      case "ready":
      case "enroute":
        setCurrentStep(4);
        break;

      case "delivered":
        setCurrentStep(1);
        clearMapData();
        zoomToLocation(
          LatLng(
            onGoingOrderTrip?.taxiOrder?.dropoffLatitude.toDoubleOrNull() ??
                0.0,
            onGoingOrderTrip?.taxiOrder?.dropoffLongitude.toDoubleOrNull() ??
                0.0,
          ),
        );
        stopAllListeners();
        break;

      case "failed":
      case "cancelled":
        setCurrentStep(1);
        clearMapData();
        stopAllListeners();
        closeOrderSummary();
        break;

      default:
        break;
    }
  }

  // === Track driver movement ===
  void _startDriverTracking() {
    driverLocationStream?.cancel();
    _driverTrackingActive = true;

    final driverId = onGoingOrderTrip?.driverId ?? onGoingOrderTrip?.driver?.id;
    if (driverId == null) return;

    LatLng? lastDriverPosition;

    driverLocationStream = firebaseFirestore
        .collection("drivers")
        .doc(driverId.toString())
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      final lat = (data?["lat"] as num?)?.toDouble();
      final lng = (data?["long"] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPosition = LatLng(lat, lng);
      double movementDistance = 0.0;
      // Ignore very small movement
      if (lastDriverPosition != null) {
        final movementDistance = Geolocator.distanceBetween(
          lastDriverPosition!.latitude,
          lastDriverPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        if (movementDistance < 2) return; // Skip minor jitter
      }
      if (!_driverHasStartedMoving && movementDistance > 5) {
        _driverHasStartedMoving = true;
        _erasePolylineOnMove = true;
      }
      lastDriverPosition = newPosition;
      driverPosition = newPosition;
      driverPositionRotation = (data?["rotation"] as num?)?.toDouble() ?? 0.0;
      // ✅ If driver started moving → erase polyline
      if (_erasePolylineOnMove) {
        gMapPolylines
            .removeWhere((p) => p.polylineId.value == "driverPickupPoly");
        _erasePolylineOnMove = false;
      }

      // ✅ ERASE POLYLINE WHEN DRIVER MOVES
      // gMapPolylines
      //     .removeWhere((p) => p.polylineId.value == "driverPickupPoly");
      // === Update Driver Marker ===
      gMapMarkers.removeWhere((m) => m.markerId.value == "driverMarker");
      gMapMarkers.add(
        Marker(
          markerId: const MarkerId("driverMarker"),
          position: driverPosition!,
          rotation: driverPositionRotation,
          icon: driverIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          anchor: const Offset(0.5, 0.5),
        ),
      );

      notifyListeners();

      // === Polyline & Camera Update ===
      final pickupLat =
          onGoingOrderTrip?.taxiOrder?.pickupLatitude.toDoubleOrNull() ?? 0.0;
      final pickupLng =
          onGoingOrderTrip?.taxiOrder?.pickupLongitude.toDoubleOrNull() ?? 0.0;

      await drawDriverPickupPolyLines(
        driverPosition: newPosition,
        pickupPosition: LatLng(pickupLat, pickupLng),
      );

      // === Smooth Follow Camera ===
      _debounceZoomFocusDriver();
    });
  }

  // === Listen for trip updates ===
  void startHandlingOnGoingTrip() {
    if (onGoingOrderTrip == null) return;

    setCurrentStep(3);
    tripUpdateStream?.cancel();

    tripUpdateStream = firebaseFirestore
        .collection("orders")
        .doc(onGoingOrderTrip?.code)
        .snapshots()
        .listen((event) async {
      if (!event.exists) return;

      final data = event.data()!;
      final driverId = data["driver_id"];
      final status = data["status"];

      if (driverId != null && onGoingOrderTrip?.driverId == null) {
        onGoingOrderTrip?.driverId = driverId;
        await loadDriverDetails();
      }

      onGoingOrderTrip?.status = status;
      await loadTripUIByOrderStatus();
      notifyListeners();
    });
  }

  // === Load driver details ===
  Future<void> loadDriverDetails() async {
    try {
      final mDriverId = onGoingOrderTrip?.driverId;
      onGoingOrderTrip = await taxiRequest.getOnGoingTrip();
      if (onGoingOrderTrip?.driver == null && mDriverId != null) {
        onGoingOrderTrip?.driver = await taxiRequest.getDriverInfo(mDriverId);
      }
      notifyListeners();
    } catch (error) {
      debugPrint("loadDriverDetails error: $error");
    }
  }

  // === Update driver marker ===
  void updateDriverMarkerPosition() {
    if (driverPosition == null) return;
    final existingMarker =
        gMapMarkers.firstOrNullWhere((e) => e.markerId.value == "driverMarker");
    final updatedMarker = (existingMarker != null)
        ? existingMarker.copyWith(
            positionParam: driverPosition,
            rotationParam: driverPositionRotation,
          )
        : Marker(
            markerId: const MarkerId('driverMarker'),
            position: driverPosition!,
            rotation: driverPositionRotation,
            icon: driverIcon ?? BitmapDescriptor.defaultMarker,
            anchor: const Offset(0.5, 0.5),
          );
    gMapMarkers.removeWhere((e) => e.markerId.value == "driverMarker");
    gMapMarkers.add(updatedMarker);
    notifyListeners();
  }

  // === Focus camera ===
  void startZoomFocusDriver() {
    if (driverPosition == null || onGoingOrderTrip == null) return;

    if (onGoingOrderTrip!.canZoomOnPickupLocation && pickupLocation != null) {
      updateCameraLocation(
        driverPosition!,
        LatLng(pickupLocation!.latitude!, pickupLocation!.longitude!),
        googleMapController,
      );
    } else if (onGoingOrderTrip!.canZoomOnDropoffLocation &&
        dropoffLocation != null) {
      updateCameraLocation(
        driverPosition!,
        LatLng(dropoffLocation!.latitude!, dropoffLocation!.longitude!),
        googleMapController,
      );
    }
  }

  // === Stop all listeners ===
  void stopAllListeners() {
    tripUpdateStream?.cancel();
    driverLocationStream?.cancel();
    _driverTrackingActive = false; // ✅ reset flag when stopped
  }

  // === Rating ===
  void dismissTripRating() {
    tripReviewTEC.clear();
    setCurrentStep(1);
  }

  Future<void> submitTripRating() async {
    setBusyForObject(newTripRating, true);
    final apiResponse = await taxiRequest.rateDriver(
      onGoingOrderTrip!.id,
      onGoingOrderTrip!.driverId!,
      newTripRating,
      tripReviewTEC.text,
    );

    if (apiResponse.allGood) {
      toastSuccessful(apiResponse.message ?? "Trip rated successfully".tr());
      dismissTripRating();
    } else {
      toastError(apiResponse.message ?? "Failed to rate trip".tr());
    }
    setBusyForObject(newTripRating, false);
  }

  // === Close order summary ===
  void closeOrderSummary({bool clear = true}) {
    if (clear) {
      pickupLocation = null;
      dropoffLocation = null;
      pickupLocationTEC.clear();
      dropoffLocationTEC.clear();
      selectedVehicleType = null;
      selectedPaymentMethod = paymentMethods.firstOrNull;
      notifyListeners();
    }
    clearMapData();
    setCurrentStep(1);
  }
}

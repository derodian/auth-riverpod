import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<Location?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      return locations.isNotEmpty ? locations.first : null;
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      return null;
    }
  }

  Future<double?> getDistanceToAddress(String address) async {
    try {
      final currentLocation = await getCurrentLocation();
      if (currentLocation == null) return null;

      final targetLocation = await getLocationFromAddress(address);
      if (targetLocation == null) return null;

      return Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        targetLocation.latitude,
        targetLocation.longitude,
      );
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
LocationService locationService(LocationServiceRef ref) {
  return LocationService();
}

@riverpod
Future<double?> distanceToAddress(
  DistanceToAddressRef ref,
  String address,
) async {
  return ref.watch(locationServiceProvider).getDistanceToAddress(address);
}

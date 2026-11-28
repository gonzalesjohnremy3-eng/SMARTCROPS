import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// What the phone could tell us about where the Farmer is.
sealed class PlaceResult {
  const PlaceResult();
}

/// A place, as named by the phone. Names are matched loosely against the
/// official list afterwards.
class PlaceFound extends PlaceResult {
  const PlaceFound({this.barangay, this.area});

  final String? barangay;
  final String? area;
}

/// The Farmer did not allow location access.
class PlaceDenied extends PlaceResult {
  const PlaceDenied();
}

/// The phone's location switch is off.
class PlaceServiceOff extends PlaceResult {
  const PlaceServiceOff();
}

/// Location could not be worked out (no signal, no address for it, an error).
class PlaceUnavailable extends PlaceResult {
  const PlaceUnavailable();
}

abstract class DevicePlaceFinder {
  Future<PlaceResult> findCurrentPlace();
}

/// Asks for permission only when [findCurrentPlace] is called, never earlier.
class GeolocatorPlaceFinder implements DevicePlaceFinder {
  const GeolocatorPlaceFinder();

  @override
  Future<PlaceResult> findCurrentPlace() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const PlaceServiceOff();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const PlaceDenied();
      }

      // A barangay is a few hundred metres across, so a coarse, quick fix is
      // enough and saves the battery.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final marks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (marks.isEmpty) return const PlaceUnavailable();

      final mark = marks.first;
      return PlaceFound(
        barangay: _firstNonEmpty([mark.subLocality, mark.name]),
        area: _firstNonEmpty([mark.locality, mark.subAdministrativeArea]),
      );
    } catch (_) {
      return const PlaceUnavailable();
    }
  }
}

String? _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return null;
}

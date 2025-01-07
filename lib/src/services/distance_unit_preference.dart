import 'package:auth_riverpod/src/features/widgets/address_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distance_unit_preference.g.dart';

@riverpod
class DistanceUnitPreference extends _$DistanceUnitPreference {
  @override
  DistanceUnit build() {
    return DistanceUnit.both; // Default to showing both units
  }

  void setUnit(DistanceUnit unit) {
    state = unit;
  }
}

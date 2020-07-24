
import 'mi_scale_unit.dart';

class MiScaleData {
  /// ID of the device this data was parsed from.
  final String deviceId;
  final double weight;

  /// Value is `true` if the weight has stabilized.
  final bool weightStabilized;

  /// Value is `true` if the device is done measuring.
  /// This value is usually given after other measurements (such as body fat) have been completed as well.
  final bool measurementComplete;

  /// Value is `true` if there is no weight detected.
  final bool weightRemoved;

  /// The currently configured weight unit on the device.
  final MiScaleUnit unit;

  /// The timestamp given by the device.
  ///
  /// Note that this value must only be considered valid if [weightRemoved] is `false` and [weightStabilized] is `true`.
  /// This can also be checked by calling [dateTimeValid]
  final DateTime dateTime;

  MiScaleData({
    this.deviceId,
    this.weight,
    this.weightStabilized,
    this.measurementComplete,
    this.weightRemoved,
    this.unit,
    this.dateTime,
  });

  bool get dateTimeValid => weightStabilized && !weightRemoved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiScaleData &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          weightStabilized == other.weightStabilized &&
          measurementComplete == other.measurementComplete &&
          weightRemoved == other.weightRemoved &&
          unit == other.unit &&
          dateTime == other.dateTime;

  @override
  int get hashCode =>
      weight.hashCode ^
      weightStabilized.hashCode ^
      measurementComplete.hashCode ^
      weightRemoved.hashCode ^
      unit.hashCode ^
      dateTime.hashCode;

  @override
  String toString() {
    return 'MiScaleData{deviceId: $deviceId, weight: $weight, weightStabilized: $weightStabilized, measurementComplete: $measurementComplete, weightRemoved: $weightRemoved, unit: $unit, dateTime: $dateTime, dateTimeValid: $dateTimeValid}';
  }
}

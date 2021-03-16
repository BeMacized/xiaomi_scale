import 'package:uuid/uuid.dart';

import 'mi_scale_data.dart';
import 'mi_scale_unit.dart';

const Uuid _uuid = Uuid();

enum MiScaleMeasurementStage {
  /// Person has stepped off the scale before the scale has stabilized
  WEIGHT_REMOVED,

  /// Person is on the scale, but the measurement is not stable yet
  MEASURING,

  /// Person is on the scale and the scale has stabilized. Scale is still be taking other measurements (Body fat, etc)
  STABILIZED,

  /// Measurement has fully completed.
  MEASURED,
}

class MiScaleMeasurement {
  /// The unique id of the measurement in uuid v4 format
  final String id;

  /// The id given to the device used for this measurement
  final String? deviceId;

  /// The weight associated with this measurement
  ///
  /// The weight does not change anymore after [stage] has turned to [MiScaleMeasurementStage.STABILIZED]
  final double weight;

  /// The current stage this measurement is at.
  ///
  /// Starts out on [MiScaleMeasurementStage.MEASURING]
  /// When a person steps off the scale before reaching [MiScaleMeasurementStage.STABILIZED], it will move on to [MiScaleMeasurementStage.WEIGHT_REMOVED] instead.
  /// When a person steps off the scale after reaching [MiScaleMeasurementStage.STABILIZED], but before reaching [MiScaleMeasurementStage.MEASURED], the measurement will automatically move on to [MiScaleMeasurementStage.MEASURED].
  final MiScaleMeasurementStage stage;

  /// The weight unit for the current measurement, based on the device configuration
  final MiScaleUnit unit;

  /// The timestamp associated with this measurement.
  ///
  /// By default, it is based on the current host time, not the current device (scale) time.
  final DateTime dateTime;

  MiScaleMeasurement({
    required this.weight,
    required this.stage,
    required this.unit,
    this.deviceId,
    String? id,
    DateTime? dateTime,
  })  : dateTime = dateTime ?? DateTime.now(),
        id = id ?? _uuid.v4();

  bool get isActive => stage != MiScaleMeasurementStage.MEASURED;

  static MiScaleMeasurement? processData(
      MiScaleMeasurement? previousMeasurement, MiScaleData scaleData) {
    // Start new measurement if new weight is detected
    if (previousMeasurement == null &&
        !scaleData.weightRemoved &&
        !scaleData.measurementComplete) {
      return MiScaleMeasurement(
        weight: scaleData.weight,
        stage: MiScaleMeasurementStage.MEASURING,
        unit: scaleData.unit,
      );
    }

    // From this point we assume a measurement is already taking place.
    if (previousMeasurement == null) return null;

    // Update measurement if we're still measuring
    if (previousMeasurement.stage == MiScaleMeasurementStage.MEASURING &&
        !scaleData.weightStabilized &&
        !scaleData.measurementComplete &&
        !scaleData.weightRemoved) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: scaleData.weight,
        stage: MiScaleMeasurementStage.MEASURING,
        unit: scaleData.unit,
      );
    }

    // Handle person stepping off mid measurement
    if (previousMeasurement.stage == MiScaleMeasurementStage.MEASURING &&
        scaleData.weightRemoved &&
        !scaleData.measurementComplete) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: 0,
        stage: MiScaleMeasurementStage.WEIGHT_REMOVED,
        unit: scaleData.unit,
      );
    }

    // Handle person stepping back on mid measurement
    if (previousMeasurement.stage == MiScaleMeasurementStage.WEIGHT_REMOVED &&
        !scaleData.weightRemoved &&
        !scaleData.measurementComplete) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: scaleData.weight,
        stage: scaleData.weightStabilized
            ? MiScaleMeasurementStage.STABILIZED
            : MiScaleMeasurementStage.MEASURING,
        unit: scaleData.unit,
      );
    }

    // Lock measurement if we've just stabilized
    if (previousMeasurement.stage == MiScaleMeasurementStage.MEASURING &&
        !scaleData.weightRemoved &&
        scaleData.weightStabilized) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: scaleData.weight,
        stage: MiScaleMeasurementStage.STABILIZED,
        unit: scaleData.unit,
      );
    }

    // Handle person stepping off after stabilizing, before done measuring
    if (previousMeasurement.stage == MiScaleMeasurementStage.STABILIZED &&
        !scaleData.measurementComplete &&
        scaleData.weightRemoved) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: previousMeasurement.weight,
        stage: MiScaleMeasurementStage.MEASURED,
        unit: scaleData.unit,
      );
    }

    // Finalize measurement if we are done measuring
    if (previousMeasurement.stage == MiScaleMeasurementStage.STABILIZED &&
        scaleData.measurementComplete) {
      return MiScaleMeasurement(
        id: previousMeasurement.id,
        weight: previousMeasurement.weight,
        stage: MiScaleMeasurementStage.MEASURED,
        unit: scaleData.unit,
      );
    }

    // Otherwise just return the previous measurement
    return previousMeasurement;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiScaleMeasurement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceId == other.deviceId &&
          weight == other.weight &&
          stage == other.stage &&
          unit == other.unit &&
          dateTime == other.dateTime;

  @override
  int get hashCode =>
      id.hashCode ^
      deviceId.hashCode ^
      weight.hashCode ^
      stage.hashCode ^
      unit.hashCode ^
      dateTime.hashCode;
}

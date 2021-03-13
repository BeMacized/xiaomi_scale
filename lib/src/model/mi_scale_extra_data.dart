import 'package:xiaomi_scale/src/model/gender.dart';

class MiScaleExtraData {
  final Gender gender;
  final int age;
  final double height;
  final double weight;
  final int impedance;

  const MiScaleExtraData({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.impedance,
  });

  double get lbmCoefficient {
    var lbm = (height * 9.058 / 100.0) * (height / 100.0);
    lbm += weight * 0.32 + 12.226;
    lbm -= impedance * 0.0068;
    lbm -= age * 0.0542;

    return lbm;
  }

  double get bmi {
    return weight / (((height * height) / 100.0) / 100.0);
  }

  double get muscleMass {
    var muscleMass = weight - ((bodyFat * 0.01) * weight) - boneMass;

    if (gender == Gender.FEMALE && muscleMass >= 84.0) {
      muscleMass = 120.0;
    } else if (gender == Gender.MALE && muscleMass >= 93.5) {
      muscleMass = 120.0;
    }

    return muscleMass;
  }

  double get water {
    double coeff;
    final water = (100.0 - bodyFat) * 0.7;

    if (water < 50) {
      coeff = 1.02;
    } else {
      coeff = 0.98;
    }

    return coeff * water;
  }

  double get boneMass {
    double boneMass;
    double base;

    if (gender == Gender.FEMALE) {
      base = 0.245691014;
    } else {
      base = 0.18016894;
    }

    boneMass = (base - (lbmCoefficient * 0.05158)) * -1.0;

    if (boneMass > 2.2) {
      boneMass += 0.1;
    } else {
      boneMass -= 0.1;
    }

    if (gender == Gender.FEMALE && boneMass > 5.1) {
      boneMass = 8.0;
    } else if (gender == Gender.MALE && boneMass > 5.2) {
      boneMass = 8.0;
    }

    return boneMass;
  }

  double get visceralFat {
    var visceralFat = 0.0;
    if (gender == Gender.FEMALE) {
      if (weight > (13.0 - (height * 0.5)) * -1.0) {
        final subsubcalc = ((height * 1.45) + (height * 0.1158) * height) - 120.0;
        final subcalc = weight * 500.0 / subsubcalc;
        visceralFat = (subcalc - 6.0) + (age * 0.07);
      } else {
        final subcalc = 0.691 + (height * -0.0024) + (height * -0.0024);
        visceralFat = (((height * 0.027) - (subcalc * weight)) * -1.0) + (age * 0.07) - age;
      }
    } else if (gender == Gender.MALE) {
      if (height < weight * 1.6) {
        final subcalc = ((height * 0.4) - (height * (height * 0.0826))) * -1.0;
        visceralFat = ((weight * 305.0) / (subcalc + 48.0)) - 2.9 + (age * 0.15);
      } else {
        final subcalc = 0.765 + height * -0.0015;
        visceralFat = (((height * 0.143) - (weight * subcalc)) * -1.0) + (age * 0.15) - 5.0;
      }
    }

    return visceralFat;
  }

  double get bodyFat {
    var bodyFat = 0.0;
    var lbmSub = 0.8;

    if (gender == Gender.FEMALE && age <= 49) {
      lbmSub = 9.25;
    } else if (gender == Gender.MALE && age > 49) {
      lbmSub = 7.25;
    }

    final lbmCoeff = lbmCoefficient;
    var coeff = 1.0;

    if (gender == Gender.MALE && weight < 61.0) {
      coeff = 0.98;
    } else if (gender == Gender.FEMALE && weight > 60.0) {
      coeff = 0.96;

      if (height > 160.0) {
        coeff *= 1.03;
      }
    } else if (gender == Gender.FEMALE && weight < 50.0) {
      coeff = 1.02;

      if (height > 160.0) {
        coeff *= 1.03;
      }
    }

    bodyFat = (1.0 - (((lbmCoeff - lbmSub) * coeff) / weight)) * 100.0;

    if (bodyFat > 63.0) {
      bodyFat = 75.0;
    }

    return bodyFat;
  }
}

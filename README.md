# xiaomi_scale

[![pub package](https://img.shields.io/pub/v/xiaomi_scale.svg)](https://pub.dartlang.org/packages/xiaomi_scale)

A Flutter plugin to take measurements from Xiaomi weight scales.

<img src="https://raw.githubusercontent.com/BeMacized/xiaomi_scale/master/readme_res/screenshots.png" alt="App Screenshots" width="512">

**What it does:**

* Track measurements
  * Weight
  * Device weight unit (kg/lbs)
  * Progress (e.g. Measuring -> Stabilized -> Measured)
* Scan for nearby Xiaomi scales
* Direct scale data
  * Weight
  * Device weight unit
  * Device timestamp
  * Flags
    * Weight stabilized
    * Weight removed
    * Measurement completes

**What it does NOT do:**

* Sync historical data stored on device
* Configure the device settings

## Supported devices

| **Image**                                                    | **Name**                    |
| ------------------------------------------------------------ | --------------------------- |
| <img src="https://raw.githubusercontent.com/BeMacized/xiaomi_scale/master/readme_res/scale_v2.jpg" alt="Mi Body Composition Scale 2" width="128"> | Mi Body Composition Scale 2 |

I am still looking to support the **Xiaomi Scale (v1)** as well (The one without the 4 electrodes on top).
I only have access to the v2 model, and therefore am not able to test. In case you have access to one and are willing to help out, please get in contact!

## How to use

First of all I can recommend to just take a look at the [example](https://github.com/BeMacized/xiaomi_scale/tree/master/example).

### Setup iOS

Min iOS Development Target => 11
This is because of flutter_reactive_ble

Add a description why you want to use the bluetooth peripherals in the info.plist
iOS13 and higher
```
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>Connect to xiaomi scale to get weight</string>
```

iOS12 and lower
```
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>Connect to xiaomi scale to get weight</string>
```

No need to ask for runtime permission. This is already handled by flutter_reactive_ble
Best practice: 
    You should check if the permission is already given. if not show a message to the user. You can only request the permission once.
    After that you should check the status of the permission yourself. (this is not handled by this package or flutter_reactive_ble)

### Setup Android

Min sdk Development Target => 24
This is because of flutter_reactive_ble

flutter_reactive_ble adds these permissions automaticly
```
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
```

At runtime you should still request the location permissions yourself. Otherwise the app won't work.

### Setup Dart


For the examples below, grab an instance of `MiScale` first.

```typescript
MiScale _mi = MiScale.instance;
```

### Tracking measurements

You can keep track of measurements as follows:

```typescript
StreamSubscription subscription =
    _mi.takeMeasurements().listen((MiScaleMeasurement measurement) {
  // Code for handing measurement
});

// Stop taking measurements
subscription.cancel();
```

#### Cancelling measurements

Measurements must be cancelled before a new measurement can be started for the same device. Measurements are automatically cancelled when they reached the final `MEASURED` stage.

In case you would like to cancel a measurement before the `MEASURED` stage is reached, it is up to you to cancel the measurement manually.

```typescript
_mi.cancelMeasurement(deviceId)
```

You can obtain the `deviceId` either from a `MiScaleMeasurement` or `MiScaleDevice` instance.

**Note:** If a user steps off the scale before the `STABILIZED` stage is reached, the measurement will remain incomplete. Hence, if you want to take a new measurement, you must also cancel the incomplete measurement first

### Scanning for devices

The `discoverDevices` stream will only output compatible devices that it finds.

```typescript
StreamSubscription subscription = _mi.discoverDevices(
  duration: Duration(seconds: 10), // Optional, default is 5 seconds
).listen(
  (MiScaleDevice device) {
    // Code for handling found device
  },
);

// Stop discovering before given duration has expired
subscription?.cancel();
```

### Getting all scale data

If you want to get the scale data directly without tracking measurements, you can do so as follows:

```typescript
StreamSubscription subscription = _mi.readScaleData().listen(
        (data) {
          // Code to handle the scale data
        },
      );

// Stop reading data
subscription.cancel();
```

## How to adjust ProGuard (Android)
In case you are using ProGuard add the following snippet to your proguard-rules.pro file:

```
-keep class com.signify.hue.** { *; }
```

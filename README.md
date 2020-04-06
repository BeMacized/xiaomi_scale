# xiaomi_scale

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

**Note:** Make sure before using any functionality of this library, that permission has been given to scan for bluetooth devices. On Android, this is the `ACCESS_COARSE_LOCATION` permission.

For the examples below, grab an instance of `MiScale` first.

```typescript
MiScale _mi = MiScale.instance;
```

### Tracking measurements

You can keep track of measurements as follows:

```typescript
StreamSubscription subscription =
    _scale.takeMeasurements().listen((MiScaleMeasurement measurement) {
  // Code for handing measurement
});

// Stop taking measurements
subscription.cancel();
```

#### Cancelling measurements

Measurements must be cancelled before a new measurement can be started for the same device. Measurements are automatically cancelled when they reached the final `MEASURED` stage.

In case you would like to cancel a measurement before the `MEASURED` stage is reached, it is up to you to cancel the measurement manually.

```typescript
_scale.cancelMeasurement(deviceId)
```

You can obtain the `deviceId` either from a `MiScaleMeasurement` or `MiScaleDevice` instance.

**Note:** If a user steps off the scale before the `STABILIZED` stage is reached, the measurement will remain incomplete. Hence, if you want to take a new measurement, you must also cancel the incomplete measurement first

### Scanning for devices

The `discoverDevices` stream will only output compatible devices that it finds.

```typescript
StreamSubscription subscription = _scale.discoverDevices(
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
StreamSubscription subscription = _scale.readScaleData().listen(
        (data) {
          // Code to handle the scale data
        },
      );

// Stop reading data
subscription.cancel();
```


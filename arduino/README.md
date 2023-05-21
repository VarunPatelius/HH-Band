# HH Band - Embedded Device

This section of the repository features the code which runs on the Arduino Nano RP2040 Connect, which is worn by each athlete to provide communication betweem them and the coach's mobile device.

## Parts

- [Arduino Nano RP2040 Connect](https://store-usa.arduino.cc/products/arduino-nano-rp2040-connect-with-headers)
- [Space Trek MakerBox](https://spacetrek.com/) (Provided by Samsung to State Winners)
    - Temperature Probe
    - Vibration Motor

## Code

The code running on the board is extremely simple and essentially pieces together the Arduino example sketch for BLE connectivity and Space Trek's example code for reading values from the thermistor.

The only changes made to the [example code provided by Space Trek](https://github.com/SpaceTrekKSC/EasyStarterKit/blob/main/src/EasyStarterKitTemperature.h) was increasing the analog read resolution to 12-bits as that is the highest the board can handle and changing the value to 4096 for the higher clarity.


## Logic

Once connected to a central device, the board will begin reading data from the thermistor and send that data over to the mobile device. If the temperature passes the hardcoded threshold, which is 80°F, then the vibration motor on the device will go off and will not stop until the temperature has come down.
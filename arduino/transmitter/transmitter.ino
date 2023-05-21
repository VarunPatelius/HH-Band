/* 
Made by Varun Patel - BlueHandCoding
Last Updated: Wed April 19, 2023

https://www.varunpatel.net/
https://www.bluehandcoding.com/

All credits must be given to original author
*/

#include <ArduinoBLE.h>
#include "tempSensor.h"

#define VIBRATION_PIN 15
#define THRESHOLD 80

BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy LED Service

// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEByteCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead);

Temperature temper(A0);
int celsius;

void setup() {
  Serial.begin(9600);
  pinMode(VIBRATION_PIN, OUTPUT);
  digitalWrite(VIBRATION_PIN, LOW);

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");

    while (1);
  }

  // set advertised local name and service UUID:
  BLE.setLocalName("Arduino");
  BLE.setAdvertisedService(ledService);

  // add the characteristic to the service
  ledService.addCharacteristic(switchCharacteristic);

  // add service
  BLE.addService(ledService);

  // set the initial value for the characeristic:
  switchCharacteristic.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("BLE LED Peripheral");
}

void loop() {
  // listen for Bluetooth® Low Energy peripherals to connect:
  BLEDevice central = BLE.central();

  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());

    // while the central is still connected to peripheral:
    while (central.connected()) {
      switchCharacteristic.writeValue(celsius);
      celsius = temper.getTemperature(); 
      Serial.println(celsius);

      if (celsius > THRESHOLD) {
        digitalWrite(VIBRATION_PIN, HIGH);
        delay(2000);
      }

      digitalWrite(VIBRATION_PIN, LOW);

      delay(100);
    }

    // when the central disconnects, print it out:
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
}
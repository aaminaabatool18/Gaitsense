# GaitSense — Hardware Development

**Project:** IoT-Based Wearable System for Real-Time Gait Anomaly Detection and Sensory Cueing

**Project ID:** FYP-26F-0065

## Hardware Components

- ESP32 DevKit V1
- MPU accelerometer and gyroscope module
- LED with 220Ω resistor
- Breadboard and jumper wires
- 3V vibration motor (pending integration)
- Compatible motor driver (pending integration)

## Hardware Objectives

1. Collect motion data using the MPU sensor.
2. Process acceleration and gyroscope measurements using ESP32.
3. Detect movement patterns using rule-based algorithms.
4. Identify possible freezing-of-gait-like events in later development.
5. Provide sensory feedback through vibration.
6. Send motion events to Firebase.

## Current Progress

- Successfully configured and programmed the ESP32.
- Established I²C communication with the MPU sensor using GPIO 21 (SDA) and GPIO 22 (SCL).
- Implemented real-time accelerometer and gyroscope readings.
- Configured a target sampling frequency of 50 Hz.
- Implemented motion analysis using mean, variance, and standard deviation.
- Developed preliminary rule-based detection for active and low-motion states.
- Implemented automatic LED cueing when sustained low motion follows active movement.
- Successfully tested live sensor visualization using Arduino Serial Plotter.
- Added code for combined plotting and LED cueing; final integrated testing is pending.
- Uploaded the current Arduino firmware to GitHub.

## Current Detection Method

The ESP32 continuously collects motion measurements from the MPU sensor.

The firmware analyzes these readings in windows of 50 samples and calculates statistical features to classify movement.

When active movement is followed by two consecutive windows of low motion, the system triggers an LED cue.

**Note:** The current prototype detects general motion transitions. It does not yet reliably distinguish freezing of gait from normal stopping.

## Pending Tasks

- Verify the combined firmware on the ESP32.
- Integrate the vibration motor with a suitable driver and power supply.
- Implement Firebase event logging.
- Improve the algorithm to recognize gait-specific movement patterns.
- Test and validate the complete wearable prototype.

## Firmware

The Arduino source code is available in `gaitsense.ino`.


#include <Wire.h>
#include <math.h>

const byte sensorAddress = 0x68;
const int ledPin = 23;

// 50 Hz sampling
const unsigned long sampleInterval = 20000;
const int windowSize = 50;

unsigned long lastSampleTime = 0;
bool sensorReady = false;

// Motion statistics
int sampleCount = 0;

float gyroSum = 0;
float gyroSquareSum = 0;
float accelSum = 0;
float accelSquareSum = 0;

// Experimental motion thresholds
const float LOW_GYRO_STD = 3.0f;
const float LOW_ACCEL_STD = 0.025f;

const float ACTIVE_GYRO_STD = 6.0f;
const float ACTIVE_ACCEL_STD = 0.060f;

// Previous motion state
bool wasMoving = false;
int lowMotionWindows = 0;

// LED cue timing
bool cueActive = false;
unsigned long cueStart = 0;

// Output values for plotting
int motionChangeFlag = 0;
int cueFlag = 0;

// Read signed 16-bit sensor value
int16_t read16() {
  uint8_t highByte = Wire.read();
  uint8_t lowByte = Wire.read();

  return (int16_t)(
    (uint16_t(highByte) << 8) | lowByte
  );
}

// Write to sensor register
bool writeRegister(byte reg, byte value) {
  Wire.beginTransmission(sensorAddress);
  Wire.write(reg);
  Wire.write(value);
  return Wire.endTransmission() == 0;
}

void resetWindow() {
  sampleCount = 0;
  gyroSum = 0;
  gyroSquareSum = 0;
  accelSum = 0;
  accelSquareSum = 0;
}

// Trigger LED cue
void startCue() {
  cueActive = true;
  cueStart = millis();
}

// Update LED without blocking sensor readings
void updateCue() {
  if (!cueActive) {
    digitalWrite(ledPin, LOW);
    cueFlag = 0;
    return;
  }

  unsigned long elapsed = millis() - cueStart;

  if (elapsed < 200 ||
      (elapsed >= 400 && elapsed < 600)) {

    digitalWrite(ledPin, HIGH);
    cueFlag = 1;

  } else {

    digitalWrite(ledPin, LOW);
    cueFlag = 0;
  }

  if (elapsed >= 800) {
    cueActive = false;
    digitalWrite(ledPin, LOW);
    cueFlag = 0;
  }
}

void setup() {
  Serial.begin(115200);

  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);

  Wire.begin(21, 22);
  Wire.setClock(400000);

  delay(100);

  bool ok = true;

  ok &= writeRegister(0x6B, 0x00);
  ok &= writeRegister(0x1C, 0x00);
  ok &= writeRegister(0x1B, 0x00);

  if (!ok) {
    return;
  }

  sensorReady = true;
  lastSampleTime = micros();
}

void loop() {

  updateCue();

  if (!sensorReady) {
    return;
  }

  unsigned long now = micros();

  if ((unsigned long)(now - lastSampleTime)
      < sampleInterval) {
    return;
  }

  lastSampleTime += sampleInterval;

  Wire.beginTransmission(sensorAddress);
  Wire.write(0x3B);

  if (Wire.endTransmission(false) != 0) {
    return;
  }

  if (Wire.requestFrom(sensorAddress, (uint8_t)14) != 14) {
    return;
  }

  // Accelerometer
  int16_t axRaw = read16();
  int16_t ayRaw = read16();
  int16_t azRaw = read16();

  read16(); // Skip temperature

  // Gyroscope
  int16_t gxRaw = read16();
  int16_t gyRaw = read16();
  int16_t gzRaw = read16();

  // Convert to physical units
  float ax = axRaw / 16384.0f;
  float ay = ayRaw / 16384.0f;
  float az = azRaw / 16384.0f;

  float gx = gxRaw / 131.0f;
  float gy = gyRaw / 131.0f;
  float gz = gzRaw / 131.0f;

  // Calculate magnitudes
  float accelMagnitude = sqrt(
    ax * ax + ay * ay + az * az
  );

  float gyroMagnitude = sqrt(
    gx * gx + gy * gy + gz * gz
  );

  // Collect motion statistics
  gyroSum += gyroMagnitude;
  gyroSquareSum += gyroMagnitude * gyroMagnitude;

  accelSum += accelMagnitude;
  accelSquareSum += accelMagnitude * accelMagnitude;

  sampleCount++;

  // Analyze every 50 readings
  if (sampleCount >= windowSize) {

    float avgGyro = gyroSum / sampleCount;
    float avgAccel = accelSum / sampleCount;

    float gyroVariance =
      gyroSquareSum / sampleCount -
      avgGyro * avgGyro;

    float accelVariance =
      accelSquareSum / sampleCount -
      avgAccel * avgAccel;

    gyroVariance = max(0.0f, gyroVariance);
    accelVariance = max(0.0f, accelVariance);

    float gyroStd = sqrt(gyroVariance);
    float accelStd = sqrt(accelVariance);

    bool lowMotion =
      gyroStd < LOW_GYRO_STD &&
      accelStd < LOW_ACCEL_STD;

    bool activeMotion =
      gyroStd > ACTIVE_GYRO_STD ||
      accelStd > ACTIVE_ACCEL_STD;

    motionChangeFlag = 0;

    if (activeMotion) {

      wasMoving = true;
      lowMotionWindows = 0;

    } else if (lowMotion) {

      lowMotionWindows++;

      if (wasMoving && lowMotionWindows >= 2) {

        motionChangeFlag = 1;
        startCue();
        wasMoving = false;
      }

    } else {

      lowMotionWindows = 0;
    }

    resetWindow();
  }

  // Update cue after any new trigger
  updateCue();

  // Send clean numeric output to Serial Plotter
  Serial.print("AccelMag:");
  Serial.print(accelMagnitude, 3);

  Serial.print("\tGyroScaled:");
  Serial.print(gyroMagnitude / 20.0f, 3);

  Serial.print("\tMotionChange:");
  Serial.print(motionChangeFlag);

  Serial.print("\tLED:");
  Serial.println(cueFlag);
}

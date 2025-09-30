/*
  This sketch integrates multiple IoT features for an Arduino UNO R4 WiFi:
  
  - Controls blinds with a 28BYJ-48 stepper motor based on a schedule.
  - Controls a lamp with a 5V relay module based on a schedule.
  - Uses the built-in Real-Time Clock (RTC) for timekeeping.
  - Allows manual override for both blinds and lamp via Arduino Cloud & Alexa.
  - Is ready to receive commands from IFTTT for geofencing.
*/

// Automatically included by the Arduino Cloud editor
#include "thingProperties.h"

#include <Stepper.h> // Arduino's built-in stepper library
#include <RTC.h>     // Access to the Real-Time Clock on the UNO R4 WiFi

// The pin order for the ULN2003 driver is IN1, IN3, IN2, IN4
const int STEPPER_PIN_1 = 8;
const int STEPPER_PIN_2 = 10;
const int STEPPER_PIN_3 = 9;
const int STEPPER_PIN_4 = 11;
const int STEPS_PER_REVOLUTION = 2048; // For a 28BYJ-48 stepper motor

// Stepper Motor Calibration
// This is the number of steps your motor needs to turn to open/close the blinds.
// 512 steps = 90 degrees.
const int STEPS_TO_OPERATE = 512; 

// Specific pin on the Arduino that acts as the control switch for a lamp.
const int RELAY_PIN = 7;

// AUTOMATION SCHEDULE (24-hour format)
const int DAY_START_HOUR = 7;    // 7:00 AM
const int NIGHT_START_HOUR = 19; // 7:00 PM

// Update Time
// How often to check the time for automation (in milliseconds). 60000ms = 1 minute.
const long CHECK_INTERVAL_MS = 60000;

// Initialize the stepper library
Stepper myStepper(STEPS_PER_REVOLUTION, STEPPER_PIN_1, STEPPER_PIN_2, STEPPER_PIN_3, STEPPER_PIN_4);

// State-tracking variables
bool blindsAreOpen = false; // Tracks the physical state of the blinds
unsigned long lastTimeCheck = 0; // Timer for the automation check

void setup() {
  Serial.begin(9600);
  // A small delay to allow the serial monitor to connect
  delay(1500); 

  // Hardware Initialization
  pinMode(RELAY_PIN, OUTPUT);
  myStepper.setSpeed(12); // Set motor speed in RPM (10-15 is good for 28BYJ-48)

  // Arduino Cloud & Properties Initialization
  initProperties();
  ArduinoCloud.begin(ArduinoIoTPreferredConnection);
  setDebugMessageLevel(2);
  ArduinoCloud.printDebugInfo();

  // Real-Time Clock (RTC) Initialization
  RTC.begin();
  Serial.println("Waiting for time sync from network...");
  // Wait until the RTC has a valid time (seconds since epoch > a large number)
  while (RTC.secondsSinceEpoch() < 1000000000) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println("\nTime synchronized successfully!");
  
  // Initial State Check
  // On startup, check the time and immediately move devices to their correct state.
  Serial.println("Performing initial device state check...");
  checkTimeAndOperateDevices(true); // 'true' forces an update
}


// main loop
void loop() {
  // Handles all cloud communication.
  ArduinoCloud.update();

  // Use a non-blocking timer to check the automation schedule periodically
  if (millis() - lastTimeCheck > CHECK_INTERVAL_MS) {
    lastTimeCheck = millis(); // Reset the timer
    checkTimeAndOperateDevices(false); // 'false' means only act if state needs to change
  }
}

/**
 * @brief Checks the current time and operates blinds and lamp accordingly.
 * @param forceUpdate If true, will move devices even if the state variable matches.
 * Useful for initial setup.
 */
void checkTimeAndOperateDevices(bool forceUpdate) {
  int currentHour = RTC.getHours();
  Serial.print("Time check. Current hour: ");
  Serial.println(currentHour);

  bool isDayTime = (currentHour >= DAY_START_HOUR && currentHour < NIGHT_START_HOUR);

  if (isDayTime) {
    // Daytime Logic
    if (!blindsAreOpen || forceUpdate) {
      Serial.println("Schedule: It's daytime. Opening blinds.");
      openBlinds();
    }
    // Only act on the lamp if it's currently on, or if forcing an update
    if (lampCommand || forceUpdate) {
      Serial.println("Schedule: It's daytime. Turning lamp off.");
      turnLampOff();
    }
  } else {
    // Night time Logic
    if (blindsAreOpen || forceUpdate) {
      Serial.println("Schedule: It's nighttime. Closing blinds.");
      closeBlinds();
    }
    // Only act on the lamp if it's currently off, or if forcing an update
    if (!lampCommand || forceUpdate) {
      Serial.println("Schedule: It's nighttime. Turning lamp on.");
      turnLampOn();
    }
  }
}


// Arduino Cloud Functions

// This function is called automatically whenever 'blindsCommand' is changed from the cloud
void onBlindsCommandChange() {
  Serial.println("Cloud Command: Received manual blinds command.");
  if (blindsCommand) { // If true or > 0 for percentage
    openBlinds();
  } else {
    closeBlinds();
  }
}

// This function is called automatically whenever 'lampCommand' is changed from the cloud
void onLampCommandChange() {
  Serial.println("Cloud Command: Received manual lamp command.");
  if (lampCommand) {
    turnLampOn();
  } else {
    turnLampOff();
  }
}

// Device Helper Functions

// Move stepper to OPEN
void openBlinds() {
  Serial.println("  -> Action: Moving stepper to OPEN position.");
  myStepper.step(STEPS_TO_OPERATE);
  blindsAreOpen = true;
}

// Move stepper to CLOSE
void closeBlinds() {
  Serial.println("  -> Action: Moving stepper to CLOSE position.");
  myStepper.step(-STEPS_TO_OPERATE); // Negative value reverses direction
  blindsAreOpen = false;
}

// Move Lamp State to ON
void turnLampOn() {
  Serial.println("  -> Action: Turning lamp ON.");
  // Relay module used is ACTIVE-LOW (LOW turns them on).
  digitalWrite(RELAY_PIN, LOW);
  if (!lampCommand) { lampCommand = true; } // Sync local state with cloud variable
}

// Move Lamp State to OFF
void turnLampOff() {
  Serial.println("  -> Action: Turning lamp OFF.");
  digitalWrite(RELAY_PIN, HIGH);
  if (lampCommand) { lampCommand = false; } // Sync local state with cloud variable
}

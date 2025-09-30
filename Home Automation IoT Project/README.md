# Arduino Smart Room Controller

This project transforms a standard room into a smart, automated space using an Arduino UNO R4 WiFi. It features automated control of window blinds and a lamp based on the time of day, with a full manual override system using Amazon Alexa and the Arduino Cloud dashboard.

## ✨ Features

* **Time-Based Automation:** Automatically opens/closes blinds and turns on/off a lamp based on a configurable day/night schedule.
* **Smart Voice Control:** Full integration with Amazon Alexa for manual control (e.g., "Alexa, open the blinds," "Alexa, turn off the lamp").
* **Cloud Dashboard:** Control and monitor the devices from anywhere using the Arduino Cloud app on a phone or web browser.
* **Geofencing Ready:** Includes the necessary logic to integrate with IFTTT for location-based triggers, such as automatically turning off the lights when you leave home.
* **Reliable Timekeeping:** Utilizes the Arduino UNO R4 WiFi's built-in Real-Time Clock (RTC) for accurate scheduling.

## 🛠️ Hardware Required

| Component                               | Quantity | Purpose                                        |
| --------------------------------------- | :------: | ---------------------------------------------- |
| Arduino UNO R4 WiFi                     |    1     | Main controller with WiFi & RTC capabilities   |
| 28BYJ-48 Stepper Motor                  |    1     | To physically operate the blinds               |
| ULN2003 Stepper Motor Driver            |    1     | To safely drive the stepper motor              |
| 5V Relay Module                         |    1     | To switch the high-voltage lamp on and off     |
| 5V DC External Power Supply (>1A)       |    1     | **Required** for powering the stepper motor    |
| Breadboard & Jumper Wires               |  Several | For connecting all the components              |
| A standard lamp                         |    1     | The device to be controlled                    |

## ☁️ Software & Services

* [Arduino IDE](https://www.arduino.cc/en/software) or [Arduino Web Editor](https://create.arduino.cc/editor)
* [Arduino Cloud](https://cloud.arduino.cc/) Account (Free plan is sufficient)
* Amazon Alexa Account & App
* [IFTTT](https://ifttt.com/) Account (Optional for geofencing)

## ⚙️ Setup & Installation

### 1. Hardware Assembly

1.  **Stepper Motor:** Connect the 28BYJ-48 motor to the ULN2003 driver board. Connect the driver's input pins `IN1`, `IN2`, `IN3`, `IN4` to the Arduino's digital pins `D8`, `D10`, `D9`, `D11` respectively.
2.  **Stepper Power:** Power the ULN2003 driver board with the external 5V power supply. Connect the ground (-) of the external power supply to a `GND` pin on the Arduino to create a common ground.
3.  **Relay Module:** Connect the relay module's `VCC` to `5V`, `GND` to `GND`, and the `IN` pin to Arduino digital pin `D7`.
4.  **Lamp Wiring:** Carefully cut open the outer sheath of the lamp's power cord to expose the inner wires. Cut only the Hot (black) wire. You now have two ends of the black wire. Take the end of the Hot wire that comes from the wall plug and connect it to the `COM` terminal on the relay.
Take the other end of the Hot wire that goes to the lamp itself and connect it to the `NO` terminal on the relay.

### 2. Arduino Cloud Configuration

1.  Create a new **Thing** in the Arduino IoT Cloud.
2.  Associate **Arduino UNO R4 WiFi** board.
3.  Under the "Network" tab, enter WiFi credentials.
4.  Create two **Cloud Variables**:
    * A `Boolean` variable named `blindsCommand`. In its settings, enable "Sync with Alexa" and give it a name. Ex. "Blinds".
    * A `Boolean` variable named `lampCommand`. Enable "Sync with Alexa" and give it a name. Ex. "Lamp".

### 3. Upload the Code

1.  Open the final `.ino` sketch file in the Arduino IDE or Web Editor.
2.  **Calibrate:** Before uploading, review and adjust the necessary constants, especially `STEPS_TO_OPERATE`, to match the physical setup.
3.  Upload the code to your Arduino.

### 4. Link Services

1.  **Alexa:** Open the Alexa app, search for the "Arduino" skill, and enable it. Log in with Arduino account. Ask Alexa to "Discover devices." Your "Blinds" and "Lamp" should appear.
2.  **IFTTT (Optional):** Create a new applet. Use the "Location" service ("You exit an area") as the "If This" trigger. Use the "Arduino IoT Cloud" service ("Set a Thing Property") as the "Then That" action, setting `lampCommand` to `false`.

## 💻 Code Overview

The main sketch (`.ino` file) is structured for clarity and ease of modification.

* **User Configuration:** A block at the top of the file contains all the important variables you might need to change, such as pin numbers, motor steps, and the day/night schedule.
* **`setup()`:** This function runs once on startup. It initializes the hardware, connects to WiFi and the Arduino Cloud, synchronizes the time via the internet, and sets the devices to their correct initial states.
* **`loop()`:** The main loop continuously calls `ArduinoCloud.update()` to listen for commands and runs a timed check (once per minute) to execute the automation logic.
* **Callback Functions (`on...Change()`):** These special functions are triggered instantly when a variable is changed from the cloud (by Alexa or the dashboard). They handle the manual override commands.

## 🚀 Usage

Once set up, the system is fully autonomous.

* **Automation:** The blinds and lamp will operate automatically at the times defined in the code.
* **Voice Control:** Use commands like:
    * "Alexa, turn on the lamp."
    * "Alexa, turn off the blinds." (Closes them)
    * "Alexa, set the blinds to on." (Opens them)
* **Remote Control:** Use the toggles in the Arduino Cloud app for manual control.

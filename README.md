# Recipe Maker

**Have you ever struggled to come up with a recipe using the ingredients lying around your house?** 

Well, struggle no more! With Recipe Maker, you can simply list the ingredients you have, hit the **Generate** button, and get a personalized recipe instantly!

---

## Features

### Data Persistence
- Utilizes **Isar** to remember your ingredients across app restarts.
- Easily **add**, **edit**, **remove**, or **clear** your ingredient list through the app's user interface.

### API Integration
- Integrates with the **Gemini AI API** to generate recipes based on your ingredients.
- Uses a structured JSON schema to request a tailored recipe response.
- Supports **location-based recipe generation** by including your `city` and `country` in the API prompt when selecting the "Generate with Location" option.

### GPS and Geocoding
- Leverages the device's **GPS sensor** to fetch your current location.
- Uses **Dart's Geocoder package** to convert GPS coordinates into `city` and `country` information.

### Flutter Features
- Implements **Flutter navigation** for seamless transitions to the recipe response view.
- Uses **Provider** for state management of:
  - **Isar database** for ingredients.
  - **User's GPS location**.
  - **Gemini API responses**.

---

## Installation

1. Create an `APIKEY.env` file to store the Gemini API key.
2. Add the following to the `APIKEY.env` file:
   ```
   APIKEY='Your Gemini API Key Here'
   ```
3. Move the `APIKEY.env` file into the `/recipe-maker` directory.
4. Run the following command to fetch dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app and enjoy generating recipes!

---

## Supported Devices

- **iOS and Android only**: The app relies on hardware-specific features, such as GPS sensors and geocoding, which are tested only on mobile platforms.
- Compatibility with other operating systems (e.g., desktop or web) has **not been tested** and may not work as expected.

---

Enjoy creating recipes with ease using Recipe Maker!

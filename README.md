# Nebula Nutrition

## Compilation Instructions

### Prerequisites
- Flutter SDK
- Android Studio or Xcode
- Firebase project configured

### Steps to Compile
1. Clone the repository
    ```bash
    git clone <https://github.com/AlexVu2662/Nebula-Nutrition.git>
    cd Nebula-Nutrition
    ```

2. Install dependencies
    ```bash
    flutter pub get
    ```

3. Build the application:
    - For Android: 
    ```bash
    flutter build apk --debug
    ```
    - For iOS: 
    ```bash
    flutter build ios --debug
    ```

## Executable Location
- **Android**: `build/app/outputs/flutter-apk/app-release.apk`
- **iOS**: `build/ios/iphoneos/Runner.app`

## Running the Application
- Use Flutter CLI: 
    ```bash
    flutter run
    ```
- Or launch from Android Studio/Xcode

## Authentication Credentials

### Test User Accounts
1. **Email**: `test@test.com`
   **Password**: `foobar`

## Input Parameters
- **Camera input**: Rear camera only
- **Supported image formats**: JPEG, PNG
- **Recommended image size**: 224x224 pixels

## Notes
- Requires active internet connection
- Nutrition data retrieval depends on network connectivity
- Machine learning model must be pre-loaded in `assets/model.tflite`
- Only categorizes based on 1 of 36 classes that the model is trained on, available in `labels.txt`

## Project Files Overview

### `lib/`
- **`food.dart`**: Formats API calls to retrieve nutrition data based on the food classification.
- **`firebase_options.dart`**: Configures Firebase for compatibility with the project, including setup for authentication and other Firebase services.
- **`api_service.dart`**: Handles making API calls to retrieve nutrition information and other services.
- **`main.dart`**: Contains the main app logic, page routing, and component integration to tie everything together.

### `assets/`
- **`labels.txt`**: A text file containing the 36 classes the model is trained to classify. This file is essential for determining what food items are detected in images.
- **`model.tflite`**: A lightweight TensorFlow Lite model used for image classification to detect and categorize food items.

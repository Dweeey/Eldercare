*ELDERCAREAPP*

A Flutter application for ElderCare+ Smart Health Assistant Watch.

⚠️ IMPORTANT WARNING

DO NOT PUSH OR UPDATE THE REPOSITORY until instructed.
Any changes may affect the project setup or cause conflicts. Only clone and run for now.

1. DOWNLOAD THE PROJECT

To download the project to your local machine:

Make sure Git is installed. If not, download it from git-scm.com
.

Open your terminal or command prompt.

Run the following command to clone the repository:

git clone <your-repo-url>


Replace <your-repo-url> with the GitHub repository URL.
This will create a local copy of the project.

2. INSTALL FLUTTER SDK

Download the Flutter SDK from flutter.dev
.

Extract it to a suitable location (e.g., C:\src\flutter on Windows).

Add Flutter to your system PATH:

Windows: System Properties > Environment Variables > Path > Add <flutter-path>\bin

Mac/Linux: add export PATH="$PATH:<flutter-path>/bin" to your shell config (.zshrc or .bashrc)

Verify the installation:

flutter doctor


Make sure all required dependencies are installed.

3. INSTALL ANDROID STUDIO

Download Android Studio: https://developer.android.com/studio

Install it and during setup, make sure to include:

Android SDK

Android SDK Platform-Tools

Android Emulator

Open Android Studio and create a virtual device (AVD) to run the app.

4. RUNNING THE PROJECT

Open your terminal in the project folder.

Run the following commands to prepare the project:

flutter clean
flutter pub get


flutter clean clears the build cache.

flutter pub get fetches all dependencies.

To run the app on your emulator or connected device:

flutter run


For hot reload during development, press r in the terminal or use the hot reload button in your IDE.

5. PULLING UPDATES FROM GIT

If you need to pull updates later:

git pull origin main


Only do this when instructed to avoid conflicts.
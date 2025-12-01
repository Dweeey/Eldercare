# **ELDERCAREAPP**

A Flutter application for **ElderCare+ Smart Health Assistant Watch**.

---

## **⚠️ IMPORTANT WARNING**

> **🚫 DO NOT PUSH OR UPDATE THE REPOSITORY** until instructed.
> Any changes may affect the project setup or cause conflicts. Only clone and run for now.

---

## **1️⃣ DOWNLOAD THE PROJECT**

1. **Install Git** if not already installed: [https://git-scm.com/](https://git-scm.com/)
2. Open **Terminal** or **Command Prompt**.
3. Run the command to clone the repository:

```bash
git clone <your-repo-url>
```

➡️ Replace `<your-repo-url>` with the GitHub repository URL.
This will download the project to your computer.

---

## **2️⃣ INSTALL FLUTTER SDK**

1. **Download Flutter SDK**: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. **Extract** the folder to a location (e.g., `C:\src\flutter`).
3. **Add Flutter to your PATH**:

   * **Windows:** `System Properties > Environment Variables > Path > Add <flutter-path>\bin`
   * **Mac/Linux:** add `export PATH="$PATH:<flutter-path>/bin"` to `.bashrc` or `.zshrc`
4. **Verify installation**:

```bash
flutter doctor
```

✔️ Make sure all dependencies show as installed.

---

## **3️⃣ INSTALL ANDROID STUDIO**

1. **Download Android Studio**: [https://developer.android.com/studio](https://developer.android.com/studio)
2. **Install** and include the following components:

   * Android SDK
   * Android SDK Platform-Tools
   * Android Emulator
3. Open Android Studio → **Create a Virtual Device (AVD)** to run the app.

---

## **4️⃣ RUNNING THE PROJECT**

1. Open **Terminal** in the project folder.
2. Run these commands to prepare the project:

```bash
flutter clean   # → clears build cache
flutter pub get # → installs dependencies
```

3. To **run the app**:

```bash
flutter run
```

4. For **hot reload** during development:

   * Press **`r`** in the terminal
   * OR use the **hot reload button** in Android Studio/VS Code

---

## **5️⃣ PULLING UPDATES FROM GIT**

1. When instructed, update your local repo with:

```bash
git pull origin main
```

⚠️ Only pull updates when given permission.

---

## **6️⃣ SUMMARY OF COMMANDS**

* **Clone project:** `git clone <repo>`
* **Clear build cache:** `flutter clean`
* **Install dependencies:** `flutter pub get`
* **Run the app:** `flutter run`
* **Pull updates:** `git pull origin main`

---

✅ This setup ensures you can **safely run the app** without accidentally pushing updates.

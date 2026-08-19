name: Build Local Business Services APK

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout project
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Verify Flutter project
        run: |
          echo "Current directory:"
          pwd
          echo "Project files:"
          ls -la
          echo "Checking pubspec.yaml:"
          test -f pubspec.yaml
          echo "Flutter project found."

      - name: Add Firebase packages
        run: |
          flutter pub add firebase_core
          flutter pub add firebase_auth
          flutter pub add cloud_firestore
          flutter pub add http
          flutter pub add url_launcher

      - name: Add Firebase configuration
        env:
          GOOGLE_SERVICES_JSON: ${{ secrets.GOOGLE_SERVICES_JSON }}
        run: |
          mkdir -p android/app
          printf '%s' "$GOOGLE_SERVICES_JSON" > android/app/google-services.json
          test -s android/app/google-services.json
          echo "google-services.json created."

      - name: Add Internet permission
        run: |
          python3 - <<'PY'
          from pathlib import Path

          path = Path("android/app/src/main/AndroidManifest.xml")

          if path.exists():
              text = path.read_text()

              permission = '<uses-permission android:name="android.permission.INTERNET"/>'

              if permission not in text:
                  text = text.replace(
                      '<manifest',
                      '<manifest',
                      1
                  )

                  first_close = text.find('>')

                  if first_close != -1:
                      text = (
                          text[:first_close + 1]
                          + '\n    '
                          + permission
                          + text[first_close + 1:]
                      )

              path.write_text(text)

          print("Internet permission checked.")
          PY

      - name: Configure Firebase Android plugin
        run: |
          python3 - <<'PY'
          from pathlib import Path

          settings = Path("android/settings.gradle.kts")
          settings_groovy = Path("android/settings.gradle")

          if settings.exists():
              text = settings.read_text()

              if "com.google.gms.google-services" not in text:
                  marker = "plugins {"

                  if marker in text:
                      text = text.replace(
                          marker,
                          marker + '\n    id("com.google.gms.google-services") version "4.4.2" apply false',
                          1
                      )

                  settings.write_text(text)

          elif settings_groovy.exists():
              text = settings_groovy.read_text()

              if "com.google.gms.google-services" not in text:
                  marker = "plugins {"

                  if marker in text:
                      text = text.replace(
                          marker,
                          marker + "\n    id 'com.google.gms.google-services' version '4.4.2' apply false",
                          1
                      )

                  settings_groovy.write_text(text)

          print("Firebase Android plugin checked.")
          PY

      - name: Enable Google Services plugin
        run: |
          python3 - <<'PY'
          from pathlib import Path

          path = Path("android/app/build.gradle.kts")
          groovy = Path("android/app/build.gradle")

          if path.exists():
              text = path.read_text()

              if 'com.google.gms.google-services' not in text:
                  text = text.replace(
                      'plugins {',
                      'plugins {\n    id("com.google.gms.google-services")',
                      1
                  )

              path.write_text(text)

          elif groovy.exists():
              text = groovy.read_text()

              if 'com.google.gms.google-services' not in text:
                  text = text.replace(
                      'plugins {',
                      "plugins {\n    id 'com.google.gms.google-services'",
                      1
                  )

              path.write_text(text)

          print("Google Services plugin enabled.")
          PY

      - name: Get Flutter packages
        run: |
          flutter clean
          flutter pub get

      - name: Check Firebase configuration
        run: |
          echo "Checking Firebase configuration..."
          test -f android/app/google-services.json
          echo "Firebase configuration exists."

      - name: Build Release APK
        env:
          GOOGLE_PLACES_API_KEY: ${{ secrets.GOOGLE_PLACES_API_KEY }}
        run: |
          flutter build apk --release \
            --dart-define=GOOGLE_PLACES_API_KEY="$GOOGLE_PLACES_API_KEY"

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: local-business-services-apk
          path: build/app/outputs/flutter-apk/app-release.apk
          if-no-files-found: error

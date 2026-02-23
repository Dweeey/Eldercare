# ElderCareApp

Flutter app for elder health monitoring, alerts, and caregiver support.

## Prerequisites

1. Install Flutter SDK and confirm setup:
```bash
flutter doctor
```
2. Install dependencies:
```bash
flutter pub get
```

## Required Runtime Configuration

This app now requires Supabase config via `--dart-define`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Run with:

```bash
flutter run --dart-define=SUPABASE_URL=<your-url> --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

## Quality Gates

Run these locally before pushing changes:

```bash
flutter analyze
flutter test
```

## Project Structure

- `lib/core/providers/` shared app state providers
- `lib/data/local/` local database helpers
- `lib/features/auth/` auth flow and auth data services
- `lib/features/home/` dashboard and health metrics
- `lib/features/alerts/` alert list/details/call/message screens
- `lib/features/account/` profile/settings/contacts/medications/support
- `lib/app_routes.dart` centralized route definitions
- `lib/app_config.dart` environment-backed app config

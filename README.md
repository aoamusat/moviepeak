# MoviePeak Mobile MVP

Flutter mobile customization of the existing template into **MoviePeak**, a discovery-first streaming app for Nigeria.

## Stack

- Flutter + Dart 3
- State management: `flutter_riverpod`
- Networking: `dio`
- Token storage: `flutter_secure_storage`
- Fonts: `google_fonts` (Manrope)
- Playback: `chewie` + `video_player` (HLS compatible)

## Project Structure

```text
lib/
  app/
  core/
    config/ constants/ network/ storage/ theme/ widgets/
  data/
    models/ repositories/
  features/
    auth/
    onboarding/
    home/
    search/
    movie_details/
    playback/
    profile/
    requests/
    subscriptions/
    watch_history/
```

## API Base URL

Uses `.env` via `flutter_dotenv`.

1. Copy the example:
```bash
cp .env.example .env
```
2. Update:
```env
API_BASE_URL=http://10.0.2.2:3000/api/v1
```

For real devices, replace `10.0.2.2` with a reachable backend host.

## Run

```bash
flutter pub get
flutter run
```

## Test & Analyze

```bash
flutter analyze
flutter test
```

## Implemented MVP Flows

- Auth: signup/login/logout with access + refresh token persistence
- Onboarding: genres/languages/moods preferences
- Home discovery: marketing banners + trending, under 90, nollywood, because-you-watched
- Search + filters, empty state request flow
- Movie details + trailer + watchlist toggle
- Subscription screens: plans/start/cancel/status (mock-provider ready)
- Playback authorization + HLS playback + progress sync every 10s
- Requests: create + top requests
- Profile: edit info/preferences, watch history, logout

## Docs

- Branding changes: `BRANDING.md`
- Screen-to-endpoint integration map: `docs/INTEGRATION.md`

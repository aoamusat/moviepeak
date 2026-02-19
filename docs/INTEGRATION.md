# MoviePeak Mobile Integration Map

Base URL prefix expected by app:

- `/api/v1`

## Auth

### Screens
- `lib/features/auth/screens/auth_landing_screen.dart`

### Endpoints
- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/refresh` (automatic when token expires)
- `POST /auth/logout`

## Onboarding / Preferences

### Screens
- `lib/features/onboarding/screens/onboarding_screen.dart`
- `lib/features/profile/screens/profile_screen.dart`

### Endpoints
- `PATCH /users/me` (genres/languages/moods)
- `GET /users/me`

## Home Discovery

### Screens
- `lib/features/home/screens/home_screen.dart`

### Endpoints
- `GET /discovery/trending`
- `GET /discovery/under-90`
- `GET /discovery/nollywood`
- `GET /discovery/because-you-watched`

## Search

### Screens
- `lib/features/search/screens/search_screen.dart`

### Endpoints
- `GET /search?q=...&genre=...&language=...&minDuration=...&maxDuration=...&year=...&region=...`

## Movie Details + Watchlist

### Screens
- `lib/features/movie_details/screens/movie_details_screen.dart`

### Endpoints
- `GET /movies`
- `GET /movies/:id`
- `POST /movies/:id/watchlist`
- `GET /watchlist/me`

## Subscriptions

### Screens
- `lib/features/subscriptions/screens/plans_screen.dart`
- `lib/features/subscriptions/screens/subscription_status_screen.dart`

### Endpoints
- `GET /plans`
- `POST /subscriptions/start`
- `POST /subscriptions/cancel`
- `GET /subscriptions/me`

## Playback

### Screens
- `lib/features/playback/screens/playback_screen.dart`

### Endpoints
- `GET /movies/:id/playback`
- `POST /watch-history/progress` (every ~10 seconds + dispose)

## Watch History

### Screens
- `lib/features/profile/screens/profile_screen.dart`

### Endpoints
- `GET /watch-history/me`
- `POST /watch-history/progress`

## Requests

### Screens
- `lib/features/requests/screens/requests_screen.dart`
- `lib/features/search/screens/search_screen.dart` (empty results flow)

### Endpoints
- `POST /requests`
- `GET /requests/top`

## Notes

- API client unwraps `data` payloads if backend uses `{ data: ... }` response envelopes.
- `401` responses trigger refresh-token flow automatically, then retry original request once.
- Playback expects HLS-compatible `streamUrl` and short-lived `playbackToken` from backend.

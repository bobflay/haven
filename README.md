# Haven — Flutter web app

A quiet place to meet the urge and watch it pass. Haven is a craving &
recovery–tracking companion. This is the **Flutter (web) front end**; it talks to
the Laravel API in [`../haven_backend`](../haven_backend).

## What's inside

A faithful build of the Haven design — rendered inside a centred phone frame so it
looks identical on desktop and mobile browsers:

- **Login / Create a space** — token auth against the API.
- **Today** — greeting, quick actions, today-at-a-glance stats, recent moments.
- **Patterns** — weekly craving-intensity chart, energy-state distribution,
  emotional-weather averages, and a gentle observation.
- **Name the feeling** — an interactive emotion wheel (custom-painted, tappable).
- **Log a moment** — an 11-step flow (timing → place → state → energy → intensity
  → duration → trigger → emotions → rest → response → summary) that saves to the API.
- **Ride the wave** — a breathing/grounding timer.
- **Care team**, **Medications** (with per-dose check-off), **Export** (CSV / summary
  download), and **Chat with Haven** (an AI companion).

## Run it

1. Start the backend first (see `../haven_backend/README.md`) — it listens on
   `http://127.0.0.1:8000`.
2. Fetch packages and run for web:

   ```bash
   flutter pub get
   flutter run -d chrome
   ```

The app expects the API at `http://127.0.0.1:8000/api`. Point it elsewhere with:

```bash
flutter run -d chrome --dart-define=HAVEN_API_BASE=https://your-host/api
```

### Production build

```bash
flutter build web            # standard JS build
flutter build web --wasm     # WebAssembly build (also supported)
```

## Architecture

- `lib/theme/` — palette + Newsreader / Hanken Grotesk typography.
- `lib/models/` — API data models and the shared constants (energy states,
  emotion-wheel cores).
- `lib/services/api_service.dart` — the typed HTTP client.
- `lib/state/` — `AuthState` (token, persisted via `shared_preferences`),
  `DataStore` (all data + derived patterns), `NavState` (screen routing).
- `lib/widgets/` — the phone frame, the Haven mark, and shared building blocks.
- `lib/screens/` — one file per surface.

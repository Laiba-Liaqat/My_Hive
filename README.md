# 🐝 Hive Focus

A minimal, distraction-aware productivity app. Focus and your bees fill a
living honeycomb; leave the app and the colony collapses. Completed sessions
build a 3D-style apiary, backed by a full analytics dashboard, calendar,
light/dark honey theming, and a Solana wallet foundation for future
on-chain rewards.

## ✨ What's implemented

- **Focus Timer** — 15/25/45m presets + custom duration slider (5–180m),
  live countdown, Pause/Resume, Give Up with confirmation.
- **Gamified hive** — a hand-painted `CustomPainter` honeycomb fills with
  animated liquid honey as you focus; bees orbit while active; colony health
  drains if you background the app and the batch is lost if you don't
  return within the grace period (`FocusProvider.distractionGraceSeconds`).
- **Distraction detection** — `WidgetsBindingObserver` in `FocusProvider`
  watches app lifecycle state; leaving the foreground during a running
  session triggers the "distracted" state in real time.
- **3D-style apiary** — `Apiary3DView` renders your completed sessions as
  jars of honey across depth-scaled shelf rows (back rows smaller/dimmer,
  front rows larger/brighter) for a perspective illusion without a 3D engine.
- **Analytics dashboard** (`ApiaryScreen`) — honey produced, failed batches,
  total focus time, average session; a time-of-day bar chart; a
  Day/Week/Month/Year honey-yield line chart; a focus calendar highlighting
  active days with a live streak counter.
- **Theming** — warm honey-inspired light & dark themes, togglable and
  persisted (`ThemeProvider` + `shared_preferences`).
- **Solana wallet foundation** (`SolanaWalletService` + `WalletProvider`) —
  create/import an on-device keypair (BIP-39 mnemonic, stored in
  `flutter_secure_storage`), fetch devnet SOL balance, and a documented hook
  (`connectWithExistingWallet`) for wiring up Phantom/Solflare/Backpack via
  Mobile Wallet Adapter later. A "proof of focus" memo builder is included
  as a starting point for anchoring sessions on-chain.

## 📂 Project structure

```
lib/
  main.dart                    # App entry, providers wiring
  theme/app_theme.dart         # Light/dark honey theme
  models/focus_session.dart    # FocusSession + HoneyJar models
  providers/
    focus_provider.dart        # Timer state machine, distraction detection, stats
    theme_provider.dart        # Theme mode persistence
    wallet_provider.dart       # Wallet UI state
  services/
    storage_service.dart       # SharedPreferences persistence
    solana_wallet_service.dart # Solana keypair + RPC balance foundation
  screens/
    root_shell.dart            # Bottom nav shell
    home_screen.dart           # Focus timer
    apiary_screen.dart         # Dashboard & analytics
    wallet_screen.dart         # Solana wallet
    settings_screen.dart       # Theme + data settings
  widgets/
    honeycomb_painter.dart     # CustomPainter: empty -> wax -> cells -> capped honey
    bee_animation.dart         # Orbiting bee while a session is active
    hive_progress_widget.dart  # Composes painter + bee + labels
    apiary_3d_view.dart        # Depth-scaled honey jar shelves
    stat_card.dart             # Dashboard stat tile
    time_distribution_chart.dart
    productivity_chart.dart    # Line chart + range toggle
    focus_calendar.dart        # table_calendar wrapper with honey markers
  utils/constants.dart         # Honey-yield math, formatting helpers
```

## 🚀 Getting started

1. **Install Flutter** (stable channel, 3.22+ recommended) — https://docs.flutter.dev/get-started/install
2. From the project root, generate the platform folders for your machine
   (this keeps `android/`, `ios/`, etc. matched to your local Flutter/SDK
   versions instead of shipping possibly-stale boilerplate):
   ```bash
   flutter create .
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run it:
   ```bash
   flutter run
   ```

### Notes on the Solana integration

- The wallet defaults to **devnet** (`https://api.devnet.solana.com`). Change
  the `rpcUrl` passed into `SolanaWalletService` in `main.dart` when you're
  ready for mainnet-beta.
- Balance fetching requires network access — if you're testing offline,
  wallet creation/import still works (it's all local keypair generation),
  but `refreshBalance()` will surface a friendly error instead of crashing.
- `connectWithExistingWallet()` is an intentionally unimplemented hook —
  wire in `solana_mobile_client` (Android Mobile Wallet Adapter) or a
  WalletConnect-style deep link bridge for iOS when you want "Connect
  Phantom" style buttons instead of/alongside the built-in local wallet.

### Tuning the gamified mechanic

- `FocusProvider.distractionGraceSeconds` — how long the app can be
  backgrounded before the batch is auto-failed (default 6s, deliberately
  tight to match "leave the session and production stops").
- `AppConstants.honeyForSession` / `AppConstants.partialHoney` in
  `utils/constants.dart` — the honey-yield formulas; tweak the ml-per-minute
  rate or bonus curve for longer sessions here.

## 🎨 Design language

Warm creams, honey golds, and wax browns throughout (`HiveColors` in
`theme/app_theme.dart`), with `Fredoka` for display type and `Nunito` for
body text (via `google_fonts`) to keep the whole app feeling soft, rounded,
and hand-made — like a hive, not a spreadsheet.


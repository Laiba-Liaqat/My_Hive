🐝 Hive Focus
A minimal, distraction-aware productivity app. Focus and your bees fill a living honeycomb; leave the app and the colony collapses. Completed sessions build a 3D-style apiary, backed by a full analytics dashboard, calendar, light/dark honey theming, and a dedicated Mind Relax space to recharge between sessions.

✨ What's implemented
Focus Timer — 15/25/45m presets + custom duration slider (5–180m), live countdown, Pause/Resume, Give Up with confirmation.

Gamified hive — A hand-painted CustomPainter honeycomb fills with animated liquid honey as you focus; bees orbit while active; colony health drains if you background the app and the batch is lost if you don't return within the grace period (FocusProvider.distractionGraceSeconds).

Distraction detection — WidgetsBindingObserver in FocusProvider watches app lifecycle state; leaving the foreground during a running session triggers the "distracted" state in real time.

Mind Relax space — A dedicated screen to unwind between deep focus sessions. Features guided breathing exercises, ambient acoustic sounds, and a gentle visual cool-down to help you recharge and prevent burnout.

3D-style apiary — Apiary3DView renders your completed sessions as jars of honey across depth-scaled shelf rows (back rows smaller/dimmer, front rows larger/brighter) for a perspective illusion without a 3D engine.

Analytics dashboard (ApiaryScreen) — Honey produced, failed batches, total focus time, average session; a time-of-day bar chart; a Day/Week/Month/Year honey-yield line chart; a focus calendar highlighting active days with a live streak counter.

Theming — Warm honey-inspired light & dark themes, togglable and persisted (ThemeProvider + shared_preferences).

📂 Project structure
Plaintext
lib/
  main.dart                    # App entry, providers wiring
  theme/app_theme.dart         # Light/dark honey theme
  models/focus_session.dart    # FocusSession + HoneyJar models
  providers/
    focus_provider.dart        # Timer state machine, distraction detection, stats
    theme_provider.dart        # Theme mode persistence
  services/
    storage_service.dart       # SharedPreferences persistence
  screens/
    root_shell.dart            # Bottom nav shell
    home_screen.dart           # Focus timer
    mind_relax_screen.dart     # Breathing and cool-down space
    apiary_screen.dart         # Dashboard & analytics
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
🚀 Getting started
Install Flutter (stable channel, 3.22+ recommended) — https://docs.flutter.dev/get-started/install

From the project root, generate the platform folders for your machine (this keeps android/, ios/, etc. matched to your local Flutter/SDK versions instead of shipping possibly-stale boilerplate):

Bash
flutter create .
Install dependencies:

Bash
flutter pub get
Run it:

Bash
flutter run
⚙️ Tuning the gamified mechanic
FocusProvider.distractionGraceSeconds — How long the app can be backgrounded before the batch is auto-failed (default 6s, deliberately tight to match "leave the session and production stops").

AppConstants.honeyForSession / AppConstants.partialHoney in utils/constants.dart — The honey-yield formulas; tweak the ml-per-minute rate or bonus curve for longer sessions here.

🎨 Design language
Warm creams, honey golds, and wax browns throughout (HiveColors in theme/app_theme.dart), with Fredoka for display type and Nunito for body text (via google_fonts) to keep the whole app feeling soft, rounded, and hand-made — like a hive, not a spreadsheet.


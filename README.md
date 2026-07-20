# 🐝 Hive Focus

> **Cultivate focus. Build your apiary. Prevent burnout.**

Hive Focus is a minimal, distraction-aware productivity application designed to keep you deeply engaged in your work. By combining robust time management with intuitive gamification, your focus sessions breathe life into a digital honeycomb. Leave the app, and the colony collapses. Complete your sessions, and watch your 3D apiary thrive.

---

## ✨ Core Features

*   **Focus Timer:** Flexible scheduling with 15, 25, and 45-minute presets, alongside a custom duration slider (5–180 minutes). Includes a live countdown, pause/resume functionality, and intentional "Give Up" fail-safes.
*   **Gamified Hive Dynamics:** A `CustomPainter` honeycomb dynamically fills with animated, liquid honey as you work. Orbiting bees visualize active focus, creating a living digital environment.
*   **Strict Distraction Detection:** Leverages `WidgetsBindingObserver` to monitor application lifecycle states. Leaving the foreground triggers a real-time "distracted" penalty, enforcing strict discipline.
*   **Mind Relax Space:** A dedicated cool-down environment to recharge between deep work sessions. Features guided breathing exercises, ambient acoustics, and gentle visual cool-downs to prevent cognitive burnout.
*   **3D-Style Apiary Collection:** Renders completed sessions as honey jars across depth-scaled shelves (back rows appear smaller/dimmer; front rows larger/brighter), creating a captivating perspective illusion without the overhead of a heavy 3D engine.
*   **Comprehensive Analytics Dashboard:** Track your productivity through detailed metrics:
    *   Total honey produced, failed batches, and average session length.
    *   Time-of-day bar charts and yield trend lines (Day/Week/Month/Year).
    *   A dynamic focus calendar featuring live streak counters and honey markers.
*   **Adaptive Theming:** Seamlessly toggle between warm, honey-inspired light and dark modes, fully persisted via local storage.

---

## 📂 Project Structure

The project utilizes a clean, feature-driven architecture to ensure maintainability and scalable performance.

```plaintext
lib/
├── main.dart                  # Application entry point & provider wiring
├── theme/
│   └── app_theme.dart         # Light/dark honey-inspired theme definitions
├── models/
│   └── focus_session.dart     # Data models for FocusSession & HoneyJar
├── providers/
│   ├── focus_provider.dart    # Timer state machine & distraction detection
│   └── theme_provider.dart    # Theme mode persistence logic
├── services/
│   └── storage_service.dart   # SharedPreferences persistence management
├── screens/
│   ├── root_shell.dart        # Bottom navigation shell
│   ├── home_screen.dart       # Primary focus timer interface
│   ├── mind_relax_screen.dart # Breathing and cool-down environment
│   ├── apiary_screen.dart     # Analytics dashboard & data visualization
│   └── settings_screen.dart   # Theme and application preferences
├── widgets/
│   ├── honeycomb_painter.dart # CustomPainter: empty -> wax -> capped honey
│   ├── bee_animation.dart     # Orbiting bee animation for active sessions
│   ├── hive_progress_widget.dart # Composed painter, bee, and labels
│   ├── apiary_3d_view.dart    # Depth-scaled honey jar shelving
│   ├── stat_card.dart         # Reusable dashboard statistic tile
│   ├── time_distribution_chart.dart
│   ├── productivity_chart.dart # Line chart with range toggles
│   └── focus_calendar.dart    # table_calendar wrapper with honey markers
└── utils/
    └── constants.dart         # Honey-yield formulas & formatting helpers
🚀 Quick Start GuideEnsure you have Flutter installed (stable channel, 3.22+ recommended). View the official installation documentation.1. Generate Platform FoldersFrom the project root, generate the platform folders for your specific machine. This ensures your android/, ios/, and web/ directories match your local Flutter SDK version, preventing stale boilerplate issues.Bashflutter create .
2. Install DependenciesBashflutter pub get
3. Run the ApplicationBashflutter run
⚙️ Mechanics & TuningHive Focus allows developers to easily adjust the gamification difficulty and reward mechanics to suit different productivity philosophies.ParameterLocationDescriptionDistraction Grace PeriodFocusProvider.distractionGraceSecondsDefines how long the app can remain backgrounded before a batch automatically fails. Defaults to 6 seconds—deliberately tight to simulate stopped production.Honey Yield FormulaAppConstants.honeyForSessionAdjusts the baseline mL-per-minute honey production rate.Partial YieldsAppConstants.partialHoneyConfigures the bonus curve and reward logic for longer sessions or prematurely ended intervals.🎨 Design LanguageHive Focus is designed to feel soft, organic, and hand-made—like a real apiary, rather than a corporate spreadsheet.Color Palette: Warm creams, rich honey golds, and deep wax browns (HiveColors in theme/app_theme.dart).Typography: Driven by google_fonts:Headers & Display: Fredoka (adds a rounded, friendly, and geometric touch).Body & UI Text: Nunito (highly readable with soft, inviting terminals).

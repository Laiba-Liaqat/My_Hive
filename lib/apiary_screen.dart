import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/customization_provider.dart';
import 'providers/focus_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/apiary_3d_view.dart';
import 'widgets/focus_calendar.dart';
import 'widgets/glass_container.dart';
import 'widgets/meadow_view.dart';
import 'widgets/productivity_chart.dart';
import 'widgets/stat_card.dart';
import 'widgets/time_distribution_chart.dart';
import 'customize_screen.dart';

class ApiaryScreen extends StatefulWidget {
  const ApiaryScreen({super.key});

  @override
  State<ApiaryScreen> createState() => _ApiaryScreenState();
}

class _ApiaryScreenState extends State<ApiaryScreen> {
  AnalyticsRange _range = AnalyticsRange.week;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Consumer2<FocusProvider, CustomizationProvider>(
      builder: (context, focus, custom, _) {
        // Keep unlockable state in sync with the latest stats whenever
        // this screen rebuilds (session history changes propagate here).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          custom.refreshUnlocks(
            completedSessions: focus.completedSessions.length,
            totalHoneyMl: focus.totalHoneyMl,
          );
        });

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Hive', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26)),
                      Text(
                        'Your meadow and productivity, at a glance.',
                        style: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CustomizeScreen()),
                    ),
                    icon: const Text('🎨', style: TextStyle(fontSize: 20)),
                    tooltip: 'Customize',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Meadow ------------------------------------------
              MeadowView(
                jarCount: focus.honeyJars.length,
                colonyStrength: (0.3 + focus.honeyJars.length * 0.07).clamp(0.0, 1.0),
                beeEmoji: custom.activeBee.emoji,
                flowerEmoji: custom.activeFlower.emoji,
                reduceMotion: settings.reduceMotion,
              ),

              const SizedBox(height: 24),

              // --- Stat grid --------------------------------------
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  StatCard(label: 'Honey Produced', value: formatHoney(focus.totalHoneyMl), icon: '🍯'),
                  StatCard(label: 'Failed Batches', value: '${focus.failedBatchCount}', icon: '🥀', accent: HiveColors.danger),
                  StatCard(label: 'Total Focus Time', value: formatDuration(focus.totalFocusTime), icon: '⏳'),
                  StatCard(label: 'Avg. Session', value: formatDuration(focus.averageSessionDuration), icon: '📊'),
                ],
              ),

              const SizedBox(height: 28),
              _SectionTitle('Honey Jar Shelf', subtitle: '${focus.honeyJars.length} jars collected'),
              const SizedBox(height: 12),
              Apiary3DView(jars: focus.honeyJars),

              const SizedBox(height: 28),
              _SectionTitle('When Your Bees Are Active'),
              const SizedBox(height: 12),
              GlassContainer(child: TimeDistributionChart(distribution: focus.timeDistribution)),

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Productivity'),
                  RangeToggle<AnalyticsRange>(
                    options: AnalyticsRange.values,
                    labels: const ['Day', 'Week', 'Month', 'Year'],
                    selected: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassContainer(child: ProductivityChart(series: focus.yieldSeries(_range))),

              const SizedBox(height: 28),
              _SectionTitle('Focus Calendar', subtitle: '${focus.currentStreak} day streak 🔥'),
              const SizedBox(height: 12),
              GlassContainer(child: FocusCalendar(activeDays: focus.activeDays)),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        if (subtitle != null)
          Text(subtitle!, style: TextStyle(color: HiveColors.wilted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

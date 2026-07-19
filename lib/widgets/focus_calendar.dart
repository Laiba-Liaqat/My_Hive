import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';

/// Monthly calendar highlighting days with at least one completed
/// focus session, to visualize consistency/streaks over time.
class FocusCalendar extends StatefulWidget {
  const FocusCalendar({super.key, required this.activeDays});

  final Set<DateTime> activeDays;

  @override
  State<FocusCalendar> createState() => _FocusCalendarState();
}

class _FocusCalendarState extends State<FocusCalendar> {
  DateTime _focusedDay = DateTime.now();

  bool _isActive(DateTime day) {
    return widget.activeDays.contains(DateTime(day.year, day.month, day.day));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 1)),
      focusedDay: _focusedDay,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          color: isDark ? HiveColors.combCream : HiveColors.waxBrown,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: HiveColors.honeyAmber),
        rightChevronIcon: Icon(Icons.chevron_right, color: HiveColors.honeyAmber),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w700, fontSize: 11),
        weekendStyle: TextStyle(color: HiveColors.wilted, fontWeight: FontWeight.w700, fontSize: 11),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          border: Border.all(color: HiveColors.honeyAmber, width: 2),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: isDark ? HiveColors.combCream : HiveColors.waxBrown,
          fontWeight: FontWeight.w700,
        ),
        defaultTextStyle: TextStyle(
          color: isDark ? HiveColors.combCream.withOpacity(0.8) : HiveColors.waxBrown.withOpacity(0.8),
        ),
        weekendTextStyle: TextStyle(
          color: isDark ? HiveColors.combCream.withOpacity(0.6) : HiveColors.waxBrown.withOpacity(0.6),
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (_isActive(day)) {
            return _HoneyDayCell(day: day);
          }
          return null;
        },
        todayBuilder: (context, day, focusedDay) {
          if (_isActive(day)) {
            return _HoneyDayCell(day: day, isToday: true);
          }
          return null;
        },
      ),
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
    );
  }
}

class _HoneyDayCell extends StatelessWidget {
  const _HoneyDayCell({required this.day, this.isToday = false});

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [HiveColors.honeyGold, HiveColors.honeyDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isToday ? Border.all(color: HiveColors.waxBrown, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

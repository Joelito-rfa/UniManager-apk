import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEvent {
  final int id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String time;
  final Color color;
  final String type;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.color,
    this.type = 'course',
  });
}

class AcademicCalendar extends StatefulWidget {
  final List<CalendarEvent> events;
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;

  const AcademicCalendar({
    super.key,
    this.events = const [],
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<AcademicCalendar> createState() => _AcademicCalendarState();
}

class _AcademicCalendarState extends State<AcademicCalendar> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.initialDate?.year ?? DateTime.now().year,
      widget.initialDate?.month ?? DateTime.now().month,
      1,
    );
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  Iterable<CalendarEvent> eventsForDay(DateTime day) {
    return widget.events.where((e) =>
        e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthFormat = DateFormat('MMMM yyyy', 'fr_FR');
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    final weekDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _previousMonth,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                monthFormat.format(_currentMonth)[0].toUpperCase() +
                    monthFormat.format(_currentMonth).substring(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: _nextMonth,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: weekDays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          ((firstWeekday + daysInMonth) / 7).ceil(),
          (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayNumber =
                      weekIndex * 7 + dayIndex - firstWeekday + 1;
                  final isInMonth =
                      dayNumber >= 1 && dayNumber <= daysInMonth;
                  final date = DateTime(
                    _currentMonth.year,
                    _currentMonth.month,
                    isInMonth ? dayNumber : 0,
                  );
                  final isToday = isInMonth &&
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isSelected = isInMonth &&
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final dayEvents = isInMonth ? eventsForDay(date).toList() : [];

                  return Expanded(
                    child: InkWell(
                      onTap: isInMonth
                          ? () {
                              setState(() {
                                _selectedDate = date;
                              });
                              widget.onDateSelected?.call(date);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isToday && !isSelected
                                  ? theme.colorScheme.primaryContainer
                                      .withAlpha(80)
                                  : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              isInMonth ? '$dayNumber' : '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isToday || isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : isInMonth
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.outlineVariant,
                              ),
                            ),
                            if (dayEvents.isNotEmpty)
                              Positioned(
                                bottom: 4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: dayEvents.take(3).map((e) {
                                    return Container(
                                      width: 5,
                                      height: 5,
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: e.color,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (eventsForDay(_selectedDate).isNotEmpty)
          _buildEventsList(theme),
        if (eventsForDay(_selectedDate).isEmpty)
          _buildNoEvents(theme),
      ],
    );
  }

  Widget _buildEventsList(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Événements du ${_selectedDate.day}/${_selectedDate.month}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        ...eventsForDay(_selectedDate).map((event) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: event.color.withAlpha(12),
              border: Border.all(
                color: event.color.withAlpha(40),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: event.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        event.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  event.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: event.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNoEvents(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 32,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun événement ce jour',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

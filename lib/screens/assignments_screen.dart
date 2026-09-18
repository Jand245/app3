import 'package:flutter/material.dart';

import '../models/app_data_store.dart';
import '../models/assignment_item.dart';
import 'assignment_create_screen.dart';
import 'assignment_detail_screen.dart';
import 'monthly_calendar_view.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({required this.store, super.key});

  final AppDataStore store;

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const _monthLabels = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final DateTime _today;

  List<AssignmentItem> get _assignments => widget.store.assignments;

  DateTime get _weekStart =>
      _today.subtract(Duration(days: _today.weekday - DateTime.monday));

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 7));

  List<AssignmentItem> get _weeklyAssignments {
    final assignments = _assignments.where(
      (assignment) =>
          !assignment.dueDate.isBefore(_weekStart) &&
          assignment.dueDate.isBefore(_weekEnd),
    );
    return assignments.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    widget.store.addListener(_handleStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_handleStoreChanged);
    super.dispose();
  }

  void _handleStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _createAssignment() async {
    final assignment = await Navigator.push<AssignmentItem>(
      context,
      MaterialPageRoute(builder: (_) => const AssignmentCreateScreen()),
    );
    if (assignment != null && mounted) {
      widget.store.addAssignment(assignment);
    }
  }

  void _replaceAssignment(AssignmentItem updatedAssignment) {
    widget.store.updateAssignment(updatedAssignment);
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlyCalendarView(
          assignments: List.unmodifiable(_assignments),
          onAssignmentChanged: _replaceAssignment,
        ),
      ),
    );
  }

  Future<void> _openAssignment(AssignmentItem assignment) async {
    final updatedAssignment = await Navigator.push<AssignmentItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
    if (updatedAssignment != null && mounted) {
      _replaceAssignment(updatedAssignment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklyAssignments = _weeklyAssignments;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
        children: [
          Text(
            'Assignments',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          _buildWeekCard(context),
          const SizedBox(height: 28),
          Text('This week', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (weeklyAssignments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No assignments due this week.')),
            )
          else
            ...weeklyAssignments.map(_buildAssignmentTile),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create-assignment-button'),
        heroTag: 'create-assignment',
        onPressed: _createAssignment,
        icon: const Icon(Icons.add),
        label: const Text('Create assignment'),
      ),
    );
  }

  List<AssignmentItem> _assignmentsForDay(DateTime day) {
    return _assignments.where((assignment) {
      final dueDate = assignment.dueDate;

      return dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day;
    }).toList();
  }

  Widget _buildWeekCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('open-month-calendar'),
        onTap: _openCalendar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_monthLabels[_today.month - 1]} ${_today.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.calendar_month_outlined),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final date = _weekStart.add(Duration(days: index));
                  final isToday = date == _today;
                  final dateAssignments = _assignmentsForDay(date);

                  return Column(
                    children: [
                      Text(_weekdayLabels[index]),
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? colorScheme.primary : null,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isToday ? colorScheme.onPrimary : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: dateAssignments.take(3).map((assignment) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: Color(assignment.colorValue),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to view the full month',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentTile(AssignmentItem assignment) {
    final weekday = _weekdayLabels[assignment.dueDate.weekday - 1];

    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined),
        title: Text(assignment.title),
        subtitle: Text(assignment.course),
        trailing: Text(
          '$weekday ${assignment.dueDate.month}/${assignment.dueDate.day}\n'
          '${TimeOfDay.fromDateTime(assignment.dueDate).format(context)}',
          textAlign: TextAlign.end,
        ),
        onTap: () => _openAssignment(assignment),
      ),
    );
  }
}

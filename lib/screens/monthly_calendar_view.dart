import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/assignment_item.dart';
import 'assignment_detail_screen.dart';

class MonthlyCalendarView extends StatefulWidget {
  const MonthlyCalendarView({
    required this.assignments,
    required this.onAssignmentChanged,
    super.key,
  });

  final List<AssignmentItem> assignments;
  final ValueChanged<AssignmentItem> onAssignmentChanged;

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late DateTime _selectedDate;
  late DateTime _focusedDay;
  late final List<AssignmentItem> _assignments;

  List<AssignmentItem> get _selectedAssignments {
    final assignments = _assignments.where(
      (assignment) => _isSameDay(assignment.dueDate, _selectedDate),
    );
    return assignments.toList()..sort((a, b) => a.title.compareTo(b.title));
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    _focusedDay = _selectedDate;
    _assignments = widget.assignments.toList();
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  Future<void> _openAssignment(AssignmentItem assignment) async {
    final updatedAssignment = await Navigator.push<AssignmentItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailScreen(assignment: assignment),
      ),
    );
    if (updatedAssignment == null || !mounted) return;
    final index = _assignments.indexWhere(
      (item) => item.id == updatedAssignment.id,
    );
    if (index == -1) return;
    setState(() => _assignments[index] = updatedAssignment);
    widget.onAssignmentChanged(updatedAssignment);
  }

  List<AssignmentItem> _assignmentsForDay(DateTime day) {
    return _assignments.where((assignment) {
      return _isSameDay(assignment.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _selectedAssignments;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar<AssignmentItem>(
            key: const Key('monthly-calendar'),
            firstDay: DateTime(_selectedDate.year - 5),
            lastDay: DateTime(_selectedDate.year + 5, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return _isSameDay(day, _selectedDate);
            },
            eventLoader: _assignmentsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders<AssignmentItem>(
              markerBuilder: (context, day, assignments) {
                if (assignments.isEmpty) return null;

                return Positioned(
                  bottom: 5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: assignments.take(3).map((assignment) {
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
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assignments for ${_selectedDate.month}/${_selectedDate.day}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: assignments.isEmpty
                ? const Center(child: Text('No assignments due this day.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.assignment_outlined),
                          title: Text(assignment.title),
                          subtitle: Text(assignment.course),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openAssignment(assignment),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

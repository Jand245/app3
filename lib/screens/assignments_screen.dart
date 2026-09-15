import 'package:flutter/material.dart';

import 'placeholder_page.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Assignments',
      icon: Icons.calendar_month_outlined,
      message: 'Assignments, due dates, and the calendar will appear here.',
    );
  }
}

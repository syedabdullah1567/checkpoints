import 'package:flutter/material.dart';
import 'package:checkpoints/pages/tasks.dart';

class HomepageCheckpoints extends StatefulWidget {
  const HomepageCheckpoints({super.key});

  @override
  State<HomepageCheckpoints> createState() => _HomepageCheckpointsState();
}

class _HomepageCheckpointsState extends State<HomepageCheckpoints> {
  int currentIndex = 0;
  final List<Widget> _screens = [
    const ToDoPage(pageId: 0),
    const ToDoPage(pageId: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Today',
            selectedIcon: Icon(Icons.check_circle),
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Long-term',
            selectedIcon: Icon(Icons.calendar_month),
          ),
        ],
        onDestinationSelected: (value) => {
          setState(() {
            currentIndex = value;
          }),
        },
      ),
    );
  }
}

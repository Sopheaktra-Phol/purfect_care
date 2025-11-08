import 'package:flutter/material.dart';

class ProgressTracker extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const ProgressTracker({super.key, required this.completedTasks, required this.totalTasks});

  @override
  Widget build(BuildContext context) {
    final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$completedTasks / $totalTasks'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

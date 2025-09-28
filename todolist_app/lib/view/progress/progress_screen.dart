import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_application/secure_application.dart';
import 'package:todolist_app/viewmodel/task/task_viewmodel.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    SecureApplicationProvider.of(context, listen: false)!.secure();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Consumer<TaskViewModel>(
          builder: (context, viewModel, child) {
            final totalTasks = viewModel.tasks.length;
            final completedTasks =
                viewModel.tasks.where((t) => t.isCompleted).length;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tu progreso',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                Text('$completedTasks / $totalTasks',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Tasks Completed',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    SecureApplicationProvider.of(context, listen: false)!.open();
    super.dispose();
  }
}
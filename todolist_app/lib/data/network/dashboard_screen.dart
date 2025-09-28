import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Lógica para el menú de opciones (se implementará más adelante)
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to your Dashboard!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para agregar una nueva tarea (se implementará más adelante)
        },
        tooltip: 'Add To-Do',
        child: const Icon(Icons.add),
      ),
    );
  }
}
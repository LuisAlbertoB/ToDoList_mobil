import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_application/secure_application.dart';
import 'package:todolist_app/model/task_model.dart';
import 'package:todolist_app/view/progress/progress_screen.dart';
import 'package:todolist_app/viewmodel/auth/auth_viewmodel.dart';
import 'package:todolist_app/viewmodel/task/task_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bloqueamos las capturas de pantalla en esta vista (solo para Android)
    SecureApplicationProvider.of(context, listen: false)!.secure();

    // Usamos addPostFrameCallback para asegurarnos de que el contexto esté disponible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtenemos el token del AuthViewModel.
      final token = Provider.of<AuthViewModel>(context, listen: false).token;
      if (token != null) {
        // Solicitamos al TaskViewModel que cargue las tareas.
        Provider.of<TaskViewModel>(context, listen: false)
            .getTasks(token: token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en TaskViewModel para redibujar la UI.
    final taskViewModel = Provider.of<TaskViewModel>(context);
    // No necesitamos escuchar cambios en AuthViewModel aquí, solo acceder a su estado.
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // El título cambia dinámicamente si hay tareas seleccionadas.
        title: Text(taskViewModel.hasSelection
            ? '${taskViewModel.selectedTaskIds.length} selected'
            : 'My To-Do List'),
        actions: [
          // Botón para navegar a la pantalla de progreso.
          // Solo se muestra si no hay tareas seleccionadas.
          if (!taskViewModel.hasSelection)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressScreen()),
                );
              },
              child: const Text('Ir a progreso'),
            ),
          if (taskViewModel.hasSelection)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  taskViewModel.deleteSelectedTasks(token: authViewModel.token!);
                }
                if (value == 'complete') {
                  taskViewModel.markSelectedTasksAsCompleted(token: authViewModel.token!);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
                const PopupMenuItem<String>(
                  value: 'complete',
                  child: Text('Mark as Complete'),
                ),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          // --- MITAD SUPERIOR: Formulario de Creación ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'New Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- MITAD INFERIOR: Lista de Tareas ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('LABELS',
                  style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.state == TaskState.loading &&
                    viewModel.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.tasks.isEmpty) {
                  return const Center(child: Text('No tasks yet. Add one!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Espacio para el FAB
                  itemCount: viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = viewModel.tasks[index];
                    return TaskItemTile(
                      task: task,
                      isSelected: viewModel.selectedTaskIds.contains(task.id),
                      onSelected: () => viewModel.toggleTaskSelection(task.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_titleController.text.isNotEmpty) {
            await taskViewModel.createTask(
              title: _titleController.text,
              content: _contentController.text,
              token: authViewModel.token!,
            );
            _titleController.clear();
            _contentController.clear();
            FocusScope.of(context).unfocus(); // Ocultar teclado
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Title cannot be empty.'),
              backgroundColor: Colors.orange,
            ));
          }
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // Es importante limpiar el flag al salir de la pantalla para que otras apps
    // (o la pantalla de Sign In si volvemos) puedan tomar capturas.
    SecureApplicationProvider.of(context, listen: false)!.open();
    super.dispose();
  }
}

/// Molécula reutilizable para cada "Label" o tarea en la lista.
/// Usa un [ExpansionTile] para mostrar/ocultar el contenido.
class TaskItemTile extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onSelected;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
      child: ExpansionTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            onSelected();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)
                    .copyWith(left: 72), // Alineado con el título
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(task.content.isEmpty
                  ? 'No additional content.'
                  : task.content),
            ),
          ),
        ],
      ),
    );
  }
}

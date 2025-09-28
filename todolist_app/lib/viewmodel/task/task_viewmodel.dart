import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:todolist_app/data/repository/task_repository.dart';
import 'package:todolist_app/model/task_model.dart';

enum TaskState { idle, loading, success, error }

/// [TaskViewModel] gestiona el estado y la lógica de negocio para las tareas.
///
/// Se comunica con [TaskRepository] para realizar operaciones CRUD y notifica
/// a los widgets que lo escuchan sobre cualquier cambio en el estado, como la
/// lista de tareas, el estado de carga o los errores.
class TaskViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // Para manejar las selecciones de los checkboxes
  final Set<int> _selectedTaskIds = {};
  Set<int> get selectedTaskIds => _selectedTaskIds;
  bool get hasSelection => _selectedTaskIds.isNotEmpty;

  TaskState _state = TaskState.idle;
  TaskState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(TaskState state) {
    _state = state;
    notifyListeners();
  }

  void toggleTaskSelection(int taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    notifyListeners();
  }

  /// Ordena la lista de tareas.
  /// Las tareas incompletas van primero, y luego se ordenan por fecha de creación (más nuevas primero).
  /// Las tareas completadas van al final, también ordenadas por fecha.
  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      // Si ambas tienen el mismo estado, la más nueva va primero.
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> getTasks({required String token}) async {
    _setState(TaskState.loading);
    try {
      _tasks = await _taskRepository.getTasks(token: token);
      _sortTasks(); // Ordenamos la lista después de obtenerla.
      _setState(TaskState.success);
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to fetch tasks.';
      _setState(TaskState.error);
    }
  }

  Future<void> createTask({
    required String title,
    required String content,
    required String token,
  }) async {
    _setState(TaskState.loading);
    try {
      final newTask = await _taskRepository.createTask(
          title: title, content: content, token: token);
      _tasks.add(newTask);
      _sortTasks(); // Reordenamos para que aparezca al principio de las incompletas.
      _setState(TaskState.success);
    } on DioException catch (e) {
      _errorMessage = e.response?.data['error'] ?? 'Failed to create task.';
      _setState(TaskState.error);
    }
  }

  Future<void> updateTaskStatus(
      {required int taskId, required bool isCompleted, required String token}) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final originalTask = _tasks[taskIndex];
    final updatedTask = Task(
      id: originalTask.id,
      title: originalTask.title,
      content: originalTask.content,
      createdAt: originalTask.createdAt,
      isCompleted: isCompleted,
      userId: originalTask.userId,
    );

    _tasks[taskIndex] = updatedTask;
    _sortTasks(); // Reordenamos la lista después de actualizar el estado.
    notifyListeners();

    try {
      await _taskRepository.updateTask(task: updatedTask, token: token);
    } catch (e) {
      // Si falla, revertimos el cambio en la UI
      _tasks[taskIndex] = originalTask;
      _sortTasks(); // Y volvemos a ordenar.
      notifyListeners();
      // Opcional: mostrar un error
    }
  }

  Future<void> markSelectedTasksAsCompleted({required String token}) async {
    // Copiamos la lista de IDs para evitar problemas al modificarla.
    final tasksToUpdate = _selectedTaskIds.toList();

    // Limpiamos la selección en la UI inmediatamente.
    clearSelection();

    // Creamos una lista de futuras actualizaciones.
    final updateFutures = tasksToUpdate.map((taskId) =>
        updateTaskStatus(taskId: taskId, isCompleted: true, token: token));

    // Esperamos a que todas las actualizaciones se completen.
    // La UI ya se actualiza de forma optimista dentro de `updateTaskStatus`.
    await Future.wait(updateFutures);
  }

  Future<void> deleteSelectedTasks({required String token}) async {
    final tasksToDelete =
        _tasks.where((t) => _selectedTaskIds.contains(t.id)).toList();
    
    // Optimistic UI update
    _tasks.removeWhere((t) => _selectedTaskIds.contains(t.id));
    _selectedTaskIds.clear();
    notifyListeners();

    try {
      // Enviar todas las peticiones de borrado
      for (final task in tasksToDelete) {
        await _taskRepository.deleteTask(taskId: task.id, token: token);
      }
    } catch (e) {
      // Si falla, podríamos recargar la lista para resincronizar
      await getTasks(token: token);
    }
  }
}

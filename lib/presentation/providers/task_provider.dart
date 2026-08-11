import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lead_task_model.dart';
import '../../data/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskState {
  final bool isLoading;
  final List<LeadTaskModel> tasks;
  final String statusFilter;
  final String? error;

  TaskState({
    this.isLoading = false,
    this.tasks = const [],
    this.statusFilter = 'ALL',
    this.error,
  });

  TaskState copyWith({
    bool? isLoading,
    List<LeadTaskModel>? tasks,
    String? statusFilter,
    String? error,
  }) {
    return TaskState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      statusFilter: statusFilter ?? this.statusFilter,
      error: error,
    );
  }
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(TaskState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasks(status: state.statusFilter);
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String status) {
    state = state.copyWith(statusFilter: status);
    loadTasks();
  }

  Future<bool> createTask(LeadTaskModel task) async {
    try {
      await _repository.createTask(task);
      await loadTasks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> completeTask(String taskId, {String? leadId}) async {
    try {
      await _repository.updateTaskStatus(taskId, 'COMPLETED', leadId: leadId);
      await loadTasks();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repo);
});

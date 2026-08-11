import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_metrics_model.dart';
import '../../data/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository();
});

class DashboardState {
  final bool isLoading;
  final DashboardMetricsModel metrics;
  final Map<String, dynamic> systemHealth;
  final String? error;

  DashboardState({
    this.isLoading = false,
    DashboardMetricsModel? metrics,
    this.systemHealth = const {},
    this.error,
  }) : metrics = metrics ?? DashboardMetricsModel();

  DashboardState copyWith({
    bool? isLoading,
    DashboardMetricsModel? metrics,
    Map<String, dynamic>? systemHealth,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      metrics: metrics ?? this.metrics,
      systemHealth: systemHealth ?? this.systemHealth,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AnalyticsRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final metrics = await _repository.getDashboardMetrics();
      final health = await _repository.getSystemHealth();
      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        systemHealth: health,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return DashboardNotifier(repo);
});

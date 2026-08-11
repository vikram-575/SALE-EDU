import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  return LeadRepository();
});

class LeadState {
  final bool isLoading;
  final List<LeadModel> leads;
  final String selectedStageFilter;
  final String selectedSourceFilter;
  final String selectedPriorityFilter;
  final String searchQuery;
  final String? error;

  LeadState({
    this.isLoading = false,
    this.leads = const [],
    this.selectedStageFilter = 'ALL',
    this.selectedSourceFilter = 'ALL',
    this.selectedPriorityFilter = 'ALL',
    this.searchQuery = '',
    this.error,
  });

  LeadState copyWith({
    bool? isLoading,
    List<LeadModel>? leads,
    String? selectedStageFilter,
    String? selectedSourceFilter,
    String? selectedPriorityFilter,
    String? searchQuery,
    String? error,
  }) {
    return LeadState(
      isLoading: isLoading ?? this.isLoading,
      leads: leads ?? this.leads,
      selectedStageFilter: selectedStageFilter ?? this.selectedStageFilter,
      selectedSourceFilter: selectedSourceFilter ?? this.selectedSourceFilter,
      selectedPriorityFilter: selectedPriorityFilter ?? this.selectedPriorityFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

class LeadNotifier extends StateNotifier<LeadState> {
  final LeadRepository _repository;

  LeadNotifier(this._repository) : super(LeadState()) {
    loadLeads();
  }

  Future<void> loadLeads() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leads = await _repository.getLeads(
        stage: state.selectedStageFilter,
        source: state.selectedSourceFilter,
        priority: state.selectedPriorityFilter,
        searchQuery: state.searchQuery,
      );
      state = state.copyWith(isLoading: false, leads: leads);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadLeads();
  }

  void setStageFilter(String stage) {
    state = state.copyWith(selectedStageFilter: stage);
    loadLeads();
  }

  void setSourceFilter(String source) {
    state = state.copyWith(selectedSourceFilter: source);
    loadLeads();
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(selectedPriorityFilter: priority);
    loadLeads();
  }

  Future<bool> createLead(LeadModel lead) async {
    try {
      await _repository.createLead(lead);
      await loadLeads();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> changeStage(String leadId, String newStage, {String? previousStage, String? reason}) async {
    try {
      await _repository.changeLeadStage(
        leadId: leadId,
        newStage: newStage,
        previousStage: previousStage,
        reason: reason,
      );
      await loadLeads();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final leadProvider = StateNotifierProvider<LeadNotifier, LeadState>((ref) {
  final repo = ref.watch(leadRepositoryProvider);
  return LeadNotifier(repo);
});

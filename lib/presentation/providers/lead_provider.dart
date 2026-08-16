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
  final String? selectedCity;
  final String? selectedDistrict;
  final String? selectedPincode;
  final String searchQuery;
  final String? error;

  LeadState({
    this.isLoading = false,
    this.leads = const [],
    this.selectedStageFilter = 'ALL',
    this.selectedSourceFilter = 'ALL',
    this.selectedPriorityFilter = 'ALL',
    this.selectedCity,
    this.selectedDistrict,
    this.selectedPincode,
    this.searchQuery = '',
    this.error,
  });

  LeadState copyWith({
    bool? isLoading,
    List<LeadModel>? leads,
    String? selectedStageFilter,
    String? selectedSourceFilter,
    String? selectedPriorityFilter,
    String? selectedCity,
    String? selectedDistrict,
    String? selectedPincode,
    String? searchQuery,
    String? error,
  }) {
    return LeadState(
      isLoading: isLoading ?? this.isLoading,
      leads: leads ?? this.leads,
      selectedStageFilter: selectedStageFilter ?? this.selectedStageFilter,
      selectedSourceFilter: selectedSourceFilter ?? this.selectedSourceFilter,
      selectedPriorityFilter: selectedPriorityFilter ?? this.selectedPriorityFilter,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedPincode: selectedPincode ?? this.selectedPincode,
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
    state = state.copyWith(isLoading: state.leads.isEmpty, error: null);
    try {
      final leads = await _repository.getLeads(
        stage: state.selectedStageFilter,
        source: state.selectedSourceFilter,
        priority: state.selectedPriorityFilter,
        cityFilter: state.selectedCity,
        districtFilter: state.selectedDistrict,
        pincodeFilter: state.selectedPincode,
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

  void setGeoFilters({String? city, String? district, String? pincode}) {
    state = LeadState(
      isLoading: true,
      leads: state.leads,
      selectedStageFilter: state.selectedStageFilter,
      selectedSourceFilter: state.selectedSourceFilter,
      selectedPriorityFilter: state.selectedPriorityFilter,
      selectedCity: city,
      selectedDistrict: district,
      selectedPincode: pincode,
      searchQuery: state.searchQuery,
    );
    loadLeads();
  }

  void clearGeoFilters() {
    state = LeadState(
      isLoading: true,
      leads: state.leads,
      selectedStageFilter: state.selectedStageFilter,
      selectedSourceFilter: state.selectedSourceFilter,
      selectedPriorityFilter: state.selectedPriorityFilter,
      selectedCity: null,
      selectedDistrict: null,
      selectedPincode: null,
      searchQuery: state.searchQuery,
    );
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

  // Fast optimistic update + Supabase sync
  Future<bool> createLead(LeadModel lead) async {
    try {
      final updatedLeads = [lead, ...state.leads];
      state = state.copyWith(leads: updatedLeads);

      await _repository.createLead(lead);
      await loadLeads();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Fast update lead
  Future<bool> updateLead(LeadModel lead) async {
    try {
      final updatedLeads = state.leads.map((l) => l.id == lead.id ? lead : l).toList();
      state = state.copyWith(leads: updatedLeads);

      await _repository.updateLead(lead);
      await loadLeads();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Fast optimistic stage change
  Future<bool> changeStage(String leadId, String newStage, {String? previousStage, String? reason}) async {
    try {
      final updatedLeads = state.leads.map((l) {
        if (l.id == leadId) {
          return l.copyWith(stage: newStage);
        }
        return l;
      }).toList();
      state = state.copyWith(leads: updatedLeads);

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

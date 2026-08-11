import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';

class CopilotState {
  final bool isLoading;
  final String? reply;
  final Map<String, dynamic> groundedData;
  final String? error;

  CopilotState({
    this.isLoading = false,
    this.reply,
    this.groundedData = const {},
    this.error,
  });

  CopilotState copyWith({
    bool? isLoading,
    String? reply,
    Map<String, dynamic>? groundedData,
    String? error,
  }) {
    return CopilotState(
      isLoading: isLoading ?? this.isLoading,
      reply: reply ?? this.reply,
      groundedData: groundedData ?? this.groundedData,
      error: error,
    );
  }
}

class CopilotNotifier extends StateNotifier<CopilotState> {
  CopilotNotifier() : super(CopilotState());

  Future<void> askCopilot(String prompt, {String? leadId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.queryCopilot(prompt: prompt, leadId: leadId);
      if (res['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          reply: res['copilotReply'],
          groundedData: res['groundedData'] ?? {},
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['error']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final copilotProvider = StateNotifierProvider<CopilotNotifier, CopilotState>((ref) {
  return CopilotNotifier();
});

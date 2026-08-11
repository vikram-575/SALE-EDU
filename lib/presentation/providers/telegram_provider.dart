import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/telegram_message_model.dart';
import '../../data/repositories/telegram_repository.dart';

final telegramRepositoryProvider = Provider<TelegramRepository>((ref) {
  return TelegramRepository();
});

class TelegramState {
  final bool isLoading;
  final List<TelegramConversationModel> conversations;
  final String currentFilter;
  final String? activeConversationId;
  final List<TelegramMessageModel> messages;
  final List<Map<String, dynamic>> templates;
  final String? error;

  TelegramState({
    this.isLoading = false,
    this.conversations = const [],
    this.currentFilter = 'ALL',
    this.activeConversationId,
    this.messages = const [],
    this.templates = const [],
    this.error,
  });

  TelegramState copyWith({
    bool? isLoading,
    List<TelegramConversationModel>? conversations,
    String? currentFilter,
    String? activeConversationId,
    List<TelegramMessageModel>? messages,
    List<Map<String, dynamic>>? templates,
    String? error,
  }) {
    return TelegramState(
      isLoading: isLoading ?? this.isLoading,
      conversations: conversations ?? this.conversations,
      currentFilter: currentFilter ?? this.currentFilter,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      messages: messages ?? this.messages,
      templates: templates ?? this.templates,
      error: error,
    );
  }
}

class TelegramNotifier extends StateNotifier<TelegramState> {
  final TelegramRepository _repository;

  TelegramNotifier(this._repository) : super(TelegramState()) {
    loadConversations();
    loadTemplates();
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final convs = await _repository.getConversations(filter: state.currentFilter);
      state = state.copyWith(isLoading: false, conversations: convs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(currentFilter: filter);
    loadConversations();
  }

  Future<void> openConversation(String conversationId) async {
    state = state.copyWith(activeConversationId: conversationId, isLoading: true);
    try {
      final msgs = await _repository.getMessages(conversationId);
      state = state.copyWith(isLoading: false, messages: msgs);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> sendMessage(String text, {String? leadId}) async {
    final convId = state.activeConversationId;
    if (convId == null) return false;

    try {
      final ok = await _repository.sendMessage(
        conversationId: convId,
        content: text,
        leadId: leadId,
      );
      if (ok) {
        await openConversation(convId);
        await loadConversations();
      }
      return ok;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> loadTemplates() async {
    try {
      final tpls = await _repository.getTemplates();
      state = state.copyWith(templates: tpls);
    } catch (_) {}
  }
}

final telegramProvider = StateNotifierProvider<TelegramNotifier, TelegramState>((ref) {
  final repo = ref.watch(telegramRepositoryProvider);
  return TelegramNotifier(repo);
});

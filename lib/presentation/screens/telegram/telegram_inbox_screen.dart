import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/telegram_provider.dart';
import 'telegram_chat_screen.dart';

class TelegramInboxScreen extends ConsumerWidget {
  const TelegramInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telegramState = ref.watch(telegramProvider);
    final telegramNotifier = ref.read(telegramProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Telegram Inbox', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => telegramNotifier.loadConversations(),
          )
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('ALL', telegramState.currentFilter == 'ALL', () => telegramNotifier.setFilter('ALL')),
                _filterChip('UNREAD', telegramState.currentFilter == 'UNREAD', () => telegramNotifier.setFilter('UNREAD')),
                _filterChip('UNMATCHED', telegramState.currentFilter == 'UNMATCHED', () => telegramNotifier.setFilter('UNMATCHED')),
                _filterChip('HOT LEADS', telegramState.currentFilter == 'HOT_LEADS', () => telegramNotifier.setFilter('HOT_LEADS')),
              ],
            ),
          ),

          Expanded(
            child: telegramState.isLoading
                ? const LoadingIndicator(message: 'Syncing Telegram Conversations...')
                : telegramState.conversations.isEmpty
                    ? const EmptyStateWidget(
                        message: 'No Telegram conversations yet.',
                        subtitle: 'Incoming prospect messages via EducateSetu Telegram Bot will appear here in real-time.',
                        icon: Icons.send_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => telegramNotifier.loadConversations(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: telegramState.conversations.length,
                          itemBuilder: (context, index) {
                            final conv = telegramState.conversations[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  telegramNotifier.openConversation(conv.id);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelegramChatScreen(
                                        conversationId: conv.id,
                                        telegramChatId: conv.telegramChatId,
                                        contactName: conv.contactName ?? conv.telegramUsername ?? 'Prospect',
                                        leadId: conv.leadId,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: conv.isMatched ? AppColors.primary : AppColors.warning,
                                  child: Icon(conv.isMatched ? Icons.school : Icons.person_outline, color: Colors.white, size: 20),
                                ),
                                title: Text(
                                  conv.contactName ?? conv.telegramUsername ?? 'Unknown Telegram Contact',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                subtitle: Text(
                                  conv.isMatched ? 'Linked to Lead record' : '⚠️ Unmatched Telegram Chat',
                                  style: TextStyle(
                                    color: conv.isMatched ? AppColors.textSecondary : AppColors.warning,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(DateFormatter.formatTimeAgo(conv.lastMessageAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    if (conv.unreadCount > 0) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                                        child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

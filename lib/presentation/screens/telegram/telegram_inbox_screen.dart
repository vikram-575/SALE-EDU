import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/telegram_provider.dart';
import 'telegram_chat_screen.dart';
import 'link_telegram_modal.dart';

class TelegramInboxScreen extends ConsumerStatefulWidget {
  const TelegramInboxScreen({super.key});

  @override
  ConsumerState<TelegramInboxScreen> createState() => _TelegramInboxScreenState();
}

class _TelegramInboxScreenState extends ConsumerState<TelegramInboxScreen> {
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'ALL',
    'UNREAD',
    'ASSIGNED TO ME',
    'HOT LEADS',
    'CUSTOMERS',
    'WAITING FOR REPLY',
    'FOLLOW-UP',
    'UNMATCHED',
    'ARCHIVED',
  ];

  @override
  Widget build(BuildContext context) {
    final telegramState = ref.watch(telegramProvider);
    final telegramNotifier = ref.read(telegramProvider.notifier);

    final filteredList = telegramState.conversations.where((conv) {
      if (_searchController.text.trim().isEmpty) return true;
      final q = _searchController.text.toLowerCase().trim();
      return conv.contactName.toLowerCase().contains(q) ||
          (conv.telegramUsername != null && conv.telegramUsername!.toLowerCase().contains(q)) ||
          conv.telegramChatId.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Telegram CRM Inbox', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => telegramNotifier.loadConversations(),
          )
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search prospect name, @username, chat ID...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 9 Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _filters.map((f) {
                final isSel = telegramState.currentFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(f, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onSelected: (_) => telegramNotifier.setFilter(f),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: telegramState.isLoading
                ? const LoadingIndicator(message: 'Syncing Telegram Inbox...')
                : filteredList.isEmpty
                    ? const EmptyStateWidget(
                        message: 'No Telegram conversations found.',
                        subtitle: 'Incoming prospect messages via EducateSetu Bot will appear here in real-time.',
                        icon: Icons.send_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => telegramNotifier.loadConversations(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final conv = filteredList[index];
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
                                        contactName: conv.contactName,
                                        leadId: conv.leadId,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: conv.isMatched ? AppColors.primary : AppColors.warning,
                                  child: Icon(conv.isMatched ? Icons.school : Icons.person_outline, color: Colors.white, size: 20),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conv.contactName,
                                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    if (conv.priority == 'HIGH' || conv.priority == 'URGENT')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(4)),
                                        child: Text(conv.priority ?? 'HIGH', style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                      )
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      conv.isMatched ? 'Linked Lead Record' : '⚠️ Unmatched Telegram Chat',
                                      style: TextStyle(
                                        color: conv.isMatched ? AppColors.textSecondary : AppColors.warning,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (!conv.isMatched) ...[
                                      const SizedBox(height: 4),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: AppColors.surface,
                                            builder: (context) => LinkTelegramModal(
                                              conversationId: conv.id,
                                              telegramChatId: conv.telegramChatId,
                                              telegramUsername: conv.telegramUsername,
                                              contactName: conv.contactName,
                                            ),
                                          );
                                        },
                                        child: const Text('🔗 LINK TO LEAD / CUSTOMER', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                                      )
                                    ]
                                  ],
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
}

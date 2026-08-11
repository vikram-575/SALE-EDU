import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/telegram_message_model.dart';
import '../../providers/telegram_provider.dart';
import '../../providers/copilot_provider.dart';
import 'telegram_profile_sheet.dart';

class TelegramChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String telegramChatId;
  final String contactName;
  final String? leadId;

  const TelegramChatScreen({
    super.key,
    required this.conversationId,
    required this.telegramChatId,
    required this.contactName,
    this.leadId,
  });

  @override
  ConsumerState<TelegramChatScreen> createState() => _TelegramChatScreenState();
}

class _TelegramChatScreenState extends ConsumerState<TelegramChatScreen> {
  final _messageController = TextEditingController();
  bool _isDraftingAI = false;

  void _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final ok = await ref.read(telegramProvider.notifier).sendMessage(
          text,
          leadId: widget.leadId,
        );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to dispatch Telegram message. Check backend API.')),
      );
    }
  }

  void _runAiAction(String action) async {
    final telegramState = ref.read(telegramProvider);
    TelegramMessageModel? lastProspectMsg;

    for (final m in telegramState.messages.reversed) {
      if (m.senderType == 'PROSPECT') {
        lastProspectMsg = m;
        break;
      }
    }
    lastProspectMsg ??= telegramState.messages.isNotEmpty ? telegramState.messages.last : null;

    final promptText = lastProspectMsg != null
        ? 'Draft a polite, highly persuasive sales reply on Telegram to prospect "${widget.contactName}" who said: "${lastProspectMsg.content}". Offer a 10-minute online demo of EducateSetu School ERP.'
        : 'Draft a welcoming initial Telegram message to school principal "${widget.contactName}" introducing EducateSetu ERP for fee collection and AI report cards.';

    setState(() => _isDraftingAI = true);
    await ref.read(copilotProvider.notifier).askCopilot(promptText);
    final copilotReply = ref.read(copilotProvider).reply;

    if (mounted) {
      setState(() {
        _isDraftingAI = false;
        if (copilotReply != null && copilotReply.isNotEmpty) {
          _messageController.text = copilotReply;
        }
      });
    }
  }

  void _showTemplatePicker() {
    final telegramState = ref.watch(telegramProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: telegramState.templates.length,
        itemBuilder: (context, index) {
          final tpl = telegramState.templates[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(tpl['title'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              subtitle: Text(tpl['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                final filledText = (tpl['content'] ?? '').replaceAll('{{contact_name}}', widget.contactName).replaceAll('{{sales_agent}}', 'Vikram');
                _messageController.text = filledText;
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telegramState = ref.watch(telegramProvider);
    final conv = telegramState.conversations.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => TelegramConversationModel(
        id: widget.conversationId,
        telegramChatId: widget.telegramChatId,
        contactName: widget.contactName,
        lastMessageAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.surface,
              builder: (context) => TelegramProfileSheet(conversation: conv),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.contactName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              Text('Chat ID: ${widget.telegramChatId} • Tap for Profile', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome, color: AppColors.secondary),
            tooltip: 'Gemini AI Assistant',
            onSelected: (val) => _runAiAction(val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'DRAFT_REPLY', child: Text('✨ Draft Reply')),
              PopupMenuItem(value: 'SUMMARIZE', child: Text('✨ Summarize Conversation')),
              PopupMenuItem(value: 'IDENTIFY_INTENT', child: Text('✨ Classify Intent & Objections')),
              PopupMenuItem(value: 'TRANSLATE', child: Text('✨ Translate to Hindi')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bolt, color: AppColors.primary),
            tooltip: 'Quick Templates',
            onPressed: _showTemplatePicker,
          )
        ],
      ),
      body: Column(
        children: [
          if (_isDraftingAI)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              color: AppColors.secondary.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary)),
                  const SizedBox(width: 10),
                  Text('Gemini AI is analyzing conversation & drafting reply...', style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          Expanded(
            child: telegramState.isLoading
                ? const LoadingIndicator()
                : telegramState.messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Send a message to start conversation!', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: telegramState.messages.length,
                        itemBuilder: (context, index) {
                          final msg = telegramState.messages[index];
                          final isMe = msg.senderType == 'AGENT' || msg.senderType == 'BOT';

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: isMe ? null : Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormatter.formatTime(msg.sentAt),
                                        style: TextStyle(color: isMe ? Colors.white70 : AppColors.textMuted, fontSize: 10),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg.deliveryStatus == 'DELIVERED' ? Icons.done_all : Icons.done,
                                          size: 12,
                                          color: Colors.white70,
                                        )
                                      ]
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_on, color: AppColors.secondary),
                  onPressed: _showTemplatePicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Type Telegram message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

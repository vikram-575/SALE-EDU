import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/telegram_message_model.dart';

class TelegramProfileSheet extends StatelessWidget {
  final TelegramConversationModel conversation;

  const TelegramProfileSheet({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: Text(
                  conversation.contactName.isNotEmpty ? conversation.contactName[0].toUpperCase() : 'T',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conversation.contactName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    if (conversation.telegramUsername != null)
                      Text('@${conversation.telegramUsername}', style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          _infoRow('Telegram Chat ID', conversation.telegramChatId),
          _infoRow('Matched Lead ID', conversation.leadId ?? 'Not Linked (Unmatched)'),
          _infoRow('Conversation Status', conversation.status),
          _infoRow('Priority', conversation.priority ?? 'NORMAL'),
          _infoRow('Intent Category', conversation.intentCategory ?? 'UNKNOWN'),
          _infoRow('Marketing Opt-Out', conversation.doNotContact ? 'YES (Do Not Contact)' : 'NO (Subscribed)'),
          const SizedBox(height: 16),

          if (conversation.aiSummary != null && conversation.aiSummary!.isNotEmpty) ...[
            Text('AI CONVERSATION SUMMARY', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(conversation.aiSummary!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

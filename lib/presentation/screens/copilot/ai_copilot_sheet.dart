import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/copilot_provider.dart';

class AICopilotSheet extends ConsumerStatefulWidget {
  const AICopilotSheet({super.key});

  @override
  ConsumerState<AICopilotSheet> createState() => _AICopilotSheetState();
}

class _AICopilotSheetState extends ConsumerState<AICopilotSheet> {
  final _queryController = TextEditingController();

  void _ask(String prompt) {
    _queryController.text = prompt;
    ref.read(copilotProvider.notifier).askCopilot(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final copilotState = ref.watch(copilotProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24),
              const SizedBox(width: 8),
              Text('AI Sales Copilot', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Grounded CRM strategy assistant • Real Supabase Data Queries', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const Divider(height: 20, color: AppColors.border),

          // Suggested Prompts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chipPrompt('Which leads should I contact today?'),
                _chipPrompt('Which trials are active?'),
                _chipPrompt('Pipeline summary'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Response Area
          Expanded(
            child: copilotState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
                : SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        copilotState.reply ?? 'Ask Copilot any sales strategy question or select a prompt above!',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                      ),
                    ),
                  ),
          ),

          // Input Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(hintText: 'Ask Sales Copilot...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.secondary),
                onPressed: () {
                  if (_queryController.text.trim().isNotEmpty) {
                    _ask(_queryController.text.trim());
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _chipPrompt(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(prompt, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        side: const BorderSide(color: AppColors.border),
        onPressed: () => _ask(prompt),
      ),
    );
  }
}

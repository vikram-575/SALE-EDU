import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../data/models/lead_model.dart';
import '../../providers/lead_provider.dart';

class LinkTelegramModal extends ConsumerStatefulWidget {
  final String conversationId;
  final String telegramChatId;
  final String? telegramUsername;
  final String contactName;

  const LinkTelegramModal({
    super.key,
    required this.conversationId,
    required this.telegramChatId,
    this.telegramUsername,
    required this.contactName,
  });

  @override
  ConsumerState<LinkTelegramModal> createState() => _LinkTelegramModalState();
}

class _LinkTelegramModalState extends ConsumerState<LinkTelegramModal> {
  String? _selectedLeadId;
  final _schoolNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _schoolNameController.text = widget.contactName;
    _contactPersonController.text = widget.contactName;
    _phoneController.text = widget.telegramChatId;
  }

  void _submitAction(String action) async {
    setState(() => _isSubmitting = true);

    final result = await ApiService.post('/api/telegram/link', {
      'conversationId': widget.conversationId,
      'action': action,
      'leadId': _selectedLeadId,
      'schoolName': _schoolNameController.text.trim(),
      'contactPerson': _contactPersonController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success'] == true) {
        ref.read(leadProvider.notifier).loadLeads();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Telegram conversation successfully linked: $action')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Linking action failed: ${result['error']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text('Link Telegram Prospect', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Telegram Chat ID: ${widget.telegramChatId} (${widget.telegramUsername != null ? '@${widget.telegramUsername}' : 'No username'})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // Option A: Link to Existing Lead
            Text('OPTION 1: LINK TO EXISTING LEAD', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedLeadId,
              decoration: const InputDecoration(hintText: 'Select existing lead...'),
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              items: leadState.leads.map((l) => DropdownMenuItem(value: l.id, child: Text('${l.schoolName} (${l.contactPerson})'))).toList(),
              onChanged: (val) => setState(() => _selectedLeadId = val),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedLeadId == null || _isSubmitting) ? null : () => _submitAction('LINK_LEAD'),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('LINK TO SELECTED LEAD'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),

            // Option B: Create New Lead
            Text('OPTION 2: CREATE NEW LEAD FROM TELEGRAM', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _schoolNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'School Name *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contactPersonController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Contact Person *'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () => _submitAction('CREATE_LEAD'),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('CREATE NEW LEAD & LINK'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.black),
              ),
            ),
            const SizedBox(height: 16),

            // Option C: Ignore / Block
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => _submitAction('IGNORE'),
                    child: const Text('IGNORE'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => _submitAction('BLOCK'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    child: const Text('BLOCK'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

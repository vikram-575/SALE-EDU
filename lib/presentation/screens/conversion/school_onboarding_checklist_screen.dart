import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/onboarding_model.dart';
import '../../../data/repositories/conversion_repository.dart';

class SchoolOnboardingChecklistScreen extends StatefulWidget {
  final String customerId;
  final String onboardingId;
  final String schoolName;

  const SchoolOnboardingChecklistScreen({
    super.key,
    required this.customerId,
    required this.onboardingId,
    required this.schoolName,
  });

  @override
  State<SchoolOnboardingChecklistScreen> createState() => _SchoolOnboardingChecklistScreenState();
}

class _SchoolOnboardingChecklistScreenState extends State<SchoolOnboardingChecklistScreen> {
  final _conversionRepo = ConversionRepository();
  OnboardingRecordModel? _record;
  bool _isLoading = true;
  bool _isHandoffTriggered = false;

  final Map<String, String> _itemLabels = {
    'schoolProfile': '1. School Profile & Master Data Setup',
    'academicSession': '2. Academic Session & Term Creation',
    'classes': '3. Classes & Grade Configuration',
    'sections': '4. Section Allocation',
    'subjects': '5. Subject & Curriculum Mapping',
    'teachers': '6. Teachers & Staff Directory Onboarding',
    'students': '7. Student Data & Roster Import',
    'parents': '8. Parent Accounts & Phone Linking',
    'timetable': '9. Timetable & Bell Schedule Setup',
    'adminAccounts': '10. Principal & Admin Master Credentials',
    'teacherAccounts': '11. Teacher Portal Credentials',
    'parentAccounts': '12. Parent App & WhatsApp Invitations',
    'notifications': '13. Push Notification & Fee Reminder Rules',
    'training': '14. Staff & Admin Training Session Complete',
    'goLive': '15. FINAL GO-LIVE Verification & Handover',
  };

  late Map<String, bool> _localProgress;

  @override
  void initState() {
    super.initState();
    _localProgress = {
      'schoolProfile': true,
      'academicSession': true,
      'classes': true,
      'sections': true,
      'subjects': false,
      'teachers': false,
      'students': false,
      'parents': false,
      'timetable': false,
      'adminAccounts': true,
      'teacherAccounts': false,
      'parentAccounts': false,
      'notifications': true,
      'training': false,
      'goLive': false,
    };
    _load();
  }

  Future<void> _load() async {
    try {
      final rec = await _conversionRepo.getOnboardingByCustomerId(widget.customerId);
      if (mounted) {
        setState(() {
          if (rec != null) {
            _record = rec;
            _localProgress = Map<String, bool>.from(rec.checklistProgress);
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleItem(String key, bool? val) async {
    setState(() {
      _localProgress[key] = val == true;
    });

    await _conversionRepo.updateOnboardingChecklist(widget.onboardingId, _localProgress);
  }

  void _selectAll(bool checkAll) async {
    setState(() {
      for (var k in _itemLabels.keys) {
        _localProgress[k] = checkAll;
      }
    });

    await _conversionRepo.updateOnboardingChecklist(widget.onboardingId, _localProgress);
  }

  void _triggerHandoff() async {
    setState(() => _isHandoffTriggered = true);

    await _conversionRepo.updateOnboardingChecklist(widget.onboardingId, _localProgress);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.rocket_launch, color: AppColors.secondary, size: 28),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('HANDOFF TRIGGERED!', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎉 School onboarding handoff for "${widget.schoolName}" has been successfully transferred to the Onboarding Operations Team.',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TICKET ID: OPS-ONB-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('Status: ASSIGNED TO ONBOARDING SPECIALIST', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('School: ${widget.schoolName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('BACK TO SALES DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _localProgress.values.where((v) => v == true).length;
    final totalCount = _itemLabels.length;
    final percentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Onboarding Handoff', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Check All Steps',
            onPressed: () => _selectAll(true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School Progress Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rocket_launch, color: AppColors.secondary, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.schoolName,
                                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentage / 100.0,
                          backgroundColor: AppColors.input,
                          color: percentage == 100 ? AppColors.success : AppColors.secondary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress: $completedCount/$totalCount steps completed', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            Text('${percentage.toStringAsFixed(0)}% COMPLETE', style: GoogleFonts.inter(color: percentage == 100 ? AppColors.success : AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ONBOARDING MILESTONES', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1)),
                      TextButton(
                        onPressed: () => _selectAll(completedCount < totalCount),
                        child: Text(completedCount < totalCount ? 'Check All' : 'Reset All', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),

                  ..._itemLabels.entries.map((entry) {
                    final isChecked = _localProgress[entry.key] == true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isChecked,
                        title: Text(
                          entry.value,
                          style: TextStyle(
                            color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        activeColor: AppColors.secondary,
                        onChanged: (val) => _toggleItem(entry.key, val),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _triggerHandoff,
                      icon: const Icon(Icons.send_and_archive, color: Colors.white),
                      label: Text('TRIGGER ONBOARDING OPS HANDOFF', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

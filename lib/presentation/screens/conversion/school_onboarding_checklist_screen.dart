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

  final Map<String, String> _itemLabels = {
    'schoolProfile': '1. School Profile & Setup',
    'academicSession': '2. Academic Session Creation',
    'classes': '3. Classes & Grade Configuration',
    'sections': '4. Sections Setup',
    'subjects': '5. Subjects Allocation',
    'teachers': '6. Teachers Onboarding',
    'students': '7. Student Directory Import',
    'parents': '8. Parent Accounts Linking',
    'timetable': '9. Timetable Generation',
    'adminAccounts': '10. Principal & Admin Credentials',
    'teacherAccounts': '11. Teacher Portal Credentials',
    'parentAccounts': '12. Parent App Invitations',
    'notifications': '13. Push Notification Rules',
    'training': '14. Staff Training Complete',
    'goLive': '15. GO-LIVE Verification',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rec = await _conversionRepo.getOnboardingByCustomerId(widget.customerId);
    if (mounted) {
      setState(() {
        _record = rec;
        _isLoading = false;
      });
    }
  }

  void _toggleItem(String key, bool? val) async {
    if (_record == null) return;
    final updated = Map<String, bool>.from(_record!.checklistProgress);
    updated[key] = val == true;

    await _conversionRepo.updateOnboardingChecklist(widget.onboardingId, updated);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Onboarding Handoff', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          value: (_record?.percentage ?? 0) / 100.0,
                          backgroundColor: AppColors.input,
                          color: AppColors.secondary,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress: ${_record?.completedItemCount}/${_record?.totalItemCount} steps', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            Text('${(_record?.percentage ?? 0).toStringAsFixed(0)}% COMPLETE', style: GoogleFonts.inter(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('SCHOOL ONBOARDING CHECKLIST', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  ..._itemLabels.entries.map((entry) {
                    final isChecked = _record?.checklistProgress[entry.key] == true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isChecked,
                        title: Text(entry.value, style: TextStyle(color: isChecked ? AppColors.textMuted : AppColors.textPrimary, decoration: isChecked ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600, fontSize: 14)),
                        activeColor: AppColors.secondary,
                        onChanged: (val) => _toggleItem(entry.key, val),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

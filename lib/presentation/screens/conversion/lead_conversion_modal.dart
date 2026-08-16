import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/repositories/conversion_repository.dart';
import '../../providers/lead_provider.dart';
import 'school_onboarding_checklist_screen.dart';

class LeadConversionModal extends ConsumerStatefulWidget {
  final LeadModel lead;

  const LeadConversionModal({super.key, required this.lead});

  @override
  ConsumerState<LeadConversionModal> createState() => _LeadConversionModalState();
}

class _LeadConversionModalState extends ConsumerState<LeadConversionModal> {
  final _conversionRepo = ConversionRepository();
  late TextEditingController _annualRevenueController;
  late TextEditingController _monthlyRevenueController;

  bool _isCheckingDuplicates = false;
  bool _isConverting = false;
  Map<String, dynamic>? _duplicateResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _annualRevenueController = TextEditingController(text: widget.lead.expectedValue > 0 ? widget.lead.expectedValue.toStringAsFixed(0) : '150000');
    _monthlyRevenueController = TextEditingController(text: widget.lead.expectedValue > 0 ? (widget.lead.expectedValue / 12.0).toStringAsFixed(0) : '12500');
  }

  void _startConversionScan({bool bypassDuplicate = false}) async {
    setState(() {
      _isCheckingDuplicates = true;
      _errorMessage = null;
    });

    if (!bypassDuplicate) {
      // 1. Run Duplicate Protection Scan
      final dup = await _conversionRepo.checkDuplicates(
        schoolName: widget.lead.schoolName,
        phone: widget.lead.phone,
        email: widget.lead.email,
        website: widget.lead.website,
      );

      if (dup['hasDuplicate'] == true && dup['duplicates'] != null && (dup['duplicates'] as List).isNotEmpty && dup['duplicates'][0]['similarityPercentage'] >= 80) {
        setState(() {
          _isCheckingDuplicates = false;
          _duplicateResult = dup;
        });
        return;
      }
    }

    // 2. Execute Controlled Conversion Transaction
    setState(() {
      _isCheckingDuplicates = false;
      _isConverting = true;
    });

    final res = await _conversionRepo.convertLeadToCustomer(
      leadId: widget.lead.id,
      annualRevenue: double.tryParse(_annualRevenueController.text) ?? 150000.0,
      monthlyRevenue: double.tryParse(_monthlyRevenueController.text) ?? 12500.0,
      bypassDuplicateCheck: bypassDuplicate,
    );

    if (mounted) {
      setState(() => _isConverting = false);
      if (res['success'] == true) {
        // Update local state in Lead Provider
        ref.read(leadProvider.notifier).changeStage(widget.lead.id, 'WON');

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 School Lead successfully converted to Active Customer!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolOnboardingChecklistScreen(
              customerId: res['data']['customerId'] ?? 'cust_${widget.lead.id}',
              onboardingId: res['data']['onboardingId'] ?? 'onb_${widget.lead.id}',
              schoolName: widget.lead.schoolName,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = res['error'] ?? 'Conversion failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: AppColors.success, size: 28),
                const SizedBox(width: 10),
                Text('CONVERT TO CUSTOMER', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Controlled Transaction: Creates Customer + Subscription + Onboarding Record', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 24, color: AppColors.border),

            if (_duplicateResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️ POTENTIAL DUPLICATE CUSTOMER DETECTED', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.warning)),
                    const SizedBox(height: 6),
                    Text(
                      'Match: "${_duplicateResult!['duplicates'][0]['existingSchoolName']}" (${_duplicateResult!['duplicates'][0]['similarityPercentage']}% similarity)',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _startConversionScan(bypassDuplicate: true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                            child: const Text('Override & Convert', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text('School Name: ${widget.lead.schoolName}', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('Contact: ${widget.lead.contactPerson} (${widget.lead.phone ?? 'No phone'})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),

            TextFormField(
              controller: _annualRevenueController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Final Annual Revenue / ARR (₹)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monthlyRevenueController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Monthly Recurring Revenue / MRR (₹)'),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isCheckingDuplicates || _isConverting) ? null : () => _startConversionScan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: (_isCheckingDuplicates || _isConverting)
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('EXECUTE CONVERSION TRANSACTION', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

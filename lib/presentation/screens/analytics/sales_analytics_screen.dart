import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/lead_provider.dart';

class SalesAnalyticsScreen extends ConsumerWidget {
  const SalesAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadState = ref.watch(leadProvider);
    final leads = leadState.leads;

    final newCount = leads.where((l) => l.stage == 'NEW').length;
    final qualCount = leads.where((l) => l.stage == 'QUALIFIED').length;
    final contCount = leads.where((l) => l.stage == 'CONTACTED').length;
    final demoCount = leads.where((l) => l.stage == 'DEMO_BOOKED' || l.stage == 'DEMO_COMPLETED').length;
    final trialCount = leads.where((l) => l.stage == 'TRIAL').length;
    final wonCount = leads.where((l) => l.stage == 'WON').length;
    final lostCount = leads.where((l) => l.stage == 'LOST').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sales Funnel Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIVE STAGE BREAKDOWN', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1)),
            const SizedBox(height: 14),

            _funnelStageCard('1. NEW LEADS', newCount, AppColors.stageNew),
            _funnelStageCard('2. QUALIFIED', qualCount, AppColors.stageQualified),
            _funnelStageCard('3. CONTACTED', contCount, AppColors.stageContacted),
            _funnelStageCard('4. DEMO BOOKED/DONE', demoCount, AppColors.stageDemoBooked),
            _funnelStageCard('5. ACTIVE TRIALS', trialCount, AppColors.stageTrial),
            _funnelStageCard('6. WON CUSTOMERS', wonCount, AppColors.stageWon),

            const SizedBox(height: 24),
            Text('LOST LEAD ANALYSIS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Lost Leads Recorded', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Text('$lostCount', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.danger)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _funnelStageCard(String stageName, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stageName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('$count Leads', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          )
        ],
      ),
    );
  }
}

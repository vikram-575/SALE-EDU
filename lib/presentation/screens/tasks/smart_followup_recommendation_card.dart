import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/services/smart_followup_engine.dart';
import '../leads/lead_detail_screen.dart';

class SmartFollowupRecommendationCard extends StatelessWidget {
  final SmartFollowupRecommendation recommendation;

  const SmartFollowupRecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final lead = recommendation.lead;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.danger.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    'HIGH PRIORITY RECOMMENDATION',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                child: Text('Score: ${lead.leadScore}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(lead.schoolName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Contact: ${lead.contactPerson} (${lead.phone ?? 'No Phone'})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text('Reasoning (Live Database Signals):', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          ...recommendation.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(r, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeadDetailScreen(leadId: lead.id)));
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(recommendation.recommendedAction, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          )
        ],
      ),
    );
  }
}

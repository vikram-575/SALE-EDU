import '../../data/models/lead_model.dart';
import '../../core/utils/currency_formatter.dart';

class SmartFollowupRecommendation {
  final LeadModel lead;
  final String priorityLevel; // HIGH, MEDIUM, NORMAL
  final List<String> reasons;
  final String recommendedAction;

  SmartFollowupRecommendation({
    required this.lead,
    required this.priorityLevel,
    required this.reasons,
    required this.recommendedAction,
  });
}

class SmartFollowupEngine {
  static List<SmartFollowupRecommendation> evaluate(List<LeadModel> leads) {
    final List<SmartFollowupRecommendation> recommendations = [];
    final now = DateTime.now();

    for (var lead in leads) {
      if (lead.stage == 'WON' || lead.stage == 'LOST' || lead.isArchived) continue;

      final List<String> reasons = [];
      int priorityPoints = 0;

      // 1. Days since contact
      if (lead.lastContactedAt != null) {
        final daysInactive = now.difference(lead.lastContactedAt!).inDays;
        if (daysInactive >= 3) {
          priorityPoints += 25;
          reasons.add('No contact for $daysInactive days');
        }
      } else {
        priorityPoints += 20;
        reasons.add('New lead - initial contact pending');
      }

      // 2. Lead score & High Value
      if (lead.leadScore >= 80) {
        priorityPoints += 30;
        reasons.add('HOT Lead Score (${lead.leadScore}/100)');
      }
      if (lead.expectedValue >= 50000) {
        priorityPoints += 25;
        reasons.add('High expected value (${CurrencyFormatter.formatINR(lead.expectedValue)})');
      }

      // 3. Stage signals
      if (lead.stage == 'DEMO_COMPLETED' || lead.stage == 'DEMO COMPLETED') {
        priorityPoints += 30;
        reasons.add('Demo completed - prospect awaiting trial/proposal');
      } else if (lead.stage == 'TRIAL' || lead.stage == 'TRIAL_ACTIVE') {
        priorityPoints += 25;
        reasons.add('Active trial in progress - onboarding check required');
      } else if (lead.stage == 'NEGOTIATION') {
        priorityPoints += 35;
        reasons.add('Negotiation stage - closing opportunity');
      }

      // 4. Decision Maker identified
      if (lead.decisionMaker != null && lead.decisionMaker!.isNotEmpty) {
        priorityPoints += 15;
        reasons.add('Decision maker identified (${lead.decisionMaker})');
      }

      if (reasons.isNotEmpty) {
        String level = 'NORMAL';
        String action = 'Schedule Telegram or Call follow-up.';

        if (priorityPoints >= 60) {
          level = 'HIGH';
          action = 'Contact today via Telegram or Call.';
        } else if (priorityPoints >= 35) {
          level = 'MEDIUM';
          action = 'Send quick Telegram follow-up.';
        }

        recommendations.add(
          SmartFollowupRecommendation(
            lead: lead,
            priorityLevel: level,
            reasons: reasons,
            recommendedAction: action,
          ),
        );
      }
    }

    recommendations.sort((a, b) {
      if (a.priorityLevel == 'HIGH' && b.priorityLevel != 'HIGH') return -1;
      if (b.priorityLevel == 'HIGH' && a.priorityLevel != 'HIGH') return 1;
      return b.lead.leadScore.compareTo(a.lead.leadScore);
    });

    return recommendations;
  }
}

import '../../data/models/lead_model.dart';

class LeadScoringEngine {
  static int calculateScore(LeadModel lead) {
    int score = 20; // Base score

    // School Size
    if (lead.approxStudentCount >= 1000) {
      score += 25;
    } else if (lead.approxStudentCount >= 500) {
      score += 15;
    } else if (lead.approxStudentCount >= 200) {
      score += 10;
    }

    // Decision Maker
    if (lead.decisionMaker != null && lead.decisionMaker!.trim().isNotEmpty) {
      score += 15;
    }

    // Current Problems / Pain points
    if (lead.currentProblems != null && lead.currentProblems!.trim().isNotEmpty) {
      score += 15;
    }

    // Stage progression
    switch (lead.stage) {
      case 'QUALIFIED':
        score += 10;
        break;
      case 'CONTACTED':
        score += 15;
        break;
      case 'ENGAGED':
        score += 20;
        break;
      case 'DEMO_BOOKED':
      case 'DEMO BOOKED':
        score += 25;
        break;
      case 'DEMO_COMPLETED':
      case 'DEMO COMPLETED':
        score += 35;
        break;
      case 'TRIAL':
      case 'TRIAL_ACTIVE':
        score += 45;
        break;
      case 'NEGOTIATION':
        score += 50;
        break;
      case 'WON':
        score = 100;
        return score;
      case 'LOST':
        return 0;
    }

    // Telegram engagement
    if (lead.telegramChatId != null || lead.telegramUsername != null) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  static String getClassification(int score) {
    if (score >= 80) return 'HOT';
    if (score >= 60) return 'WARM';
    if (score >= 40) return 'COLD';
    return 'LOW';
  }
}

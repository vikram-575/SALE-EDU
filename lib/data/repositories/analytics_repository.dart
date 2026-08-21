import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/network/api_service.dart';
import '../models/dashboard_metrics_model.dart';

class AnalyticsRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Fetch Dashboard Metrics using LIVE database queries
  Future<DashboardMetricsModel> getDashboardMetrics() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    List<dynamic> leads = [];
    try {
      final leadsRes = await _client
          .from('Lead')
          .select('id, stage, expectedValue, createdAt, updatedAt, nextFollowupAt')
          .eq('isArchived', false);
      leads = leadsRes as List<dynamic>;
    } catch (_) {}

    int todaysLeads = 0;
    int newLeads = 0;
    int qualifiedLeads = 0;
    int contactedLeads = 0;
    int demosToday = 0;
    int activeTrials = 0;
    int wonLeadsCount = 0;
    int lostLeads = 0;
    int overdueFollowups = 0;
    int followupsDueToday = 0;
    double expectedRevenue = 0.0;
    double pipelineValue = 0.0;
    double wonRevenue = 0.0;

    for (var l in leads) {
      final stage = l['stage'] ?? 'NEW';
      final created = l['createdAt'] != null ? DateTime.tryParse(l['createdAt']) : null;
      final val = (l['expectedValue'] as num?)?.toDouble() ?? 0.0;

      if (created != null && created.year == now.year && created.month == now.month && created.day == now.day) {
        todaysLeads++;
      }

      if (stage == 'NEW') newLeads++;
      if (stage == 'QUALIFIED') qualifiedLeads++;
      if (stage == 'CONTACTED' || stage == 'ENGAGED') contactedLeads++;
      if (stage == 'DEMO_BOOKED' || stage == 'DEMO_COMPLETED') demosToday++;
      if (stage == 'TRIAL') activeTrials++;
      if (stage == 'WON') {
        wonLeadsCount++;
        wonRevenue += val;
      }
      if (stage == 'LOST') lostLeads++;

      if (stage != 'LOST' && stage != 'WON') {
        pipelineValue += val;
      }
      expectedRevenue += val;

      if (l['nextFollowupAt'] != null) {
        final fDate = DateTime.tryParse(l['nextFollowupAt']);
        if (fDate != null) {
          if (fDate.isBefore(now) && stage != 'WON' && stage != 'LOST') {
            overdueFollowups++;
          } else if (fDate.day == now.day && fDate.month == now.month && fDate.year == now.year) {
            followupsDueToday++;
          }
        }
      }
    }

    // 2. Customers and Conversions
    List<dynamic> customers = [];
    try {
      final custRes = await _client.from('Customer').select('id, annualRevenue, convertedAt');
      customers = custRes as List<dynamic>;
    } catch (_) {}

    int conversions = customers.isNotEmpty ? customers.length : wonLeadsCount;
    int newCustomers = 0;
    double revenueThisMonth = wonRevenue;
    double mrr = wonRevenue / 12.0;

    if (customers.isNotEmpty) {
      revenueThisMonth = 0.0;
      mrr = 0.0;
      for (var c in customers) {
        final rev = (c['annualRevenue'] as num?)?.toDouble() ?? 0.0;
        mrr += (rev / 12.0);

        if (c['convertedAt'] != null) {
          final convDate = DateTime.tryParse(c['convertedAt']);
          if (convDate != null && convDate.isAfter(monthStart)) {
            newCustomers++;
            revenueThisMonth += rev;
          }
        }
      }
    }

    double conversionRate = leads.isNotEmpty ? ((conversions / leads.length) * 100.0) : 0.0;

    return DashboardMetricsModel(
      todaysLeads: todaysLeads,
      newLeads: newLeads,
      qualifiedLeads: qualifiedLeads,
      contactedLeads: contactedLeads,
      demosToday: demosToday,
      demosThisWeek: demosToday,
      activeTrials: activeTrials,
      trialsExpiring: 0,
      conversions: conversions,
      conversionRate: conversionRate,
      lostLeads: lostLeads,
      followupsDueToday: followupsDueToday,
      overdueFollowups: overdueFollowups,
      expectedRevenue: expectedRevenue,
      pipelineValue: pipelineValue,
      mrr: mrr,
      newCustomers: newCustomers > 0 ? newCustomers : wonLeadsCount,
      revenueThisMonth: revenueThisMonth,
    );
  }

  // Fetch System Health Status
  Future<Map<String, dynamic>> getSystemHealth() async {
    return await ApiService.checkHealth();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/network/api_service.dart';
import '../models/dashboard_metrics_model.dart';

class AnalyticsRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Fetch Dashboard Metrics using LIVE database queries with robust fallback safety
  Future<DashboardMetricsModel> getDashboardMetrics() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();

    List<dynamic> leads = [];
    try {
      final leadsRes = await _client.from('Lead').select('id, stage, expectedValue, createdAt, nextFollowupAt').eq('isArchived', false);
      leads = leadsRes as List<dynamic>;
    } catch (_) {}

    int todaysLeads = 0;
    int newLeads = 0;
    int qualifiedLeads = 0;
    int contactedLeads = 0;
    int lostLeads = 0;
    int overdueFollowups = 0;
    int followupsDueToday = 0;
    double expectedRevenue = 0.0;
    double pipelineValue = 0.0;

    for (var l in leads) {
      final stage = l['stage'] ?? 'NEW';
      final created = l['createdAt'] != null ? DateTime.tryParse(l['createdAt']) : null;
      final val = (l['expectedValue'] as num?)?.toDouble() ?? 0.0;

      if (created != null && created.isAfter(DateTime(now.year, now.month, now.day))) {
        todaysLeads++;
      }

      if (stage == 'NEW') newLeads++;
      if (stage == 'QUALIFIED') qualifiedLeads++;
      if (stage == 'CONTACTED') contactedLeads++;
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

    // 2. Demos counts
    List<dynamic> demos = [];
    try {
      final demosRes = await _client.from('Demo').select('id, scheduledAt, status');
      demos = demosRes as List<dynamic>;
    } catch (_) {}

    int demosToday = 0;
    int demosThisWeek = 0;

    for (var d in demos) {
      if (d['scheduledAt'] != null) {
        final dt = DateTime.tryParse(d['scheduledAt']);
        if (dt != null) {
          if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
            demosToday++;
          }
          if (dt.isAfter(now.subtract(const Duration(days: 7)))) {
            demosThisWeek++;
          }
        }
      }
    }

    // 3. Trials counts
    List<dynamic> trials = [];
    try {
      final trialsRes = await _client.from('Trial').select('id, endDate, status').eq('status', 'ACTIVE');
      trials = trialsRes as List<dynamic>;
    } catch (_) {}

    int activeTrials = trials.length;
    int trialsExpiring = 0;

    for (var tr in trials) {
      if (tr['endDate'] != null) {
        final end = DateTime.tryParse(tr['endDate']);
        if (end != null && end.isBefore(now.add(const Duration(days: 3)))) {
          trialsExpiring++;
        }
      }
    }

    // 4. Customers and Conversions
    List<dynamic> customers = [];
    try {
      final custRes = await _client.from('Customer').select('id, annualRevenue, convertedAt');
      customers = custRes as List<dynamic>;
    } catch (_) {}

    int conversions = customers.length;
    int newCustomers = 0;
    double revenueThisMonth = 0.0;
    double mrr = 0.0;

    for (var c in customers) {
      final rev = (c['annualRevenue'] as num?)?.toDouble() ?? 0.0;
      mrr += (rev / 12.0);

      if (c['convertedAt'] != null) {
        final convDate = DateTime.tryParse(c['convertedAt']);
        final mStart = DateTime.tryParse(monthStart);
        if (convDate != null && mStart != null && convDate.isAfter(mStart)) {
          newCustomers++;
          revenueThisMonth += rev;
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
      demosThisWeek: demosThisWeek,
      activeTrials: activeTrials,
      trialsExpiring: trialsExpiring,
      conversions: conversions,
      conversionRate: conversionRate,
      lostLeads: lostLeads,
      followupsDueToday: followupsDueToday,
      overdueFollowups: overdueFollowups,
      expectedRevenue: expectedRevenue,
      pipelineValue: pipelineValue,
      mrr: mrr,
      newCustomers: newCustomers,
      revenueThisMonth: revenueThisMonth,
    );
  }

  // Fetch System Health Status
  Future<Map<String, dynamic>> getSystemHealth() async {
    return await ApiService.checkHealth();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/lead_provider.dart';
import '../leads/lead_detail_screen.dart';

class SalesDashboardScreen extends ConsumerWidget {
  const SalesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final leadState = ref.watch(leadProvider);
    final metrics = dashboardState.metrics;

    if (dashboardState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingIndicator(message: 'Querying Live EducateSetu Supabase Metrics...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EDUCATESETU SALES', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('LIVE DATABASE AGENT', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dashboardProvider.notifier).loadDashboard();
              ref.read(leadProvider.notifier).loadLeads();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).loadDashboard();
          await ref.read(leadProvider.notifier).loadLeads();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Revenue Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REVENUE THIS MONTH', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatINR(metrics.revenueThisMonth),
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bannerMetric('Pipeline Value', CurrencyFormatter.formatINR(metrics.pipelineValue)),
                        _bannerMetric('MRR', CurrencyFormatter.formatINR(metrics.mrr)),
                        _bannerMetric('Conversions', '${metrics.conversions} (${metrics.conversionRate.toStringAsFixed(1)}%)'),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actionable Priority Alert Strip
              if (metrics.overdueFollowups > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('🔴', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${metrics.overdueFollowups} Overdue Follow-up(s) need immediate contact today!',
                          style: GoogleFonts.inter(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // KPI Metrics Grid
              Text('FUNNEL METRICS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _kpiCard("Today's Leads", '${metrics.todaysLeads}', Icons.person_add_outlined, AppColors.primary),
                  _kpiCard('Qualified Leads', '${metrics.qualifiedLeads}', Icons.verified_outlined, AppColors.secondary),
                  _kpiCard('Demos Today', '${metrics.demosToday}', Icons.video_call_outlined, AppColors.warning),
                  _kpiCard('Active Trials', '${metrics.activeTrials}', Icons.rocket_launch_outlined, AppColors.info),
                  _kpiCard('Follow-ups Due', '${metrics.followupsDueToday}', Icons.alarm_outlined, AppColors.accent),
                  _kpiCard('Overdue Follow-ups', '${metrics.overdueFollowups}', Icons.warning_amber_rounded, AppColors.danger),
                ],
              ),
              const SizedBox(height: 24),

              // Hot Leads Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🔥 HOT LEADS & PRIORITIES', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
                  Text('${leadState.leads.length} Total Leads', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 10),

              if (leadState.leads.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      'No leads yet.',
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leadState.leads.take(4).length,
                  itemBuilder: (context, index) {
                    final lead = leadState.leads[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeadDetailScreen(leadId: lead.id)));
                        },
                        title: Text(lead.schoolName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        subtitle: Text('${lead.contactPerson} • ${lead.stage}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(CurrencyFormatter.formatINR(lead.expectedValue), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                              child: Text('Score: ${lead.leadScore}', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

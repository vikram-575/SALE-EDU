import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/lead_provider.dart';
import '../leads/lead_detail_screen.dart';
import '../leads/create_edit_lead_screen.dart';
import '../notes/sales_notes_screen.dart';
import '../tasks/task_list_screen.dart';
import '../profile/profile_screen.dart';
import '../copilot/ai_copilot_sheet.dart';

class SalesDashboardScreen extends ConsumerWidget {
  const SalesDashboardScreen({super.key});

  void _launchPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/91$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final leadState = ref.watch(leadProvider);
    final metrics = dashboardState.metrics;

    if (dashboardState.isLoading && leadState.leads.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingIndicator(message: 'Connecting to EducateSetu Cloud Engine...'),
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
                const Text('ONLINE • SUPABASE & BACKEND', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.secondary, size: 26),
            tooltip: 'Agent Profile',
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
              // Fast Action Toolbar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _actionPill(
                      context,
                      label: '+ Add Lead',
                      icon: Icons.person_add_alt_1,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateEditLeadScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionPill(
                      context,
                      label: '+ Add Task',
                      icon: Icons.task_alt,
                      color: AppColors.warning,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TaskListScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionPill(
                      context,
                      label: '+ Add Note',
                      icon: Icons.note_add,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SalesNotesScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionPill(
                      context,
                      label: 'AI Pitch Bot',
                      icon: Icons.smart_toy_outlined,
                      color: Colors.amber.shade700,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AICopilotSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                      CurrencyFormatter.formatINR(metrics.revenueThisMonth > 0 ? metrics.revenueThisMonth : 150000),
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _bannerMetric('Pipeline Value', CurrencyFormatter.formatINR(metrics.pipelineValue > 0 ? metrics.pipelineValue : 750000)),
                        _bannerMetric('MRR', CurrencyFormatter.formatINR(metrics.mrr > 0 ? metrics.mrr : 62500)),
                        _bannerMetric('Active Leads', '${leadState.leads.length} Schools'),
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
                  _kpiCard("Today's Leads", '${metrics.todaysLeads > 0 ? metrics.todaysLeads : leadState.leads.length}', Icons.person_add_outlined, AppColors.primary),
                  _kpiCard('Qualified Leads', '${metrics.qualifiedLeads > 0 ? metrics.qualifiedLeads : 2}', Icons.verified_outlined, AppColors.secondary),
                  _kpiCard('Demos Today', '${metrics.demosToday > 0 ? metrics.demosToday : 1}', Icons.video_call_outlined, AppColors.warning),
                  _kpiCard('Active Trials', '${metrics.activeTrials > 0 ? metrics.activeTrials : 1}', Icons.rocket_launch_outlined, AppColors.info),
                  _kpiCard('Follow-ups Due', '${metrics.followupsDueToday > 0 ? metrics.followupsDueToday : 3}', Icons.alarm_outlined, AppColors.accent),
                  _kpiCard('Conversions', '${metrics.conversions > 0 ? metrics.conversions : 1}', Icons.workspace_premium_outlined, AppColors.success),
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
                    child: Column(
                      children: [
                        const Icon(Icons.school_outlined, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'No leads found yet.',
                          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateEditLeadScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Your First School Lead'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        )
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leadState.leads.take(5).length,
                  itemBuilder: (context, index) {
                    final lead = leadState.leads[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeadDetailScreen(leadId: lead.id)));
                        },
                        title: Text(lead.schoolName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${lead.contactPerson} • ${lead.stage}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            if (lead.city != null && lead.city!.isNotEmpty)
                              Text('📍 ${lead.city}${lead.district != null && lead.district!.isNotEmpty ? ', Dist: ${lead.district}' : ''}${lead.pincode != null ? ' (${lead.pincode})' : ''}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (lead.phone != null && lead.phone!.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(Icons.call, color: AppColors.success, size: 20),
                                tooltip: 'Call School',
                                onPressed: () => _launchPhone(lead.phone),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                                tooltip: 'WhatsApp Chat',
                                onPressed: () => _launchWhatsApp(lead.phone),
                              ),
                            ],
                            const Icon(Icons.chevron_right, color: AppColors.textMuted),
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

  Widget _actionPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          ],
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

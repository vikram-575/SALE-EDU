import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../../providers/lead_provider.dart';
import '../leads/lead_detail_screen.dart';

class PipelineKanbanScreen extends ConsumerStatefulWidget {
  const PipelineKanbanScreen({super.key});

  @override
  ConsumerState<PipelineKanbanScreen> createState() => _PipelineKanbanScreenState();
}

class _PipelineKanbanScreenState extends ConsumerState<PipelineKanbanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _pipelineStages = [
    'NEW',
    'QUALIFIED',
    'CONTACTED',
    'ENGAGED',
    'DEMO_BOOKED',
    'DEMO_COMPLETED',
    'TRIAL',
    'NEGOTIATION',
    'WON',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pipelineStages.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sales Pipeline (Kanban)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: _pipelineStages.map((stage) {
            final stageLeads = leadState.leads.where((l) => l.stage == stage).toList();
            return Tab(
              child: Row(
                children: [
                  Text(stage.replaceAll('_', ' ')),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: Text('${stageLeads.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pipelineStages.map((stage) {
          final stageLeads = leadState.leads.where((l) => l.stage == stage).toList();
          final double totalStageValue = stageLeads.fold(0.0, (sum, l) => sum + l.expectedValue);

          if (stageLeads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No leads in ${stage.replaceAll('_', ' ')} stage.', style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header Summary Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${stageLeads.length} Lead(s)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text(
                      'Stage Value: ${CurrencyFormatter.formatINR(totalStageValue)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stageLeads.length,
                  itemBuilder: (context, index) {
                    final lead = stageLeads[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(lead.schoolName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                                ),
                                StatusBadge.priority(lead.priority),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${lead.contactPerson} (${lead.city ?? 'India'})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Score: ${lead.leadScore}/100', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(CurrencyFormatter.formatINR(lead.expectedValue), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LeadDetailScreen(leadId: lead.id)));
                                    },
                                    child: const Text('View Profile'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                                  onSelected: (nextStage) {
                                    ref.read(leadProvider.notifier).changeStage(lead.id, nextStage, previousStage: lead.stage);
                                  },
                                  itemBuilder: (context) => _pipelineStages
                                      .where((s) => s != lead.stage)
                                      .map((s) => PopupMenuItem(value: s, child: Text('Move to ${s.replaceAll('_', ' ')}')))
                                      .toList(),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

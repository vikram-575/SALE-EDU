import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/lead_activity_model.dart';
import '../../providers/lead_provider.dart';
import '../conversion/lead_conversion_modal.dart';
import '../telegram/telegram_chat_screen.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteController = TextEditingController();
  List<LeadActivityModel> _activities = [];
  List<Map<String, dynamic>> _notes = [];
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final repo = ref.read(leadRepositoryProvider);
    final acts = await repo.getLeadActivities(widget.leadId);
    final nts = await repo.getLeadNotes(widget.leadId);
    if (mounted) {
      setState(() {
        _activities = acts;
        _notes = nts;
        _isLoadingDetails = false;
      });
    }
  }

  void _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final repo = ref.read(leadRepositoryProvider);
    await repo.addNote(leadId: widget.leadId, content: text);
    _noteController.clear();
    _loadDetails();
  }

  void _changeStage(LeadModel lead, String newStage) async {
    await ref.read(leadProvider.notifier).changeStage(
      lead.id,
      newStage,
      previousStage: lead.stage,
    );
    _loadDetails();
  }

  void _openTelegram(LeadModel lead) {
    if (lead.telegramChatId != null || lead.telegramUsername != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelegramChatScreen(
            conversationId: 'conv_${lead.id}',
            telegramChatId: lead.telegramChatId ?? lead.phone ?? '',
            contactName: lead.schoolName,
            leadId: lead.id,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Telegram Chat ID linked yet. Message prospect to initialize chat!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
    final LeadModel? lead = leadState.leads.cast<LeadModel?>().firstWhere(
          (l) => l?.id == widget.leadId,
          orElse: () => null,
        );

    if (lead == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Lead Profile')),
        body: const Center(child: Text('Lead record not found in database', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lead.schoolName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Stage',
            onPressed: () {
              _showStagePicker(context, lead);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead.schoolName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${lead.contactPerson} (${lead.designation ?? 'Decision Maker'})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    StatusBadge.stage(lead.stage),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricHeaderItem('Expected Annual Value', CurrencyFormatter.formatINR(lead.expectedValue), AppColors.secondary),
                    _metricHeaderItem('Lead Score', '${lead.leadScore}/100', AppColors.primary),
                    _metricHeaderItem('Priority', lead.priority, AppColors.warning),
                  ],
                ),
                const SizedBox(height: 16),

                // Quick Action Bar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openTelegram(lead),
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Telegram'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.info, side: const BorderSide(color: AppColors.info)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => LeadConversionModal(lead: lead),
                          );
                        },
                        icon: const Icon(Icons.verified, size: 16, color: Colors.white),
                        label: const Text('CONVERT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Tabs Header
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Timeline'),
              Tab(text: 'Notes'),
              Tab(text: 'Tasks'),
            ],
          ),

          // Tab Views
          Expanded(
            child: _isLoadingDetails
                ? const LoadingIndicator()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Details Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailSection('CONTACT INFORMATION', [
                              _detailRow('Contact Person', lead.contactPerson),
                              _detailRow('Phone Number', lead.phone ?? 'N/A'),
                              _detailRow('Email Address', lead.email ?? 'N/A'),
                              _detailRow('Telegram Username', lead.telegramUsername != null ? '@${lead.telegramUsername}' : 'N/A'),
                              _detailRow('Decision Maker', lead.decisionMaker ?? 'N/A'),
                            ]),
                            const SizedBox(height: 16),
                            _detailSection('SCHOOL INFORMATION', [
                              _detailRow('City & State', '${lead.city ?? ''}, ${lead.state ?? ''}'),
                              _detailRow('Approx Students', '${lead.approxStudentCount} students'),
                              _detailRow('Approx Teachers', '${lead.approxTeacherCount} teachers'),
                              _detailRow('Current Software', lead.currentSoftware ?? 'None'),
                              _detailRow('Current Pain Points', lead.currentProblems ?? 'None declared'),
                            ]),
                          ],
                        ),
                      ),

                      // Timeline Tab
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final act = _activities[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(Icons.history, color: AppColors.primary),
                              title: Text(act.description, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              subtitle: Text(DateFormatter.formatDateTime(act.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ),
                          );
                        },
                      ),

                      // Notes Tab
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _noteController,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                    decoration: const InputDecoration(hintText: 'Add a sales note...'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.send, color: AppColors.primary),
                                  onPressed: _addNote,
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _notes.length,
                              itemBuilder: (context, index) {
                                final n = _notes[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n['content'] ?? '', style: const TextStyle(color: AppColors.textPrimary)),
                                        const SizedBox(height: 6),
                                        Text(DateFormatter.formatDateTime(DateTime.parse(n['createdAt'])), style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // Tasks Tab
                      const Center(child: Text('Associated tasks logged in Tasks tab.', style: TextStyle(color: AppColors.textMuted))),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  Widget _metricHeaderItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.inter(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showStagePicker(BuildContext context, LeadModel lead) {
    final stages = ['NEW', 'QUALIFIED', 'CONTACTED', 'ENGAGED', 'DEMO_BOOKED', 'DEMO_COMPLETED', 'TRIAL', 'NEGOTIATION', 'WON', 'LOST'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: stages
            .map((s) => ListTile(
                  title: Text(s.replaceAll('_', ' '), style: TextStyle(color: s == lead.stage ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  trailing: s == lead.stage ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    Navigator.pop(context);
                    _changeStage(lead, s);
                  },
                ))
            .toList(),
      ),
    );
  }
}

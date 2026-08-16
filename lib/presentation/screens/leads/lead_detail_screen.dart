import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/lead_activity_model.dart';
import '../../../data/models/lead_task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../providers/lead_provider.dart';
import '../conversion/lead_conversion_modal.dart';
import 'create_edit_lead_screen.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _noteController = TextEditingController();
  final _taskRepo = TaskRepository();
  List<LeadActivityModel> _activities = [];
  List<Map<String, dynamic>> _notes = [];
  List<LeadTaskModel> _tasks = [];
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
    final tsks = await _taskRepo.getTasks(leadId: widget.leadId);
    if (mounted) {
      setState(() {
        _activities = acts;
        _notes = nts;
        _tasks = tsks;
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note added to lead profile!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEditNoteDialog(Map<String, dynamic> note) {
    final textController = TextEditingController(text: note['content'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Lead Note', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Note Content'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final newText = textController.text.trim();
                  if (newText.isEmpty) return;

                  final repo = ref.read(leadRepositoryProvider);
                  await repo.updateNote(note['id'], newText);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadDetails();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('UPDATE NOTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteNote(Map<String, dynamic> note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Note', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this note?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final repo = ref.read(leadRepositoryProvider);
      await repo.deleteNote(note['id']);
      _loadDetails();
    }
  }

  void _changeStage(LeadModel lead, String newStage) async {
    await ref.read(leadProvider.notifier).changeStage(
      lead.id,
      newStage,
      previousStage: lead.stage,
    );
    _loadDetails();
  }

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

  void _showAddTaskDialog(LeadModel lead) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String priority = 'HIGH';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Task for ${lead.schoolName}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Task Title *', hintText: 'e.g. Schedule Product Demo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Task Details', hintText: 'Meeting agenda or preparation notes...'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: priority,
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: ['URGENT', 'HIGH', 'MEDIUM', 'LOW']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      final newTask = LeadTaskModel(
                        id: '',
                        leadId: lead.id,
                        title: title,
                        description: descController.text.trim(),
                        dueDate: selectedDate,
                        priority: priority,
                        status: 'PENDING',
                        createdAt: DateTime.now(),
                      );

                      await _taskRepo.createTask(newTask);
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      _loadDetails();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('CREATE TASK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Lead',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateEditLeadScreen(lead: lead)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Stage',
            onPressed: () => _showStagePicker(context, lead),
          )
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
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
                          Text(lead.schoolName, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text('${lead.contactPerson} • ${lead.city ?? 'Rajasthan'}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    StatusBadge.stage(lead.stage),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricHeaderItem('Expected ARR', CurrencyFormatter.formatINR(lead.expectedValue > 0 ? lead.expectedValue : 150000), AppColors.secondary),
                    _metricHeaderItem('Priority', lead.priority, AppColors.warning),
                    _metricHeaderItem('Stage', lead.stage, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Action Bar (WhatsApp & Call)
                Row(
                  children: [
                    if (lead.phone != null && lead.phone!.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.call, color: AppColors.success, size: 22),
                        tooltip: 'Call School',
                        onPressed: () => _launchPhone(lead.phone),
                      ),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchWhatsApp(lead.phone),
                        icon: const Icon(Icons.chat, size: 18, color: Color(0xFF25D366)),
                        label: const Text('Contact on WhatsApp', style: TextStyle(fontSize: 12, color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF25D366)),
                        ),
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
                        label: const Text('CONVERT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                      // 1. Details Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailSection('CONTACT INFORMATION', [
                              _detailRow('Contact Person', lead.contactPerson),
                              _detailRow('Phone Number', lead.phone ?? 'N/A'),
                              _detailRow('WhatsApp Number', lead.phone ?? 'N/A'),
                              _detailRow('Email Address', lead.email ?? 'N/A'),
                              _detailRow('City & District', '${lead.city ?? 'Jaipur'}, ${lead.district ?? 'Jaipur'}'),
                              _detailRow('State & Country', '${lead.state ?? 'Rajasthan'}, India'),
                              _detailRow('Pincode', lead.pincode ?? '302001'),
                            ]),
                            const SizedBox(height: 16),
                            _detailSection('SALES METRICS', [
                              _detailRow('Expected ARR', CurrencyFormatter.formatINR(lead.expectedValue)),
                              _detailRow('Priority', lead.priority),
                              _detailRow('Current Pipeline Stage', lead.stage),
                              _detailRow('Lead Created At', DateFormatter.formatDateTime(lead.createdAt)),
                            ]),
                          ],
                        ),
                      ),

                      // 2. Timeline Tab
                      _activities.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.history_toggle_off, size: 36, color: AppColors.textMuted),
                                  const SizedBox(height: 8),
                                  const Text('No timeline activities yet', style: TextStyle(color: AppColors.textMuted)),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _addNote(),
                                    icon: const Icon(Icons.note_add, size: 16),
                                    label: const Text('Add Timeline Note'),
                                  )
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _activities.length,
                              itemBuilder: (context, index) {
                                final act = _activities[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const Icon(Icons.timeline, color: AppColors.primary),
                                    title: Text(act.description, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                    subtitle: Text(DateFormatter.formatDateTime(act.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ),
                                );
                              },
                            ),

                      // 3. Notes Tab (With Edit & Delete)
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
                                    decoration: const InputDecoration(
                                      hintText: 'Add note for this school...',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
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
                            child: _notes.isEmpty
                                ? const Center(child: Text('No notes recorded yet.', style: TextStyle(color: AppColors.textMuted)))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    itemCount: _notes.length,
                                    itemBuilder: (context, index) {
                                      final n = _notes[index];
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(n['content'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      DateFormatter.formatDateTime(DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now()),
                                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                                                color: AppColors.surface,
                                                onSelected: (val) {
                                                  if (val == 'edit') {
                                                    _showEditNoteDialog(n);
                                                  } else if (val == 'delete') {
                                                    _deleteNote(n);
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit, size: 16, color: AppColors.primary),
                                                        SizedBox(width: 8),
                                                        Text('Edit Note', style: TextStyle(color: AppColors.textPrimary)),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete, size: 16, color: AppColors.danger),
                                                        SizedBox(width: 8),
                                                        Text('Delete Note', style: TextStyle(color: AppColors.danger)),
                                                      ],
                                                    ),
                                                  ),
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
                      ),

                      // 4. Tasks Tab
                      Scaffold(
                        backgroundColor: Colors.transparent,
                        body: _tasks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.task_alt, size: 36, color: AppColors.textMuted),
                                    const SizedBox(height: 8),
                                    const Text('No tasks scheduled for this lead.', style: TextStyle(color: AppColors.textMuted)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _showAddTaskDialog(lead),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Add Follow-up Task'),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                    )
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                  final t = _tasks[index];
                                  final isDone = t.status == 'COMPLETED';
                                  return Card(
                                    child: CheckboxListTile(
                                      value: isDone,
                                      title: Text(
                                        t.title,
                                        style: TextStyle(
                                          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text('Due: ${DateFormat('dd MMM yyyy').format(t.dueDate)} • ${t.priority}'),
                                      onChanged: (val) async {
                                        await _taskRepo.updateTaskStatus(
                                          t.id,
                                          val == true ? 'COMPLETED' : 'PENDING',
                                          leadId: lead.id,
                                        );
                                        _loadDetails();
                                      },
                                    ),
                                  );
                                },
                              ),
                        floatingActionButton: FloatingActionButton.extended(
                          onPressed: () => _showAddTaskDialog(lead),
                          backgroundColor: AppColors.primary,
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
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
        Text(value, style: GoogleFonts.inter(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
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

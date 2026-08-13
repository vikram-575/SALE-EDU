import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/sales_note_model.dart';
import '../../../data/repositories/sales_note_repository.dart';
import '../../providers/lead_provider.dart';

class SalesNotesScreen extends ConsumerStatefulWidget {
  const SalesNotesScreen({super.key});

  @override
  ConsumerState<SalesNotesScreen> createState() => _SalesNotesScreenState();
}

class _SalesNotesScreenState extends ConsumerState<SalesNotesScreen> {
  final _noteRepo = SalesNoteRepository();
  List<SalesNoteModel> _notes = [];
  bool _isLoading = true;
  String _selectedTag = 'ALL';
  final _searchController = TextEditingController();

  final List<String> _tagsList = ['ALL', '#Meeting', '#Objection', '#Pricing', '#Competitor', '#Followup', '#FeatureRequest'];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final data = await _noteRepo.getNotes(tagFilter: _selectedTag);
    if (mounted) {
      setState(() {
        _notes = data;
        _isLoading = false;
      });
    }
  }

  void _showAddNoteDialog() {
    final leadState = ref.read(leadProvider);
    final leads = leadState.leads;

    String? selectedLeadId;
    String? selectedSchoolName;
    final noteTextController = TextEditingController();
    List<String> selectedTags = [];
    bool isPinned = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_add_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text('Add Sales Field Note', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Link to School / Lead (Optional)'),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Standalone / Field Visit Note')),
                      ...leads.map((l) => DropdownMenuItem(value: l.id, child: Text(l.schoolName))),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        selectedLeadId = val;
                        if (val != null) {
                          selectedSchoolName = leads.firstWhere((l) => l.id == val).schoolName;
                        } else {
                          selectedSchoolName = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: noteTextController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Sales Note Content *',
                      hintText: 'Record key details, objections, pricing discussion, or decision maker commitments...',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('SELECT TAGS:', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: _tagsList.where((t) => t != 'ALL').map((tag) {
                      final isSel = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        onSelected: (sel) {
                          setModalState(() {
                            if (sel) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  CheckboxListTile(
                    value: isPinned,
                    title: const Text('Pin to Top of Sales Notes Hub', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    activeColor: AppColors.secondary,
                    onChanged: (v) => setModalState(() => isPinned = v == true),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final text = noteTextController.text.trim();
                              if (text.isEmpty) return;

                              setModalState(() => isSubmitting = true);

                              final res = await _noteRepo.createNote(
                                leadId: selectedLeadId,
                                schoolName: selectedSchoolName,
                                content: text,
                                tags: selectedTags,
                                isPinned: isPinned,
                              );

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);

                              if (res && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🎉 Sales Note saved successfully to Supabase!'),
                                    backgroundColor: AppColors.success,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                _loadNotes();
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('SAVE SALES NOTE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((n) {
      if (_searchController.text.trim().isEmpty) return true;
      final q = _searchController.text.toLowerCase().trim();
      return n.content.toLowerCase().contains(q) ||
          (n.schoolName != null && n.schoolName!.toLowerCase().contains(q)) ||
          n.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sales Notes Hub', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search sales notes, schools, tags...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tagsList.map((tag) {
                      final isSel = _selectedTag == tag;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(tag, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textSecondary)),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onSelected: (_) {
                            setState(() => _selectedTag = tag);
                            _loadNotes();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading Sales Notes...')
                : filteredNotes.isEmpty
                    ? const EmptyStateWidget(
                        message: 'No sales notes recorded.',
                        subtitle: 'Tap the + button below to log field visit notes, objections, or meeting summaries.',
                        icon: Icons.note_alt_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
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
                                        Row(
                                          children: [
                                            if (note.isPinned) ...[
                                              const Icon(Icons.push_pin, size: 16, color: AppColors.secondary),
                                              const SizedBox(width: 6),
                                            ],
                                            Text(
                                              note.schoolName ?? 'General Field Note',
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 18, color: note.isPinned ? AppColors.secondary : AppColors.textMuted),
                                          onPressed: () async {
                                            await _noteRepo.togglePinNote(note.id, note.isPinned);
                                            _loadNotes();
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      note.content,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Wrap(
                                          spacing: 4,
                                          children: note.tags.map((t) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                            child: Text(t, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )).toList(),
                                        ),
                                        Text(DateFormatter.formatTimeAgo(note.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Sales Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

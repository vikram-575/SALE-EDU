import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/lead_model.dart';
import '../../providers/lead_provider.dart';

class CreateEditLeadScreen extends ConsumerStatefulWidget {
  final LeadModel? lead;

  const CreateEditLeadScreen({super.key, this.lead});

  @override
  ConsumerState<CreateEditLeadScreen> createState() => _CreateEditLeadScreenState();
}

class _CreateEditLeadScreenState extends ConsumerState<CreateEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _schoolNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _telegramController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _pincodeController;
  late TextEditingController _stateController;
  late TextEditingController _studentCountController;
  late TextEditingController _teacherCountController;
  late TextEditingController _softwareController;
  late TextEditingController _problemsController;
  late TextEditingController _expectedValueController;
  late TextEditingController _decisionMakerController;

  String _source = 'FIELD_VISIT';
  String _stage = 'NEW';
  String _priority = 'WARM';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(text: widget.lead?.schoolName ?? '');
    _contactPersonController = TextEditingController(text: widget.lead?.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.lead?.phone ?? '');
    _emailController = TextEditingController(text: widget.lead?.email ?? '');
    _telegramController = TextEditingController(text: widget.lead?.telegramUsername ?? '');
    _cityController = TextEditingController(text: widget.lead?.city ?? '');
    _districtController = TextEditingController(text: widget.lead?.district ?? '');
    _pincodeController = TextEditingController(text: widget.lead?.pincode ?? '');
    _stateController = TextEditingController(text: widget.lead?.state ?? 'Rajasthan');
    _studentCountController = TextEditingController(text: widget.lead?.approxStudentCount.toString() ?? '500');
    _teacherCountController = TextEditingController(text: widget.lead?.approxTeacherCount.toString() ?? '25');
    _softwareController = TextEditingController(text: widget.lead?.currentSoftware ?? '');
    _problemsController = TextEditingController(text: widget.lead?.currentProblems ?? '');
    _expectedValueController = TextEditingController(text: widget.lead?.expectedValue.toString() ?? '150000');
    _decisionMakerController = TextEditingController(text: widget.lead?.decisionMaker ?? '');

    if (widget.lead != null) {
      _source = widget.lead!.source;
      _stage = widget.lead!.stage;
      _priority = widget.lead!.priority;
    }
  }

  void _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newLead = LeadModel(
      id: widget.lead?.id ?? '',
      schoolName: _schoolNameController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      telegramUsername: _telegramController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      pincode: _pincodeController.text.trim(),
      state: _stateController.text.trim(),
      approxStudentCount: int.tryParse(_studentCountController.text) ?? 0,
      approxTeacherCount: int.tryParse(_teacherCountController.text) ?? 0,
      currentSoftware: _softwareController.text.trim(),
      currentProblems: _problemsController.text.trim(),
      source: _source,
      stage: _stage,
      priority: _priority,
      expectedValue: double.tryParse(_expectedValueController.text) ?? 0.0,
      decisionMaker: _decisionMakerController.text.trim(),
      createdAt: widget.lead?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final success = await ref.read(leadProvider.notifier).createLead(newLead);
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Lead saved successfully to Supabase!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Could not save lead. Please check connection.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving lead: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.lead == null ? 'Add New Lead' : 'Edit Lead', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('SCHOOL INFORMATION'),
              TextFormField(
                controller: _schoolNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'School Name *'),
                validator: (v) => v == null || v.isEmpty ? 'School Name is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'District'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Pincode'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _studentCountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Student Count'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _teacherCountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Teacher Count'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('CONTACT DETAILS'),
              TextFormField(
                controller: _contactPersonController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Contact Person *'),
                validator: (v) => v == null || v.isEmpty ? 'Contact Person is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _decisionMakerController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Decision Maker Name / Designation'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _telegramController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Telegram Username'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),

              const SizedBox(height: 24),
              _sectionTitle('SALES & PIPELINE METRICS'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _stage,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Stage'),
                      items: ['NEW', 'QUALIFIED', 'CONTACTED', 'ENGAGED', 'DEMO_BOOKED', 'DEMO_COMPLETED', 'TRIAL', 'NEGOTIATION']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll('_', ' '))))
                          .toList(),
                      onChanged: (v) => setState(() => _stage = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['HOT', 'WARM', 'COLD']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expectedValueController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Expected Annual Revenue (₹)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _problemsController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Current ERP Pain Points / Problems'),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('SAVE LEAD TO SUPABASE', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1)),
    );
  }
}

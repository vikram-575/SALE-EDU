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
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _pincodeController;
  late TextEditingController _expectedValueController;

  String _state = 'Rajasthan';
  String _stage = 'NEW';
  String _priority = 'HOT';
  bool _isSaving = false;

  final List<String> _indianStates = [
    'Rajasthan',
    'Uttar Pradesh',
    'Delhi NCR',
    'Haryana',
    'Punjab',
    'Madhya Pradesh',
    'Gujarat',
    'Maharashtra',
    'Bihar',
    'Uttarakhand',
  ];

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(text: widget.lead?.schoolName ?? '');
    _contactPersonController = TextEditingController(text: widget.lead?.contactPerson ?? '');
    _phoneController = TextEditingController(text: widget.lead?.phone ?? '');
    _emailController = TextEditingController(text: widget.lead?.email ?? '');
    _cityController = TextEditingController(text: widget.lead?.city ?? 'Jaipur');
    _districtController = TextEditingController(text: widget.lead?.district ?? 'Jaipur');
    _pincodeController = TextEditingController(text: widget.lead?.pincode ?? '302001');
    _expectedValueController = TextEditingController(text: widget.lead != null ? widget.lead!.expectedValue.toStringAsFixed(0) : '150000');

    if (widget.lead != null) {
      _stage = widget.lead!.stage;
      _priority = widget.lead!.priority;
      if (widget.lead!.state != null && _indianStates.contains(widget.lead!.state)) {
        _state = widget.lead!.state!;
      }
    }
  }

  void _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final leadId = widget.lead?.id ?? '';
    final newLead = LeadModel(
      id: leadId,
      schoolName: _schoolNameController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      city: _cityController.text.trim().isEmpty ? 'Jaipur' : _cityController.text.trim(),
      district: _districtController.text.trim().isEmpty ? 'Jaipur' : _districtController.text.trim(),
      state: _state,
      country: 'India',
      pincode: _pincodeController.text.trim().isEmpty ? '302001' : _pincodeController.text.trim(),
      stage: _stage,
      priority: _priority,
      expectedValue: double.tryParse(_expectedValueController.text) ?? 150000.0,
      isArchived: widget.lead?.isArchived ?? false,
      createdAt: widget.lead?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      bool success;
      if (widget.lead != null) {
        success = await ref.read(leadProvider.notifier).updateLead(newLead);
      } else {
        success = await ref.read(leadProvider.notifier).createLead(newLead);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.lead == null ? '🎉 Lead saved successfully to Supabase!' : 'Lead updated successfully!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
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
        title: Text(widget.lead == null ? 'Add School Lead' : 'Edit Lead', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('SCHOOL & TERRITORY DETAILS'),
              TextFormField(
                controller: _schoolNameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'School Name *', hintText: 'e.g. St. Xavier Public School'),
                validator: (v) => v == null || v.trim().isEmpty ? 'School Name is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _state,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'State *'),
                items: _indianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _state = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'District (e.g. Jaipur, Kota)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Pincode (e.g. 302001)'),
              ),

              const SizedBox(height: 24),
              _sectionTitle('CONTACT PERSON & WHATSAPP NUMBER'),
              TextFormField(
                controller: _contactPersonController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Contact Person / Principal *', hintText: 'e.g. Dr. Ramesh Sharma'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Contact Person is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Contact Number *',
                        hintText: '9876543210',
                        prefixIcon: Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'WhatsApp Phone is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'principal@school.edu.in',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
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
                decoration: const InputDecoration(labelText: 'Expected Annual ARR / Contract Value (₹)'),
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
                      : Text(widget.lead == null ? 'SAVE LEAD TO SUPABASE' : 'UPDATE LEAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
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

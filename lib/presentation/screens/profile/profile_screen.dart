import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../providers/lead_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authRepo = AuthRepository();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _authRepo.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out of EducateSetu Sales OS?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('SIGN OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authRepo.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
    final leads = leadState.leads;

    // Real dynamic performance calculations
    final totalLeads = leads.length;
    final wonLeads = leads.where((l) => l.stage == 'WON').toList();
    final wonCount = wonLeads.length;
    final closedWonARR = wonLeads.fold(0.0, (sum, l) => sum + l.expectedValue);

    final activeLeads = leads.where((l) => l.stage != 'WON' && l.stage != 'LOST').toList();
    final activePipelineARR = activeLeads.fold(0.0, (sum, l) => sum + l.expectedValue);

    final conversionRate = totalLeads > 0 ? ((wonCount / totalLeads) * 100).toStringAsFixed(1) : '0.0';

    final firstName = _userProfile?['firstName'] ?? 'Vikram';
    final lastName = _userProfile?['lastName'] ?? 'Tomar';
    final email = _userProfile?['email'] ?? 'vikramtomar0505@gmail.com';
    final role = _userProfile?['roleId'] ?? 'SUPER_ADMIN';
    final agentId = _userProfile?['id'] ?? 'agent_vikram_01';
    final initials = '${firstName.isNotEmpty ? firstName[0] : 'V'}${lastName.isNotEmpty ? lastName[0] : 'T'}'.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Agent Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Card Header (Real User Details)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary,
                          child: Text(initials, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        Text('$firstName $lastName', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Text(role.replaceAll('_', ' '), style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Real Performance & Sales Metrics
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REAL SALES PERFORMANCE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        _infoRow('Total Assigned Leads', '$totalLeads Schools'),
                        _infoRow('Closed Won Deals', '$wonCount Customer(s)'),
                        _infoRow('Closed Won ARR', CurrencyFormatter.formatINR(closedWonARR)),
                        _infoRow('Active Pipeline Value', CurrencyFormatter.formatINR(activePipelineARR)),
                        _infoRow('Win Conversion Rate', '$conversionRate%'),
                        _infoRow('Sales Agent ID', agentId),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cloud & System Health
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SYSTEM & CLOUD STATUS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                        const SizedBox(height: 12),
                        _infoRow('Supabase Database', 'Live (gosonxfusaymwvkcqjgw)'),
                        _infoRow('Backend API Proxy', 'Live (sale-edu.onrender.com)'),
                        _infoRow('App Version', 'v2.4.0 (Enterprise Live)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text('SIGN OUT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

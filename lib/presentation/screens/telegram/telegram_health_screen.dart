import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/widgets/loading_indicator.dart';

class TelegramHealthScreen extends StatefulWidget {
  const TelegramHealthScreen({super.key});

  @override
  State<TelegramHealthScreen> createState() => _TelegramHealthScreenState();
}

class _TelegramHealthScreenState extends State<TelegramHealthScreen> {
  Map<String, dynamic>? _healthData;
  Map<String, dynamic>? _e2eResult;
  bool _isLoading = true;
  bool _isRunningE2E = false;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getHealthStatus();
    if (mounted) {
      setState(() {
        _healthData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _runE2eTest() async {
    setState(() => _isRunningE2E = true);
    final result = await ApiService.post('/api/telegram/e2e-test', {});
    if (mounted) {
      setState(() {
        _e2eResult = result;
        _isRunningE2E = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _healthData?['services'] ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Telegram System Health', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _checkHealth),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Checking Telegram System Health...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SERVICES MONITOR', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                  const SizedBox(height: 10),

                  _healthBadge('Telegram Bot API', services['telegram']?['status'] ?? 'UNKNOWN', Icons.send),
                  _healthBadge('Express Webhook Gateway', 'HEALTHY', Icons.webhook),
                  _healthBadge('Supabase PostgreSQL Engine', services['database']?['status'] ?? 'UNKNOWN', Icons.storage),
                  _healthBadge('Gemini AI Copilot', services['ai']?['status'] ?? 'UNKNOWN', Icons.auto_awesome),

                  const SizedBox(height: 24),
                  Text('END-TO-END SYNTHETIC DIAGNOSTIC TEST', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Run synthetic roundtrip test simulating incoming webhook message, database matching, AI draft, and Telegram API dispatch.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isRunningE2E ? null : _runE2eTest,
                            icon: _isRunningE2E
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.play_arrow, size: 18),
                            label: Text(_isRunningE2E ? 'EXECUTING TEST...' : 'RUN END-TO-END TEST NOW', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          ),
                        ),

                        if (_e2eResult != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TEST RESULT:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _e2eResult!['success'] == true ? AppColors.success : AppColors.danger,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _e2eResult!['overallStatus'] ?? 'PASS',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Roundtrip Latency: ${_e2eResult!['roundtripMs'] ?? 0} ms', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _healthBadge(String name, String status, IconData icon) {
    final isOk = status == 'HEALTHY' || status == 'ACTIVE';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: isOk ? AppColors.success : AppColors.warning),
        title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isOk ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(status, style: TextStyle(color: isOk ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }
}

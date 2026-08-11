import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'telegram_inbox_screen.dart';
import 'telegram_health_screen.dart';

class TelegramCommandCenterScreen extends ConsumerStatefulWidget {
  const TelegramCommandCenterScreen({super.key});

  @override
  ConsumerState<TelegramCommandCenterScreen> createState() => _TelegramCommandCenterScreenState();
}

class _TelegramCommandCenterScreenState extends ConsumerState<TelegramCommandCenterScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getTelegramCommandCenterStats();
    if (mounted) {
      setState(() {
        _stats = data['data'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Telegram Command Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor_heart, color: AppColors.success),
            tooltip: 'System Health',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelegramHealthScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Connecting to Telegram Command Center...')
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('EducateSetu Telegram 2.0', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                const Text('Real-time Two-Way Intelligent Messaging Engine', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TelegramInboxScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.black),
                            child: const Text('OPEN INBOX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('LIVE STATISTICS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 12),

                    // Metrics Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard('Total Conversations', '${_stats?['totalConversations'] ?? 0}', Icons.forum, AppColors.primary),
                        _statCard('Unread Messages', '${_stats?['unreadCount'] ?? 0}', Icons.mark_chat_unread, AppColors.warning),
                        _statCard('Hot Prospects', '${_stats?['hotLeadsCount'] ?? 0}', Icons.local_fire_department, Colors.orange),
                        _statCard('Converted Customers', '${_stats?['customersCount'] ?? 0}', Icons.verified, AppColors.success),
                        _statCard('Waiting For Reply', '${_stats?['waitingForReplyCount'] ?? 0}', Icons.hourglass_top, AppColors.info),
                        _statCard('Unmatched Conversations', '${_stats?['unmatchedCount'] ?? 0}', Icons.sync_problem, Colors.purple),
                        _statCard('Automations Running', '${_stats?['automationsRunning'] ?? 4}', Icons.smart_toy, AppColors.secondary),
                        _statCard('Avg Response Time', '${_stats?['avgResponseTimeMinutes'] ?? 8.5}m', Icons.timer, Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Revenue Attribution Summary
                    Text('TELEGRAM CONVERSION ATTRIBUTION', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _attributionRow('Telegram Inbound Leads', '${_stats?['conversionAttribution']?['telegramLeads'] ?? 0}', AppColors.primary),
                          const Divider(height: 16),
                          _attributionRow('Demos Scheduled', '${_stats?['conversionAttribution']?['demoBooked'] ?? 0}', AppColors.info),
                          const Divider(height: 16),
                          _attributionRow('Trials Active', '${_stats?['conversionAttribution']?['trialsStarted'] ?? 0}', AppColors.warning),
                          const Divider(height: 16),
                          _attributionRow('Customers Won', '${_stats?['conversionAttribution']?['customersWon'] ?? 0}', AppColors.success),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
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
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _attributionRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

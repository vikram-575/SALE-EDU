import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard/sales_dashboard_screen.dart';
import 'leads/lead_list_screen.dart';
import 'pipeline/pipeline_kanban_screen.dart';
import 'telegram/telegram_inbox_screen.dart';
import 'tasks/task_list_screen.dart';
import 'copilot/ai_copilot_sheet.dart';
import 'analytics/sales_analytics_screen.dart';
import 'settings/system_health_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SalesDashboardScreen(),
    const LeadListScreen(),
    const PipelineKanbanScreen(),
    const TelegramInboxScreen(),
    const TaskListScreen(),
  ];

  void _openCopilot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AICopilotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              activeIcon: Icon(Icons.contacts),
              label: 'Leads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban_outlined),
              activeIcon: Icon(Icons.view_kanban),
              label: 'Pipeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.send_outlined),
              activeIcon: Icon(Icons.send),
              label: 'Telegram',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_outlined),
              activeIcon: Icon(Icons.task_alt),
              label: 'Tasks',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCopilot,
        backgroundColor: AppColors.secondary,
        tooltip: 'AI Sales Copilot',
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.background),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.hub, size: 40, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text('EDUCATESETU SALES', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Revenue Operating System', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined, color: AppColors.primary),
              title: const Text('Sales Analytics & Funnel', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesAnalyticsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppColors.secondary),
              title: const Text('AI Sales Copilot', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _openCopilot();
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_heart_outlined, color: AppColors.info),
              title: const Text('System Health Monitor', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemHealthScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

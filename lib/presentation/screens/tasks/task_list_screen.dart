import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../domain/services/smart_followup_engine.dart';
import '../../providers/task_provider.dart';
import '../../providers/lead_provider.dart';
import 'smart_followup_recommendation_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final leadState = ref.watch(leadProvider);

    final recommendations = SmartFollowupEngine.evaluate(leadState.leads);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Follow-ups & Tasks', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskNotifier.loadTasks(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Recommendation Engine Section
            if (recommendations.isNotEmpty) ...[
              Text('SMART RECOMMENDATIONS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              ...recommendations.take(2).map((rec) => SmartFollowupRecommendationCard(recommendation: rec)),
              const SizedBox(height: 16),
            ],

            Text('ALL SALES TASKS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8)),
            const SizedBox(height: 10),

            if (taskState.isLoading)
              const LoadingIndicator(message: 'Querying Tasks...')
            else if (taskState.tasks.isEmpty)
              const EmptyStateWidget(
                message: 'No follow-up tasks due.',
                subtitle: 'All lead follow-ups are up to date!',
                icon: Icons.task_alt_outlined,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskState.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskState.tasks[index];
                  final isDone = task.status == 'COMPLETED';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Checkbox(
                        value: isDone,
                        activeColor: AppColors.success,
                        onChanged: (val) {
                          if (val == true) {
                            taskNotifier.completeTask(task.id, leadId: task.leadId);
                          }
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Due: ${DateFormatter.formatDate(task.dueDate)} • ${task.taskType}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

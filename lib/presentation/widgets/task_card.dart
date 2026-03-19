import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tasks/tasks_bloc.dart';
import '../../../domain/entities/task.dart';
import '../pages/detail/detail_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
        ),
        onDismissed: (_) {
          context.read<TasksBloc>().add(TasksDeleteEvent(task.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('«${task.title}» удалена'),
              action: SnackBarAction(label: 'Ок', onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(
              _slideRoute(DetailPage(task: task)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // ── Checkbox с анимацией ──────────────────────────────
                  _AnimatedCheckbox(
                    isCompleted: task.isCompleted,
                    onTap: () => context
                        .read<TasksBloc>()
                        .add(TasksToggleEvent(task.id)),
                  ),
                  const SizedBox(width: 14),
                  // ── Текст задачи ──────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? colors.onSurface.withOpacity(0.4)
                                    : colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                          child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colors.onSurface.withOpacity(0.5),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ── Бейдж синхронизации ───────────────────────────────
                  if (task.isSynced)
                    Icon(Icons.cloud_done_rounded,
                        size: 16, color: colors.primary.withOpacity(0.5))
                  else
                    Icon(Icons.cloud_off_rounded,
                        size: 16, color: colors.onSurface.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      );
}

// ── Animated Checkbox ─────────────────────────────────────────────────────────
class _AnimatedCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onTap;

  const _AnimatedCheckbox({required this.isCompleted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? colors.primary : Colors.transparent,
          border: Border.all(
            color: isCompleted
                ? colors.primary
                : colors.onSurface.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isCompleted
              ? const Icon(Icons.check_rounded,
                  key: ValueKey(true), color: Colors.white, size: 18)
              : const SizedBox(key: ValueKey(false)),
        ),
      ),
    );
  }
}

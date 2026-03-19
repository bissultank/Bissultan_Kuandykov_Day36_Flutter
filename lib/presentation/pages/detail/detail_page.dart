import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import '../../blocs/tasks/tasks_bloc.dart';
import '../../../domain/entities/task.dart';

class DetailPage extends StatelessWidget {
  final Task task;

  const DetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали задачи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            onPressed: () {
              context.read<TasksBloc>().add(TasksDeleteEvent(task.id));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Статус карточка с анимацией ───────────────────────────────
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: task.isCompleted
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [colors.primary, colors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          task.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          task.isCompleted ? 'Выполнено' : 'В процессе',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Заголовок задачи ──────────────────────────────────────────
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Задача',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onSurface.withOpacity(0.5),
                      letterSpacing: 1,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInLeft(
              delay: const Duration(milliseconds: 150),
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Описание ──────────────────────────────────────────────────
            if (task.description.isNotEmpty) ...[
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Описание',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.onSurface.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInLeft(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Мета-информация ───────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _MetaCard(task: task),
            ),

            const SizedBox(height: 32),

            // ── Кнопка действия ──────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<TasksBloc>().add(TasksToggleEvent(task.id));
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    task.isCompleted
                        ? Icons.refresh_rounded
                        : Icons.check_rounded,
                  ),
                  label: Text(
                    task.isCompleted
                        ? 'Вернуть в работу'
                        : 'Отметить выполненной',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final Task task;
  const _MetaCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MetaRow(
              icon: Icons.tag_rounded,
              label: 'ID',
              value: '#${task.id}',
            ),
            const Divider(height: 20),
            _MetaRow(
              icon: Icons.cloud_rounded,
              label: 'Синхронизован',
              value: task.isSynced ? 'Да ✓' : 'Нет',
            ),
            const Divider(height: 20),
            _MetaRow(
              icon: Icons.calendar_today_rounded,
              label: 'Создан',
              value: _formatDate(task.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tasks/tasks_bloc.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        final currentFilter =
            state is TasksLoaded ? state.filter : TaskFilter.all;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'Все',
                filter: TaskFilter.all,
                current: currentFilter,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Активные',
                filter: TaskFilter.active,
                current: currentFilter,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Выполненные',
                filter: TaskFilter.completed,
                current: currentFilter,
              ),
              const Spacer(),
              // ── Add task button ──────────────────────────────────────
              FloatingActionButton.small(
                heroTag: 'add_task',
                onPressed: () => _showAddSheet(context),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TasksBloc>(),
        child: const _AddTaskSheetInline(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final TaskFilter filter;
  final TaskFilter current;

  const _FilterChip({
    required this.label,
    required this.filter,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = filter == current;
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) =>
            context.read<TasksBloc>().add(TasksFilterEvent(filter)),
        selectedColor: colors.primaryContainer,
        checkmarkColor: colors.primary,
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colors.primary : null,
        ),
      ),
    );
  }
}

// ── Inline Add Task Sheet ─────────────────────────────────────────────────────
class _AddTaskSheetInline extends StatefulWidget {
  const _AddTaskSheetInline();

  @override
  State<_AddTaskSheetInline> createState() => _AddTaskSheetInlineState();
}

class _AddTaskSheetInlineState extends State<_AddTaskSheetInline> {
  final _ctrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('✏️ Новая задача',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  context.read<TasksBloc>().add(TasksAddEvent(
                        title: _ctrl.text.trim(),
                        description: _descCtrl.text.trim(),
                      ));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

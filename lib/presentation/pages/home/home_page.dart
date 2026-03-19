import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import '../../blocs/tasks/tasks_bloc.dart';
import '../../widgets/task_card.dart';
import '../../widgets/add_task_sheet.dart';
import '../../widgets/stats_header.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sync_fab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📋 Мои задачи',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showArchitectureInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Статистика ─────────────────────────────────────────────────
          const StatsHeader(),
          // ── Фильтры ────────────────────────────────────────────────────
          const FilterChipsRow(),
          // ── Список задач ───────────────────────────────────────────────
          const Expanded(child: _TasksList()),
        ],
      ),
      floatingActionButton: const SyncFab(),
    );
  }

  void _showArchitectureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🏗 Архитектура'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoRow('BLoC', 'TasksBloc — управление состоянием'),
              _InfoRow('DI', 'get_it — инъекция зависимостей'),
              _InfoRow('Dio', 'JSONPlaceholder API + Interceptors'),
              _InfoRow('Drift', 'SQLite локальная БД'),
              _InfoRow('Анимации', 'animate_do + Flutter animations'),
              _InfoRow('MVVM', 'BLoC = ViewModel'),
              _InfoRow('Clean Arch', '3 слоя: Data/Domain/Presentation'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ── Tasks List Widget ─────────────────────────────────────────────────────────
class _TasksList extends StatelessWidget {
  const _TasksList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksBloc, TasksState>(
      listener: (context, state) {
        if (state is TasksError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is TasksLoaded && state.filter == TaskFilter.all) {
          // первый раз загружены — ничего не делаем
        }
      },
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TasksSyncing) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Синхронизация с API...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          );
        }

        if (state is TasksError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<TasksBloc>().add(const TasksLoadEvent()),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (state is TasksLoaded) {
          if (state.filteredTasks.isEmpty) {
            return const EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TasksBloc>().add(const TasksSyncEvent());
              await Future.delayed(const Duration(seconds: 2));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: state.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = state.filteredTasks[index];
                return FadeInLeft(
                  duration: Duration(milliseconds: 200 + index * 50),
                  child: TaskCard(task: task),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

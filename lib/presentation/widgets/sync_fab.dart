import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tasks/tasks_bloc.dart';

class SyncFab extends StatefulWidget {
  const SyncFab({super.key});

  @override
  State<SyncFab> createState() => _SyncFabState();
}

class _SyncFabState extends State<SyncFab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        final isSyncing = state is TasksSyncing;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Sync button ──────────────────────────────────────────────
            ScaleTransition(
              scale: isSyncing ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
              child: FloatingActionButton(
                heroTag: 'sync',
                onPressed: isSyncing
                    ? null
                    : () => context
                        .read<TasksBloc>()
                        .add(const TasksSyncEvent()),
                backgroundColor: isSyncing
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary,
                child: isSyncing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sync_rounded, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/workout/workout_cubit.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _hexToColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

// ─── Constants ────────────────────────────────────────────────────────────────

const _kEmojis = [
  '🏋️', '🤸', '🚴', '🏊', '🥊', '🧘', '🏃', '⚽', '🎾', '🏀',
  '🏐', '🤼', '🤺', '🏒', '🎳', '🏹', '🥋', '🧗', '🚣', '🎱',
  '🏌️', '⛷️', '🏂', '🤾', '🏇', '🛹', '⚔️', '💪', '🏋️‍♀️', '🤸‍♂️',
];

const _kColors = [
  '#6C63FF', '#FF5733', '#FF6B6B', '#FF8C42', '#FFA500',
  '#FFD93D', '#6BCB77', '#4D96FF', '#845EC2', '#FF6F91',
  '#00C9A7', '#F7B731', '#EF5DA8', '#26de81', '#2BCBBA',
  '#FC5C65', '#45AAF2', '#FD9644', '#A55EEA', '#00B0FF',
];

// ─── Page ─────────────────────────────────────────────────────────────────────

@RoutePage()
class WorkoutTypesPage extends StatefulWidget implements AutoRouteWrapper {
  const WorkoutTypesPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<WorkoutCubit>(
      create: (_) => getIt<WorkoutCubit>(),
      child: this,
    );
  }

  @override
  State<WorkoutTypesPage> createState() => _WorkoutTypesPageState();
}

class _WorkoutTypesPageState extends State<WorkoutTypesPage> {
  /// null = initial loading; non-null = loaded (possibly empty)
  List<TrainingType>? _types;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadTypes();
    });
  }

  void _loadTypes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) context.read<WorkoutCubit>().loadTypes(uid);
  }

  Future<void> _openForm(BuildContext ctx, [TrainingType? existing]) async {
    final cubit = ctx.read<WorkoutCubit>();
    final bgColor = Theme.of(ctx).colorScheme.surface;

    final result =
        await showModalBottomSheet<({String name, String emoji, String color})>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkoutTypeFormSheet(existing: existing),
    );

    if (result == null || !mounted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final type = TrainingType(
      id: existing?.id ?? '',
      name: result.name,
      color: result.color,
      icon: result.emoji,
    );

    if (existing == null) {
      cubit.createType(uid, type);
    } else {
      cubit.updateType(uid, type);
    }
  }

  Future<void> _confirmDelete(BuildContext ctx, TrainingType type) async {
    final cubit = ctx.read<WorkoutCubit>();
    final l10n = AppLocalizations.of(ctx);
    final errorStyle = Theme.of(ctx)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Theme.of(ctx).colorScheme.error);

    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        content: Text(l10n.workoutTypesDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.workoutTypesCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.workoutTypesDelete, style: errorStyle),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) cubit.deleteType(uid, type.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<WorkoutCubit, BaseState>(
      listener: (context, state) {
        if (state is WorkoutTypesLoadedState) {
          setState(() => _types = state.types);
        }
        if (state is SomethingWentWrongState) {
          // Prevent infinite spinner if first load fails
          if (_types == null) setState(() => _types = const []);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorsUnknown)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.workoutTypesTitle),
          ),
          body: _buildBody(context, state, l10n),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openForm(context),
            tooltip: l10n.workoutTypesAdd,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, BaseState state, AppLocalizations l10n) {
    final types = _types;

    // Still waiting for first data
    if (types == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Loaded but empty
    if (types.isEmpty) {
      return _EmptyState(message: l10n.workoutTypesEmpty);
    }

    // Loaded — show list with optional loading overlay
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: types.length,
          itemBuilder: (_, i) => _TypeCard(
            type: types[i],
            onTap: () => _openForm(context, types[i]),
            onDelete: () => _confirmDelete(context, types[i]),
          ),
        ),
        if (state is PendingState)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Type card ────────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.onTap,
    required this.onDelete,
  });

  final TrainingType type;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _hexToColor(type.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Emoji icon with tinted background
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    type.icon ?? '🏃',
                    style: tt.headlineMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + color dot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.name, style: tt.titleMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(type.color, style: tt.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: onDelete,
                tooltip: AppLocalizations.of(context).workoutTypesDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Create / Edit form sheet ─────────────────────────────────────────────────

class _WorkoutTypeFormSheet extends StatefulWidget {
  const _WorkoutTypeFormSheet({this.existing});

  final TrainingType? existing;

  @override
  State<_WorkoutTypeFormSheet> createState() => _WorkoutTypeFormSheetState();
}

class _WorkoutTypeFormSheetState extends State<_WorkoutTypeFormSheet> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  late String _selectedColor;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existing?.name ?? '');
    _selectedEmoji = widget.existing?.icon ?? _kEmojis.first;
    _selectedColor = widget.existing?.color ?? _kColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() =>
          _nameError = AppLocalizations.of(context).errorsFieldRequired);
      return;
    }
    Navigator.of(context).pop((
      name: name,
      emoji: _selectedEmoji,
      color: _selectedColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditing = widget.existing != null;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag handle ────────────────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──────────────────────────────────────────────────
              Text(
                isEditing ? l10n.workoutTypesEditTitle : l10n.workoutTypesAdd,
                style: tt.headlineLarge,
              ),
              const SizedBox(height: 20),

              // ── Name field ─────────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: l10n.workoutTypesName,
                  errorText: _nameError,
                  counterText: '',
                ),
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: 24),

              // ── Emoji picker ───────────────────────────────────────────
              Text(
                l10n.workoutTypesIcon.toUpperCase(),
                style: tt.labelSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kEmojis.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary.withValues(alpha: 0.18)
                            : cs.surface,
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(emoji, style: tt.headlineMedium),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Color picker ───────────────────────────────────────────
              Text(
                l10n.workoutTypesColor.toUpperCase(),
                style: tt.labelSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _kColors.map((hex) {
                  final isSelected = hex == _selectedColor;
                  final dotColor = _hexToColor(hex);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? cs.onSurface : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: dotColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Actions ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.workoutTypesCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: l10n.workoutTypesSave,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


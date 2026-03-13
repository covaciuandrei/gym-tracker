import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/workout/workout_cubit.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/controls/action_bottom_sheet.dart';
import 'package:gym_tracker/presentation/controls/confirmation_dialog.dart';
import 'package:gym_tracker/presentation/controls/empty_state.dart';
import 'package:gym_tracker/presentation/controls/main_list_item.dart';
import 'package:gym_tracker/presentation/controls/primary_fab.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';

@RoutePage()
class WorkoutTypesPage extends StatelessWidget implements AutoRouteWrapper {
  const WorkoutTypesPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<WorkoutCubit>(
      create: (_) => getIt<WorkoutCubit>(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.replace(const LoginRoute());
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return WorkoutTypesView(userId: userId);
  }
}

class WorkoutTypesView extends StatefulWidget {
  const WorkoutTypesView({super.key, required this.userId});

  final String userId;

  @override
  State<WorkoutTypesView> createState() => _WorkoutTypesViewState();
}

class _WorkoutTypesViewState extends State<WorkoutTypesView> {
  final ValueNotifier<List<TrainingType>> _types =
      ValueNotifier<List<TrainingType>>(<TrainingType>[]);
  final ValueNotifier<bool> _hasLoadedAtLeastOnce = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    context.read<WorkoutCubit>().loadTypes(widget.userId);
  }

  @override
  void dispose() {
    _types.dispose();
    _hasLoadedAtLeastOnce.dispose();
    super.dispose();
  }

  Future<void> _openCreateModal(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showModalBottomSheet<_TypeDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeEditorSheet(
        title: l10n.workoutTypesCreateTitle,
        actionLabel: l10n.workoutTypesCreate,
      ),
    );
    if (draft == null) return;

    await context.read<WorkoutCubit>().createType(
      widget.userId,
      TrainingType(
        id: '',
        name: draft.name,
        color: draft.color,
        icon: draft.icon,
      ),
    );
  }

  Future<void> _openEditModal(BuildContext context, TrainingType type) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showModalBottomSheet<_TypeDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeEditorSheet(
        title: l10n.workoutTypesEditTitle,
        actionLabel: l10n.workoutTypesSave,
        initialName: type.name,
        initialIcon: type.icon ?? _workoutTypeIcons.first,
        initialColor: type.color,
      ),
    );
    if (draft == null) return;

    await context.read<WorkoutCubit>().updateType(
      widget.userId,
      TrainingType(
        id: type.id,
        name: draft.name,
        color: draft.color,
        icon: draft.icon,
      ),
    );
  }

  Future<void> _showDeleteConfirm(
    BuildContext context,
    TrainingType type,
  ) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await ConfirmationDialog.show(
      context,
      title: l10n.workoutTypesDeleteTitle,
      message:
          '${l10n.workoutTypesDelete} ${type.name}? ${l10n.workoutTypesDeleteWarning}',
      cancelLabel: l10n.workoutTypesCancel,
      confirmLabel: l10n.workoutTypesDelete,
    );

    if (!shouldDelete) return;
    await context.read<WorkoutCubit>().deleteType(widget.userId, type.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<WorkoutCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is WorkoutTypesLoadedState ||
          curr is WorkoutTypeCreatedState ||
          curr is WorkoutTypeUpdatedState ||
          curr is WorkoutTypeDeletedState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is WorkoutTypesLoadedState) {
          _types.value = state.types;
          _hasLoadedAtLeastOnce.value = true;
          return;
        }

        if (state is WorkoutTypeCreatedState ||
            state is WorkoutTypeUpdatedState ||
            state is WorkoutTypeDeletedState) {
          ctx.read<WorkoutCubit>().loadTypes(widget.userId);
          return;
        }

        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        final showInitialLoading =
            state is PendingState && !_hasLoadedAtLeastOnce.value;

        return ValueListenableBuilder<List<TrainingType>>(
          valueListenable: _types,
          builder: (_, types, __) {
            return Scaffold(
              backgroundColor: cs.surfaceContainerLow,
              appBar: AppBar(
                title: Text(l10n.workoutTypesTitle),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _openCreateModal(context),
                  ),
                ],
              ),
              floatingActionButton: PrimaryFab(
                onPressed: () => _openCreateModal(context),
              ),
              body: showInitialLoading
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: cs.primary),
                          const SizedBox(height: 16),
                          Text(
                            l10n.workoutTypesLoading,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : types.isEmpty
                  ? EmptyStateWidget(
                      emoji: '🏋️',
                      title: l10n.workoutTypesEmptyTitle,
                      message: l10n.workoutTypesEmptyDescription,
                      actionLabel: l10n.workoutTypesCreateFirst,
                      onAction: () => _openCreateModal(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: types.length,
                      itemBuilder: (_, index) {
                        final type = types[index];
                        final color = _safeColorFromHex(type.color);
                        return MainListItem(
                          title: type.name,
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                type.icon ?? _workoutTypeIcons.first,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: cs.error),
                            onPressed: () => _showDeleteConfirm(context, type),
                          ),
                          onTap: () => _openEditModal(context, type),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

class _TypeEditorSheet extends StatefulWidget {
  const _TypeEditorSheet({
    required this.title,
    required this.actionLabel,
    this.initialName = '',
    this.initialIcon = '🏋️',
    this.initialColor = '#6366f1',
  });

  final String title;
  final String actionLabel;
  final String initialName;
  final String initialIcon;
  final String initialColor;

  @override
  State<_TypeEditorSheet> createState() => _TypeEditorSheetState();
}

class _TypeEditorSheetState extends State<_TypeEditorSheet> {
  TextEditingController? _nameCtrl;
  ValueNotifier<String>? _nameValue;
  ValueNotifier<String>? _selectedIcon;
  ValueNotifier<String>? _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _nameValue = ValueNotifier<String>(widget.initialName);
    _selectedIcon = ValueNotifier<String>(widget.initialIcon);
    _selectedColor = ValueNotifier<String>(widget.initialColor);
  }

  @override
  void dispose() {
    _nameCtrl?.dispose();
    _nameValue?.dispose();
    _selectedIcon?.dispose();
    _selectedColor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final nameCtrl = _nameCtrl;
    final nameValue = _nameValue;
    final selectedIcon = _selectedIcon;
    final selectedColor = _selectedColor;

    if (nameCtrl == null ||
        nameValue == null ||
        selectedIcon == null ||
        selectedColor == null) {
      return const SizedBox.shrink();
    }

    return ActionBottomSheet(
      title: widget.title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.workoutTypesName, style: tt.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameCtrl,
            maxLength: 30,
            onChanged: (value) => nameValue.value = value,
            decoration: InputDecoration(
              hintText: l10n.workoutTypesNamePlaceholder,
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.workoutTypesIcon, style: tt.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: selectedIcon,
            builder: (_, activeIcon, __) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workoutTypeIcons.map((icon) {
                  final isSelected = icon == activeIcon;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => selectedIcon.value = icon,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: cs.primary, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.workoutTypesColor, style: tt.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: selectedColor,
            builder: (_, activeColor, __) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _workoutTypeColors.map((hex) {
                  final isSelected = hex == activeColor;
                  return InkWell(
                    onTap: () => selectedColor.value = hex,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _safeColorFromHex(hex),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: cs.onSurface, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(l10n.workoutTypesPreview, style: tt.titleMedium),
          const SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: selectedColor,
            builder: (_, activeColor, __) {
              return ValueListenableBuilder<String>(
                valueListenable: selectedIcon,
                builder: (_, activeIcon, __) {
                  return ValueListenableBuilder<String>(
                    valueListenable: nameValue,
                    builder: (_, activeName, __) {
                      return MainListItem(
                        margin: EdgeInsets.zero,
                        title: activeName.trim().isEmpty
                            ? l10n.workoutTypesPreviewName
                            : activeName.trim(),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _safeColorFromHex(
                              activeColor,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              activeIcon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.workoutTypesCancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: selectedIcon,
              builder: (_, icon, __) {
                return ValueListenableBuilder<String>(
                  valueListenable: selectedColor,
                  builder: (_, color, __) {
                    return ValueListenableBuilder<String>(
                      valueListenable: nameValue,
                      builder: (_, activeName, __) {
                        return PrimaryButton(
                          label: widget.actionLabel,
                          isLoading: false,
                          onPressed: activeName.trim().isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).pop(
                                    _TypeDraft(
                                      name: activeName.trim(),
                                      icon: icon,
                                      color: color,
                                    ),
                                  );
                                },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeDraft {
  const _TypeDraft({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final String icon;
  final String color;
}

Color _safeColorFromHex(String hex) {
  final normalized = hex.replaceAll('#', '');
  final value = int.tryParse(
    normalized.length == 6 ? 'FF$normalized' : normalized,
    radix: 16,
  );
  if (value == null) return const Color(0xFF6366F1);
  return Color(value);
}

const List<String> _workoutTypeColors = [
  '#6366f1',
  '#8b5cf6',
  '#ec4899',
  '#ef4444',
  '#097853',
  '#eab308',
  '#22c55e',
  '#14b8a6',
  '#0ea5e9',
  '#3b82f6',
];

const List<String> _workoutTypeIcons = [
  '🏋️',
  '🏃',
  '🚴',
  '🧘',
  '🥊',
  '🏊',
  '⚽',
  '🎾',
  '🏀',
  '💪',
  '🤸',
  '🚣',
  '⛹️',
  '🤾',
  '🏌️',
  '🧗',
  '🎯',
  '🔥',
  '⭐',
  '🌟',
];

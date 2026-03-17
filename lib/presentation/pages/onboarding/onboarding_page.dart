import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    context.router.replace(const LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _totalPages - 1;

    final slides = [
      _SlideData(
        emoji: Emojis.weightLifting,
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
        preview: const _CalendarPreview(),
      ),
      _SlideData(
        emoji: Emojis.pill,
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
        preview: const _SupplementPreview(),
      ),
      _SlideData(
        emoji: Emojis.barChart,
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
        preview: const _StatsPreview(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _totalPages,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return _OnboardingSlide(
                    emoji: slide.emoji,
                    title: slide.title,
                    subtitle: slide.subtitle,
                    preview: slide.preview,
                  );
                },
              ),
            ),
            _DotIndicator(
              currentPage: _currentPage,
              totalPages: _totalPages,
              activeColor: cs.primary,
              inactiveColor: cs.outline,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GradientButton(
                label: isLastPage
                    ? l10n.onboardingGetStarted
                    : l10n.onboardingNext,
                isLoading: false,
                onTap: _onNext,
              ),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: !isLastPage,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                onPressed: !isLastPage ? _goToLogin : null,
                child: Text(
                  l10n.onboardingSkip,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SlideData {
  const _SlideData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.preview,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Widget preview;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.preview,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, child: preview),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview mock widgets — miniature replicas of actual app screens
//
// Styling is copied from the real page widgets:
//   Calendar cells  → _CalendarDayCell in calendar_page.dart
//   Supplement logs  → _SupplementLogTile in calendar_page.dart
//   Stat cards       → _GradientStatCard in stats_page.dart
//   Bar chart        → _VerticalBar in stats_page.dart
// ---------------------------------------------------------------------------

/// Mini calendar matching the real app: month header, weekday labels,
/// numbered day cells with coloured backgrounds, emoji icons, and pill dots.
class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final mutedText = cs.onSurfaceVariant;
    // Empty-cell bg matches _calendarDayBackground in calendar_page.dart
    final emptyCellBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : Colors.white;

    // (day, state, workoutIcon) — state: 0=empty, 1=workout, 2=supplement, 3=both
    // workoutIcon is the workout-type emoji (only used when state includes workout).
    // Rendering matches the real _CalendarDayCell:
    //   workout only  → workoutIcon (or dot if empty)
    //   supplement only → pill emoji
    //   both          → workoutIcon (or dot) + pill emoji side by side
    const rows = [
      [
        (26, -1, ''),
        (27, -1, ''),
        (28, -1, ''),
        (29, -1, ''),
        (30, -1, ''),
        (31, -1, ''),
        (1, 0, ''),
      ],
      [
        (2, 3, ''),
        (3, 3, Emojis.weightLifting),
        (4, 3, ''),
        (5, 3, Emojis.yoga),
        (6, 3, ''),
        (7, 3, Emojis.weightLifting),
        (8, 3, ''),
      ],
      [
        (9, 0, ''),
        (10, 0, ''),
        (11, 1, Emojis.weightLifting),
        (12, 0, ''),
        (13, 3, Emojis.boxing),
        (14, 0, ''),
        (15, 2, ''),
      ],
      [
        (16, 3, Emojis.swimming),
        (17, 3, ''),
        (18, 3, Emojis.biceps),
        (19, 0, ''),
        (20, 0, ''),
        (21, 0, ''),
        (22, 0, ''),
      ],
      [
        (23, 2, ''),
        (24, 0, ''),
        (25, 1, Emojis.running),
        (26, 1, Emojis.soccer),
        (27, 3, Emojis.soccer),
        (28, 0, ''),
        (0, -1, ''),
      ],
    ];

    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month header — matches _CalendarHeader style
          Text(
            l10n.monthsFebruary,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Weekday labels — matches calendar_page Row of labelSmall
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: List.generate(7, (i) {
                final name = _weekdayShort(context, i + 1);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: tt.labelSmall?.copyWith(
                        color: mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 2),
          // Day grid — matches GridView crossAxisSpacing/mainAxisSpacing:3
          ...rows.map(
            (week) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 2),
              child: Row(
                children: week.map((cell) {
                  final day = cell.$1;
                  final state = cell.$2;
                  final workoutIcon = cell.$3;
                  final isOutside = state == -1;
                  final hasWorkout = state == 1 || state == 3;
                  final hasSupplement = state == 2 || state == 3;

                  if (day == 0)
                    return const Expanded(child: SizedBox(height: 38));

                  // Colours copied from _calendarDayBackground
                  Color bg;
                  if (isOutside) {
                    bg = emptyCellBg;
                  } else {
                    bg = switch (state) {
                      3 => const Color(0xFF06B6D4),
                      1 => const Color(0xFF3B82F6),
                      2 => const Color(0xFF10B981),
                      _ => emptyCellBg,
                    };
                  }
                  final isActive = state > 0;
                  final textColor = isOutside
                      ? mutedText.withValues(alpha: 0.35)
                      : isActive
                      ? Colors.white
                      : cs.onSurface;

                  Widget cell_ = Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day number — bodyMedium in real app
                        Text(
                          '$day',
                          style: tt.bodySmall?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                        if (!isOutside && (hasWorkout || hasSupplement)) ...[
                          const SizedBox(height: 1),
                          // Emoji row — matches real _CalendarDayCell Row:
                          // workout icon (or dot) + optional pill emoji
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasWorkout && workoutIcon.isNotEmpty)
                                Text(
                                  workoutIcon,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    height: 1,
                                  ),
                                )
                              else if (hasWorkout)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (hasSupplement) ...[
                                if (hasWorkout) const SizedBox(width: 2),
                                const Text(
                                  Emojis.pill,
                                  style: TextStyle(fontSize: 8, height: 1),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  );

                  if (isOutside) cell_ = Opacity(opacity: 0.3, child: cell_);
                  return Expanded(child: cell_);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini supplement log list matching the real _SupplementLogTile from
/// calendar_page.dart (surfaceContainerHighest, pill emoji, timestamp, delete).
class _SupplementPreview extends StatelessWidget {
  const _SupplementPreview();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  l10n.calendarSupplementsTaken,
                  style: tt.titleSmall?.copyWith(color: cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const EmojiText(Emojis.pill, style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          // Log cards — matches _SupplementLogTile exactly
          const _SupplementLogCard(
            name: 'Creatina MyProtein 5g',
            time: '11:57',
          ),
          const SizedBox(height: 8),
          const _SupplementLogCard(name: 'Daily Multivitamin', time: '13:19'),
          const SizedBox(height: 8),
          const _SupplementLogCard(name: 'Omega-3 Fish Oil', time: '08:30'),
        ],
      ),
    );
  }
}

/// Single supplement log row — mirrors _SupplementLogTile from calendar_page.dart:
/// surfaceContainerHighest bg, border-radius 12, outlineVariant border,
/// pill emoji 22px, title bold, stopwatch+time, delete icon red.
class _SupplementLogCard extends StatelessWidget {
  const _SupplementLogCard({required this.name, required this.time});

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill emoji — real app uses fontSize: 22
          const EmojiText(Emojis.pill, style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                // Stopwatch + time — real uses stopwatchFull + bodyMedium
                Text(
                  '${Emojis.stopwatchFull} $time',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          // Delete icon — real uses Icon 18, Color(0xFFEF4444)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.delete_outline,
              size: 16,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini stats page: gradient stat cards + weekly bar chart.
/// Stat cards use _GradientStatCard styling from stats_page.dart (border
/// radius 16, gradient, emoji, value, label). Bar chart uses _VerticalBar
/// styling (bar radius 6, statsBlue highlight).
class _StatsPreview extends StatelessWidget {
  const _StatsPreview();

  static const _barValues = [2.0, 2.0, 4.0, 2.0, 2.0, 5.0, 5.0];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final days = List.generate(7, (i) => _weekdayShort(context, i + 1));
    final maxVal = 5.0;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Year header with nav arrows — matches _CalendarHeader
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left, size: 16, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                '2026',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: cs.onSurface),
            ],
          ),
          const SizedBox(height: 10),
          // Top metric row — 3 cards. Uses real AppColors stat gradients.
          _buildStatRow([
            _MiniStatChip(
              emoji: Emojis.calendar,
              value: '3',
              label: l10n.statsThisMonth,
              colors: const [
                AppColors.statsBluePurple,
                AppColors.statsBluePurpleDark,
              ],
            ),
            _MiniStatChip(
              emoji: Emojis.target,
              value: '22',
              label: l10n.statsThisYear,
              colors: const [
                AppColors.statsPinkRed,
                AppColors.statsPinkRedDark,
              ],
            ),
            _MiniStatChip(
              emoji: Emojis.trophy,
              value: '22',
              label: l10n.statsAllTime,
              colors: const [
                AppColors.statsOrangeAlt,
                AppColors.statsOrangeAltDark,
              ],
            ),
          ]),
          const SizedBox(height: 6),
          // Middle metric row — 2 cards
          _buildStatRow([
            _MiniStatChip(
              emoji: Emojis.star,
              value:
                  '${_weekdayShort(context, 6)} / ${_weekdayShort(context, 7)}',
              label: l10n.statsFavoriteDay,
              colors: const [AppColors.statsViolet, AppColors.statsVioletDark],
            ),
            _MiniStatChip(
              emoji: Emojis.target,
              value: '82%',
              label: l10n.statsConsistency,
              colors: const [AppColors.statsPurple, AppColors.statsPurpleDark],
            ),
          ]),
          const SizedBox(height: 10),
          // Mini bar chart — matches _VerticalBar styling
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const EmojiText(
                      Emojis.barChart,
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.statsDaysYouHitGym,
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final isHighlight = i >= 5;
                      final ratio = (_barValues[i] / maxVal).clamp(0.0, 1.0);
                      final barH = 4 + (ratio * 34); // min 4, max ~38

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Value above bar
                              Text(
                                _barValues[i].round().toString(),
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isHighlight
                                      ? AppColors.statsBlue
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Bar — radius 6 matches _VerticalBar
                              Container(
                                width: 16,
                                height: barH,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: isHighlight
                                      ? AppColors.statsBlue
                                      : cs.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Day label
                              Text(
                                days[i],
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 8,
                                  color: isHighlight
                                      ? AppColors.statsBlue
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(List<_MiniStatChip> chips) {
    return Row(
      children: chips
          .expand(
            (chip) => [
              Expanded(child: chip),
              if (chip != chips.last) const SizedBox(width: 6),
            ],
          )
          .toList(),
    );
  }
}

/// Mini gradient stat card — exact copy of _GradientStatCard from stats_page.dart
/// but with slightly smaller font sizes to fit the onboarding preview.
class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.emoji,
    required this.value,
    required this.label,
    required this.colors,
  });

  final String emoji;
  final String value;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    // Same structure as _GradientStatCard: borderRadius 16, gradient, padded
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmojiText(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tt.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Localized 3-letter weekday abbreviation.
/// Mirrors `_weekdayShort` from `calendar_page.dart`.
String _weekdayShort(BuildContext context, int weekday) {
  final l10n = AppLocalizations.of(context);
  final value = switch (weekday) {
    1 => l10n.weekdaysMonday,
    2 => l10n.weekdaysTuesday,
    3 => l10n.weekdaysWednesday,
    4 => l10n.weekdaysThursday,
    5 => l10n.weekdaysFriday,
    6 => l10n.weekdaysSaturday,
    _ => l10n.weekdaysSunday,
  };
  if (value.length <= 3) return value;
  return value.substring(0, 3);
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.currentPage,
    required this.totalPages,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int currentPage;
  final int totalPages;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

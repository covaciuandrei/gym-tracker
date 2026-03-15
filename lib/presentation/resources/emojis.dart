/// App-wide emoji constants.
///
/// Every emoji is stored as a Dart Unicode escape — never as a literal
/// character — so the source files stay encoding-safe across all build
/// environments and iOS versions.
///
/// Usage:
/// ```dart
/// EmojiText(Emojis.biceps)
/// EmojiText(Emojis.weightLifting)
/// ```
// ignore_for_file: constant_identifier_names
class Emojis {
  Emojis._();

  // ── Workout / sports ────────────────────────────────────────────────────────

  /// 💪  Flexed biceps — generic workout icon
  static const biceps = '\u{1F4AA}';

  /// 🏋️  Weight lifter — strength training
  static const weightLifting = '\u{1F3CB}\u{FE0F}';

  /// 🏃  Runner — cardio / running
  static const running = '\u{1F3C3}';

  /// 🚴  Cyclist — cycling / spinning
  static const cycling = '\u{1F6B4}';

  /// 🧘  Lotus pose — yoga / stretching
  static const yoga = '\u{1F9D8}';

  /// 🥊  Boxing glove — boxing / combat sports
  static const boxing = '\u{1F94A}';

  /// 🏊  Swimmer — swimming
  static const swimming = '\u{1F3CA}';

  /// ⚽  Soccer ball
  static const soccer = '\u{26BD}';

  /// 🎾  Tennis racket
  static const tennis = '\u{1F3BE}';

  /// 🏀  Basketball
  static const basketball = '\u{1F3C0}';

  /// 🤸  Gymnastics / acrobatics
  static const gymnastics = '\u{1F938}';

  /// 🚣  Rowing
  static const rowing = '\u{1F6A3}';

  /// ⛹️  Person bouncing ball — basketball variant
  static const bouncingBall = '\u{26F9}\u{FE0F}';

  /// 🤾  Handball
  static const handball = '\u{1F93E}';

  /// 🏌️  Golf
  static const golf = '\u{1F3CC}\u{FE0F}';

  /// 🧗  Wall climbing
  static const climbing = '\u{1F9D7}';

  // ── Stats / metrics ──────────────────────────────────────────────────────────

  /// 📅  Calendar — monthly stats
  static const calendar = '\u{1F4C5}';

  /// 🎯  Bullseye — goal / consistency / target
  static const target = '\u{1F3AF}';

  /// 🏆  Trophy — best streak / achievement
  static const trophy = '\u{1F3C6}';

  /// 📊  Bar chart
  static const barChart = '\u{1F4CA}';

  /// 📈  Chart increasing
  static const chartIncreasing = '\u{1F4C8}';

  /// 📝  Memo / note — untracked counts
  static const memo = '\u{1F4DD}';

  /// ⏱  Stopwatch — duration (no variation selector)
  static const stopwatch = '\u{23F1}';

  /// ⏱️  Stopwatch — duration (with variation selector)
  static const stopwatchFull = '\u{23F1}\u{FE0F}';

  /// 💊  Pill — supplement
  static const pill = '\u{1F48A}';

  // ── Streak motivational ──────────────────────────────────────────────────────

  /// 🔥  Fire — on a streak
  static const fire = '\u{1F525}';

  /// 🎉  Party popper — first milestone
  static const party = '\u{1F389}';

  /// 👑  Crown — consistency king
  static const crown = '\u{1F451}';

  /// 💎  Gem — unstoppable
  static const gem = '\u{1F48E}';

  /// 🦁  Lion — half-year beast
  static const lion = '\u{1F981}';

  /// 🌟  Glowing star — almost a full year
  static const glowingStar = '\u{1F31F}';

  /// ⭐  Star — favourite day
  static const star = '\u{2B50}';

  /// 🐐  Goat — G.O.A.T.
  static const goat = '\u{1F410}';

  // ── UI / state ───────────────────────────────────────────────────────────────

  /// 📭  Empty mailbox — empty state
  static const emptyMailbox = '\u{1F4ED}';

  /// ⚠️  Warning sign — error state
  static const warning = '\u{26A0}\u{FE0F}';

  /// ✅  Check mark button — success
  static const checkMark = '\u{2705}';

  /// 📧  E-mail — forgot-password confirmation
  static const email = '\u{1F4E7}';

  /// 🔐  Locked with key — forgot password header
  static const lockedWithKey = '\u{1F510}';

  /// 🔒  Locked — set-password header
  static const locked = '\u{1F512}';

  /// 🌅  Sunrise — supplements today (no logs yet)
  static const sunrise = '\u{1F305}';

  /// 🧪  Test tube — no supplement found
  static const testTube = '\u{1F9EA}';
}

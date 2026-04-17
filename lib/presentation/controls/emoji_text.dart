import 'dart:io';

import 'package:flutter/material.dart';

/// A [Text]-like widget that guarantees emoji glyphs render on every iOS
/// version, including iOS 26+ where Impeller's implicit font-fallback chain
/// no longer picks up Apple Color Emoji automatically.
///
/// **Why not `TextStyle.copyWith(fontFamily: '')`?**
/// `copyWith` with a null/empty family silently keeps whatever `fontFamily` is
/// already set, so the broken font is still used first on iOS. We create a
/// brand-new [TextStyle] from scratch (guaranteed `null` fontFamily) and list
/// `'Apple Color Emoji'` explicitly in [TextStyle.fontFamilyFallback]. The
/// OS text engine then uses Apple Color Emoji for every code point that the
/// primary (null = system) font doesn't cover — which is exactly what you
/// want for emoji.
///
/// On Android the widget behaves identically to [Text].
///
/// Usage:
/// ```dart
/// EmojiText(Emojis.biceps, style: TextStyle(fontSize: 48))
/// ```
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      // Android / other platforms: system emoji fallback works out of the box.
      return Text(data, style: style, textAlign: textAlign);
    }

    // ── iOS: explicit Apple Color Emoji path ────────────────────────────────
    //
    // We need two things simultaneously:
    //   1. fontFamily = null   → system (SF Pro) is primary font.
    //   2. fontFamilyFallback includes 'Apple Color Emoji' → emoji are found.
    //
    // Creating a new TextStyle (not copyWith!) is the only way to guarantee
    // fontFamily is null regardless of what any ancestor DefaultTextStyle has.
    //
    // We manually carry over the visual attributes from the caller-provided
    // style so sizing, weight, colour, etc. are preserved.
    final DefaultTextStyle defaultStyle = DefaultTextStyle.of(context);
    final TextStyle inherited = defaultStyle.style;
    final TextStyle? base = style;

    final TextStyle iosStyle = TextStyle(
      fontSize: base?.fontSize ?? inherited.fontSize,
      fontWeight: base?.fontWeight ?? inherited.fontWeight,
      fontStyle: base?.fontStyle ?? inherited.fontStyle,
      color: base?.color ?? inherited.color,
      height: base?.height ?? inherited.height,
      letterSpacing: base?.letterSpacing,
      wordSpacing: base?.wordSpacing,
      decoration: base?.decoration,
      decorationColor: base?.decorationColor,
      decorationStyle: base?.decorationStyle,
      // fontFamily intentionally omitted → null → system default (SF Pro)
      fontFamilyFallback: const <String>['Apple Color Emoji'],
    );

    return Text(data, style: iosStyle, textAlign: textAlign);
  }
}

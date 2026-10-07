import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import 'theme.dart';

export 'theme.dart';

/// Warm studio-light backdrop behind the dark tiles.
class PocketBackground extends StatelessWidget {
  const PocketBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.32, 0.7, 1.0],
          colors: [
            Color(0xFFE2A56E),
            Color(0xFF8A5B3F),
            Color(0xFF3A2C25),
            Color(0xFF1C1816),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

/// Title block: big dot-matrix name, mono subtitle, orange status line.
class PocketHeader extends StatelessWidget {
  const PocketHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.status,
  });

  final String title;
  final String subtitle;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: dot(34, color: const Color(0xFFFFF3E8), spacing: 2),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle.toUpperCase(),
            style: mono(13, color: const Color(0xCCFFF3E8), spacing: 1.4),
          ),
          if (status != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status!,
                  style: mono(12, color: const Color(0xCCFFF3E8), spacing: 0.4),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Dark rounded tile with a numbered mono header ("01  SIGN IN").
class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.index,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 20),
    this.onTap,
  });

  final String index;
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kTile,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: kLine),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(index, style: mono(11, color: kMuted)),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: mono(11, color: const Color(0xFFD8D4D0), spacing: 1.2),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
    if (onTap == null) return body;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: body,
    );
  }
}

/// Tiny orange dot + label, e.g. "● PARKED".
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.hot = true});
  final String label;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: mono(11, color: kMuted)),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: hot ? kAccent : kMuted,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

/// Big dot-matrix number with a small mono caption beneath ("128 / STEPS").
class Stat extends StatelessWidget {
  const Stat({super.key, required this.value, required this.caption, this.hot});
  final String value;
  final String caption;
  final bool? hot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption.toUpperCase(), style: mono(10, color: kMuted)),
        const SizedBox(height: 4),
        Text(value, style: dot(28, color: hot == true ? kAccent : kInk)),
      ],
    );
  }
}

/// Glass button, full width. [primary] tints the glass orange.
class GlassAction extends StatelessWidget {
  const GlassAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.busy = false,
    this.primary = true,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool busy;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return GlassButton.custom(
      width: double.infinity,
      height: 52,
      shape: const LiquidRoundedRectangle(borderRadius: 18),
      useOwnLayer: true,
      settings: LiquidGlassSettings(
        glassColor: primary ? const Color(0x55FF4A1C) : const Color(0x22FFFFFF),
        thickness: 18,
        blur: 8,
      ),
      glowColor: kAccent.withValues(alpha: 0.5),
      enabled: onTap != null && !busy,
      onTap: onTap ?? () {},
      child: Center(
        child: busy
            ? const CupertinoActivityIndicator(color: kInk)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: kInk, size: 18),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: mono(13, color: kInk, spacing: 1.4)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }
}

class PocketField extends StatelessWidget {
  const PocketField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      placeholder: placeholder,
      useOwnLayer: true,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      shape: const LiquidRoundedRectangle(borderRadius: 16),
      textStyle: mono(14, color: kInk, spacing: 0.2),
      placeholderStyle: mono(14, color: kMuted, spacing: 0.2),
      prefixIcon: icon == null ? null : Icon(icon, size: 18, color: kMuted),
    );
  }
}

class PocketPasswordField extends StatelessWidget {
  const PocketPasswordField({
    super.key,
    required this.controller,
    this.placeholder = 'Password',
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return GlassPasswordField(
      controller: controller,
      placeholder: placeholder,
      useOwnLayer: true,
      onSubmitted: onSubmitted,
      shape: const LiquidRoundedRectangle(borderRadius: 16),
      textStyle: mono(14, color: kInk, spacing: 0.2),
      placeholderStyle: mono(14, color: kMuted, spacing: 0.2),
    );
  }
}

class LinkText extends StatelessWidget {
  const LinkText(this.text, {super.key, required this.onTap, this.center = true});
  final String text;
  final VoidCallback onTap;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text.toUpperCase(),
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: mono(12, color: kAccent, spacing: 1.2)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Footer tagline with a blinking-cursor feel: "YOUR CARDS. ONE POCKET. _"
class Tagline extends StatelessWidget {
  const Tagline(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 4),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: mono(13, color: const Color(0xAAFFF3E8), spacing: 1.6),
          ),
          Text(' _', style: mono(13, color: kAccent, spacing: 1.6)),
        ],
      ),
    );
  }
}

/// Safe-area aware page padding. GlassScaffold draws the body behind the
/// status bar and app bar, so push content below them (and above the home bar).
EdgeInsets pagePadding(BuildContext context,
    {bool appBar = true, double bottom = 32}) {
  final pad = MediaQuery.paddingOf(context);
  return EdgeInsets.fromLTRB(
    20,
    pad.top + (appBar ? 44 + 16 : 24),
    20,
    pad.bottom + bottom,
  );
}

void showError(BuildContext context, Object e) {
  GlassToast.show(
    context,
    message: AuthService.messageOf(e),
    type: GlassToastType.error,
    position: GlassToastPosition.top,
  );
}

void showOk(BuildContext context, String message) {
  GlassToast.show(
    context,
    message: message,
    type: GlassToastType.success,
    position: GlassToastPosition.top,
  );
}

/// Back button for GlassAppBar.leading.
Widget backButton(BuildContext context) => GlassIconButton(
      icon: const Icon(CupertinoIcons.back),
      semanticLabel: 'Back',
      onPressed: () => Navigator.of(context).pop(),
    );

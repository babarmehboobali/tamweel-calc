import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Motion helpers. All respect the OS "remove animations" setting.
bool reduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

Duration motion(BuildContext context, Duration d) => reduceMotion(context) ? Duration.zero : d;

/// Light haptic tick for key taps.
void tapHaptic() => HapticFeedback.selectionClick();

/// Animates a number from its previous value to [value] and renders it with [format].
class CountUpText extends StatefulWidget {
  final double value;
  final String Function(double v) format;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;
  const CountUpText({super.key, required this.value, required this.format, this.style, this.textAlign,
      this.duration = const Duration(milliseconds: 700)});

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText> {
  double _from = 0;

  @override
  void didUpdateWidget(covariant CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from, end: widget.value),
      duration: motion(context, widget.duration),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(widget.format(v), style: widget.style, textAlign: widget.textAlign),
    );
  }
}

/// Fades and slides a child in once, delayed by its [index] for a staggered list effect.
class StaggerIn extends StatefulWidget {
  final int index;
  final Widget child;
  const StaggerIn({super.key, required this.index, required this.child});

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 40 * widget.index.clamp(0, 12)), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(a), child: widget.child),
    );
  }
}

/// Scales down slightly while pressed, with a haptic tick on tap.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  const Pressable({super.key, required this.child, this.onTap, this.borderRadius = const BorderRadius.all(Radius.circular(18))});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 0.96 : 1,
      duration: motion(context, const Duration(milliseconds: 110)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onHighlightChanged: (v) => setState(() => _down = v),
          onTap: widget.onTap == null ? null : () { tapHaptic(); widget.onTap!(); },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Pulsing placeholder block for loading skeletons.
class Shimmer extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;
  const Shimmer({super.key, this.height = 14, this.width, this.radius = 8});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) { _c.stop(); _c.value = 0.5; } else if (!_c.isAnimating) { _c.repeat(reverse: true); }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base.withValues(alpha: 0.06 + 0.08 * _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Friendly empty state with icon, title and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary.withValues(alpha: 0.10)),
            child: Icon(icon, size: 44, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loomoreach brand palette, shared with loomoreach.org.
class LmColors {
  LmColors._();

  static const purple = Color(0xFF7458F2);
  static const purpleDark = Color(0xFF5B3FDA);
  static const violet = Color(0xFF8568FF);
  static const cyan = Color(0xFF48CADB);
  static const ok = Color(0xFF34D3A6);

  static const night = Color(0xFF0D0B16);
  static const nightPanel = Color(0xFF120F22);
  static const nightCard = Color(0xFF1A1630);
  static const nightField = Color(0xFF1C1833);
  static const nightLine = Color(0xFF2A2447);

  static const soft = Color(0xFFF7F5FC);
  static const softPanel = Color(0xFFF1EDFB);
  static const ink = Color(0xFF17142A);
  static const copy = Color(0xFF656076);
  static const line = Color(0x245D499D);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, Color(0xFF686EEA), cyan],
    stops: [0, .52, 1],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, Color(0xFF5E7BEA)],
  );

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color panel(BuildContext context) =>
      isDark(context) ? nightPanel : softPanel;

  static Color card(BuildContext context) =>
      isDark(context) ? nightCard.withOpacity(.72) : Colors.white;

  static Color border(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(.08) : line;

  static Color muted(BuildContext context) => isDark(context)
      ? Colors.white.withOpacity(.55)
      : copy;
}

const _kLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 44 44">
  <rect x="1" y="1" width="42" height="42" rx="13" fill="url(#s)"/>
  <path d="M13.5 16.75v-1.5a3.5 3.5 0 0 1 3.5-3.5h4.25a3.5 3.5 0 0 1 3.5 3.5v6.5a3.5 3.5 0 0 1-3.5 3.5H17a3.5 3.5 0 0 1-3.5-3.5v-1.5" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round"/>
  <path d="M30.5 27.25v1.5a3.5 3.5 0 0 1-3.5 3.5h-4.25a3.5 3.5 0 0 1-3.5-3.5v-6.5a3.5 3.5 0 0 1 3.5-3.5H27a3.5 3.5 0 0 1 3.5 3.5v1.5" fill="none" stroke="#e6fcff" stroke-width="3" stroke-linecap="round"/>
  <circle cx="13.5" cy="18.5" r="1.5" fill="#c9fbff"/>
  <circle cx="30.5" cy="25.5" r="1.5" fill="#fff"/>
  <defs>
    <linearGradient id="s" x1="5" y1="3" x2="39" y2="41" gradientUnits="userSpaceOnUse">
      <stop stop-color="#8568ff"/>
      <stop offset=".52" stop-color="#686eea"/>
      <stop offset="1" stop-color="#43d4dc"/>
    </linearGradient>
  </defs>
</svg>
''';

/// The Loomoreach mark (same artwork as the website favicon).
class LmLogoMark extends StatelessWidget {
  final double size;
  const LmLogoMark({Key? key, this.size = 32}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      SvgPicture.string(_kLogoSvg, width: size, height: size);
}

/// Mark plus "Loomoreach" wordmark.
class LmBrand extends StatelessWidget {
  final double size;
  final String name;
  const LmBrand({Key? key, this.size = 30, this.name = 'Loomoreach'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LmLogoMark(size: size),
        SizedBox(width: size * .34),
        Text(
          name,
          style: TextStyle(
            fontSize: size * .6,
            fontWeight: FontWeight.w700,
            letterSpacing: -.2,
            color: LmColors.isDark(context) ? Colors.white : LmColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Rounded translucent card with a hairline border, like the website's glass panels.
class LmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool glow;
  const LmCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.glow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = LmColors.isDark(context);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: LmColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: glow
                ? LmColors.purple.withOpacity(dark ? .45 : .3)
                : LmColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: (glow ? LmColors.purple : Colors.black)
                .withOpacity(dark ? (glow ? .22 : .25) : .06),
            blurRadius: glow ? 28 : 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Primary call-to-action with the brand gradient.
class LmGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final IconData? icon;
  const LmGradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.height = 36,
    this.icon,
  }) : super(key: key);

  @override
  State<LmGradientButton> createState() => _LmGradientButtonState();
}

class _LmGradientButtonState extends State<LmGradientButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LmColors.buttonGradient,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: LmColors.purple.withOpacity(_hover ? .55 : .32),
                blurRadius: _hover ? 22 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill with a coloured dot, used for live status.
class LmStatusPill extends StatelessWidget {
  final Color color;
  final Widget label;
  const LmStatusPill({Key? key, required this.color, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(.7), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: label),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TopBarActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double size;

  const TopBarActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
    this.trailing,
    this.size = 20,
  });

  @override
  State<TopBarActionButton> createState() => _TopBarActionButtonState();
}

class _TopBarActionButtonState extends State<TopBarActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withAlpha(30)
                : widget.color.withAlpha(10),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withAlpha(30)
                    : widget.color.withAlpha(10),
                blurRadius: _isHovered ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.icon,
                    key: ValueKey('${_isHovered}_${widget.icon.hashCode}'),
                    color: widget.color,
                    size: widget.size,
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 4),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  void _updatePressed(bool value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.outlined
        ? _buildOutlinedButton(context)
        : _buildFilledButton(context);

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => _updatePressed(true),
      onTapCancel: widget.onPressed == null
          ? null
          : () => _updatePressed(false),
      onTapUp: widget.onPressed == null ? null : (_) => _updatePressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1,
        child: child,
      ),
    );
  }

  Widget _buildFilledButton(BuildContext context) {
    if (widget.icon != null) {
      return FilledButton.icon(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        label: Text(widget.label),
      );
    }
    return FilledButton(onPressed: widget.onPressed, child: Text(widget.label));
  }

  Widget _buildOutlinedButton(BuildContext context) {
    if (widget.icon != null) {
      return OutlinedButton.icon(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        label: Text(widget.label),
      );
    }
    return OutlinedButton(
      onPressed: widget.onPressed,
      child: Text(widget.label),
    );
  }
}

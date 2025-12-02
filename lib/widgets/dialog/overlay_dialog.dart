import 'package:flutter/material.dart';

class OverlayDialogController {
  final VoidCallback _dismiss;
  bool _dismissed = false;

  OverlayDialogController(this._dismiss);

  bool get isDismissed => _dismissed;

  void dismiss() {
    if (!_dismissed) {
      _dismiss();
      _dismissed = true;
    }
  }
}

OverlayDialogController showOverlayDialog(
  BuildContext context, {
  required Widget child,
  Widget Function(Widget dialog)? positioned,
  bool barrierDismissible = true,
  Color barrierColor = Colors.transparent,
  bool useSafeArea = true,
  Duration duration = const Duration(milliseconds: 300),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  final List<OverlayEntry> entries = [];

  final overlayWidgetKey = GlobalKey<_OverlayDialogWidgetState>();

  void dismissAll() {
    for (final e in entries) {
      e.remove();
    }
    entries.clear();
  }

  final barrierEntry = OverlayEntry(
    builder: (ctx) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: barrierDismissible ? dismissAll : null,
        child: Container(color: barrierColor),
      );
    },
  );

  final dialogEntry = OverlayEntry(
    builder: (ctx) {
      return _OverlayDialogWidget(
        key: overlayWidgetKey,
        positioned: positioned,
        useSafeArea: useSafeArea,
        duration: duration,
        child: child,
      );
    },
  );

  final controller = OverlayDialogController(dismissAll);

  entries.addAll([barrierEntry, dialogEntry]);
  overlay.insertAll(entries);

  return controller;
}

class _OverlayDialogWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(Widget dialog)? positioned;
  final bool useSafeArea;
  final Duration duration;

  const _OverlayDialogWidget({
    super.key,
    required this.child,
    this.positioned,
    this.useSafeArea = true,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  _OverlayDialogWidgetState createState() => _OverlayDialogWidgetState();
}

class _OverlayDialogWidgetState extends State<_OverlayDialogWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  Future<void> dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    try {
      await _controller.reverse();
    } finally {
      _isDismissing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildInner(BuildContext ctx) {
    Widget inner = Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        stepWidth: 1,
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(ctx).size.width * 0.95,
              maxHeight: MediaQuery.of(ctx).size.height * 0.95,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.useSafeArea) inner = SafeArea(child: inner);

    if (widget.positioned == null) {
      return Center(child: inner);
    }

    final positionedWidget = widget.positioned!(
      IgnorePointer(ignoring: false, child: inner),
    );
    return Stack(children: [positionedWidget]);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: _buildInner(context));
  }
}

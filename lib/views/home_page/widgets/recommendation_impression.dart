import 'dart:async';

import 'package:flutter/material.dart';

/// Counts a card only after at least half its area is visible for one continuous
/// second. Scroll notifications reset the dwell immediately; periodic sampling
/// also handles layout, tab transitions, routes, and lifecycle changes.
class RecommendationImpression extends StatefulWidget {
  const RecommendationImpression({
    super.key,
    required this.viewportKey,
    required this.active,
    required this.onImpression,
    required this.child,
  });

  final GlobalKey viewportKey;
  final bool active;
  final VoidCallback onImpression;
  final Widget child;

  @override
  State<RecommendationImpression> createState() =>
      _RecommendationImpressionState();
}

class _RecommendationImpressionState extends State<RecommendationImpression>
    with WidgetsBindingObserver {
  final _cardKey = GlobalKey();
  Timer? _sample;
  Timer? _dwell;
  ScrollPosition? _scroll;
  bool _reported = false;
  bool _resumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _sample = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _check(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scroll) {
      _scroll?.removeListener(_onScroll);
      _scroll = position;
      _scroll?.addListener(_onScroll);
    }
    if (!TickerMode.valuesOf(context).enabled ||
        ModalRoute.of(context)?.isCurrent == false) {
      _cancelDwell();
    }
  }

  @override
  void didUpdateWidget(RecommendationImpression oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active) _cancelDwell();
  }

  void _onScroll() {
    _check();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  bool _visible() {
    if (!mounted ||
        !widget.active ||
        !_resumed ||
        !TickerMode.valuesOf(context).enabled ||
        ModalRoute.of(context)?.isCurrent == false) {
      return false;
    }
    final card = _cardKey.currentContext?.findRenderObject();
    final viewport = widget.viewportKey.currentContext?.findRenderObject();
    if (card is! RenderBox ||
        viewport is! RenderBox ||
        !card.attached ||
        !viewport.attached ||
        !card.hasSize ||
        !viewport.hasSize ||
        card.size.isEmpty) {
      return false;
    }
    final rect = card.localToGlobal(Offset.zero) & card.size;
    final bounds = viewport.localToGlobal(Offset.zero) & viewport.size;
    final visible = rect
        .intersect(bounds)
        .intersect(Offset.zero & MediaQuery.sizeOf(context));
    return !visible.isEmpty &&
        visible.width * visible.height >= rect.width * rect.height * 0.5;
  }

  void _check() {
    if (_reported || !mounted) return;
    if (!_visible()) {
      _cancelDwell();
      return;
    }
    _dwell ??= Timer(const Duration(seconds: 1), () {
      _dwell = null;
      if (!_visible() || _reported) return;
      _reported = true;
      _sample?.cancel();
      widget.onImpression();
    });
  }

  void _cancelDwell() {
    _dwell?.cancel();
    _dwell = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (!_resumed) _cancelDwell();
  }

  @override
  void dispose() {
    _cancelDwell();
    _sample?.cancel();
    _scroll?.removeListener(_onScroll);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(key: _cardKey, child: widget.child);
}

import 'package:flutter/widgets.dart';
import 'package:smart_crops/app/analytics/analytics.dart';

/// Fires the wrapped widget's page-view event exactly once after first
/// frame; use for screens pushed as unnamed MaterialPageRoutes.
class AnalyticsView extends StatefulWidget {
  const AnalyticsView({
    super.key,
    required this.event,
    this.params = const {},
    required this.child,
  });

  final String event;
  final Map<String, Object?> params;
  final Widget child;

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.trackEvent(widget.event, params: widget.params);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

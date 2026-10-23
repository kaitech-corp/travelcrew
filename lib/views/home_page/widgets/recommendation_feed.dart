import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/services/recommendation_service.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/views/safety/safety_actions.dart';

import 'location_widget.dart';
import 'recommendation_impression.dart';

class RecommendationFeed extends StatefulWidget {
  const RecommendationFeed({
    super.key,
    required this.service,
    required this.active,
    this.cardBuilder,
  });
  final RecommendationService service;
  final bool active;
  final Widget Function(BuildContext, TripDiscoveryModel)? cardBuilder;

  @override
  State<RecommendationFeed> createState() => _RecommendationFeedState();
}

class _RecommendationFeedState extends State<RecommendationFeed> {
  final _viewportKey = GlobalKey();

  String _explanation(TripDiscoveryModel trip) => switch (trip
      .recommendationExplanation) {
    'followed_creator' => 'From someone you follow',
    'preferred_destination' => 'Matches your destinations',
    'popular_upcoming' => 'Popular upcoming trip',
    _ => 'Upcoming trip',
  };

  Future<void> _dismiss(TripDiscoveryModel trip, bool dismissed) async {
    try {
      await widget.service.dismiss(trip, dismissed);
      if (!mounted || !dismissed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip hidden from your recommendations.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _dismiss(trip, false),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update this recommendation. Try again.'),
          ),
        );
      }
    }
  }

  Widget _card(TripDiscoveryModel trip) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              _explanation(trip),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Recommendation options',
            enabled: !widget.service.busyDismissals.contains(trip.id),
            onSelected: (_) => _dismiss(trip, true),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: 'dismiss',
                    child: Text('Not interested'),
                  ),
                ],
          ),
        ],
      ),
      RecommendationImpression(
        key: ValueKey('${trip.recommendation?.sessionId}:${trip.id}'),
        viewportKey: _viewportKey,
        active: widget.active,
        onImpression: () => widget.service.observe(trip, 'impression'),
        child:
            widget.cardBuilder?.call(context, trip) ??
            LocationWidget(tripModel: trip),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.service,
    builder:
        (context, _) => Obx(() {
          if (!SafetyService.ready.value) return const SafetyLoadingView();
          final service = widget.service;
          final trips =
              service.items
                  .where((trip) => !SafetyService.hides(trip.createdBy))
                  .toList();
          return Column(
            children: [
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed:
                        () => showDialog<void>(
                          context: context,
                          builder:
                              (_) => RecommendationPreferencesDialog(
                                service: service,
                              ),
                        ),
                    icon: const Icon(Icons.tune),
                    label: const Text('Preferences'),
                  ),
                  TextButton.icon(
                    onPressed:
                        service.loading
                            ? null
                            : () => service.load(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              if (service.error != null || service.needsRefresh)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.error ??
                              'Your preferences changed. Refresh recommendations.',
                        ),
                      ),
                      TextButton(
                        onPressed: service.loading ? null : service.retry,
                        child: Text(service.needsRefresh ? 'Refresh' : 'Retry'),
                      ),
                    ],
                  ),
                ),
              if (service.loading && trips.isNotEmpty)
                const LinearProgressIndicator(),
              Expanded(
                child: SizedBox.expand(
                  key: _viewportKey,
                  child:
                      service.loading && trips.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : trips.isEmpty
                          ? Center(
                            child: Text(
                              service.error != null
                                  ? 'Your recommendations will appear here.'
                                  : service.hasMore
                                  ? 'No matching trips on this page. Load more to keep looking.'
                                  : 'No trips match right now. Try other destinations or check back later.',
                            ),
                          )
                          : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth >= 720) {
                                return GridView.builder(
                                  key: PageStorageKey(
                                    'recommendations-grid-${service.sessionId}',
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    18,
                                    16,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent:
                                            370 +
                                            40 *
                                                (MediaQuery.textScalerOf(
                                                      context,
                                                    ).scale(1) -
                                                    1),
                                      ),
                                  itemCount: trips.length,
                                  itemBuilder:
                                      (_, index) => _card(trips[index]),
                                );
                              }
                              return ListView.separated(
                                key: PageStorageKey(
                                  'recommendations-list-${service.sessionId}',
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  18,
                                  16,
                                ),
                                itemCount: trips.length,
                                itemBuilder: (_, index) => _card(trips[index]),
                                separatorBuilder:
                                    (_, _) => const SizedBox(height: 16),
                              );
                            },
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child:
                    service.hasMore
                        ? TextButton(
                          onPressed:
                              service.loading ? null : () => service.load(),
                          child: const Text('Load more'),
                        )
                        : service.loaded &&
                            trips.isNotEmpty &&
                            !service.needsRefresh
                        ? const Text('No more recommendations right now.')
                        : const SizedBox.shrink(),
              ),
            ],
          );
        }),
  );
}

class RecommendationPreferencesDialog extends StatefulWidget {
  const RecommendationPreferencesDialog({super.key, required this.service});
  final RecommendationService service;

  @override
  State<RecommendationPreferencesDialog> createState() =>
      _RecommendationPreferencesDialogState();
}

class _RecommendationPreferencesDialogState
    extends State<RecommendationPreferencesDialog> {
  late final TextEditingController _destinations = TextEditingController(
    text: widget.service.destinations.join('\n'),
  );
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    final destinations =
        _destinations.text
            .split('\n')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toSet()
            .toList();
    if (destinations.length > 10 || destinations.any((v) => v.length > 160)) {
      setState(
        () => _error = 'Use up to 10 destinations, each under 160 characters.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.service.savePreferences(destinations);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save preferences. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _destinations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Travel preferences'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Which cities or countries would you like to visit? Add one per line, or leave this empty to explore.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinations,
              enabled: !_saving,
              minLines: 3,
              maxLines: 6,
              maxLength: 1600,
              decoration: InputDecoration(
                labelText: 'Destinations',
                hintText: 'Paris\nJapan',
                errorText: _error,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving…' : 'Save'),
      ),
    ],
  );
}

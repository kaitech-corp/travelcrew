import 'package:flutter/material.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/transportation_service.dart';
import '../controller/specific_trip_view_controller.dart';
import '../controller/transportation_editor_controller.dart';
import 'transportation_editor.dart';

Future<void> showTransportationEditor(
  BuildContext context,
  TripModel trip, {
  TransportationModel? existing,
}) async {
  final controller = TransportationEditorController(
    existing: existing,
    tripId: trip.id,
    userId: GlobalVariables.currentUid,
    displayName: GlobalVariables.loggedInUser.value?.displayName ?? '',
  );
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    builder:
        (_) => TransportationEditor(
          controller: controller,
          onSave:
              (entry) =>
                  TransportationService.save(entry, isNew: existing == null),
        ),
  );
}

class TransportTab extends StatefulWidget {
  const TransportTab({super.key, required this.controller, this.entriesStream});
  final SpecificTripViewController controller;
  final Stream<List<TransportationModel>>? entriesStream;
  @override
  State<TransportTab> createState() => _TransportTabState();
}

class _TransportTabState extends State<TransportTab> {
  late Stream<List<TransportationModel>> entries;
  TransportationMode? filter;
  String? loadedTripId;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    loadedTripId = widget.controller.tripModel.value!.id;
    entries =
        widget.entriesStream ??
        TransportationService.watch(widget.controller.tripModel.value!.id);
  }

  @override
  void didUpdateWidget(covariant TransportTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entriesStream != widget.entriesStream ||
        loadedTripId != widget.controller.tripModel.value?.id) {
      _load();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<List<TransportationModel>>(
    stream: entries,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Column(
          children: [
            const Text('Transportation could not be loaded.'),
            TextButton(
              onPressed: () => setState(_load),
              child: const Text('Retry'),
            ),
          ],
        );
      }
      if (!snapshot.hasData) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final all = snapshot.data!;
      if (all.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Add how you’re getting there or getting around. Dates and times are optional.',
          ),
        );
      }
      final modes = all.map((entry) => entry.mode).toSet();
      final selected = modes.contains(filter) ? filter : null;
      final shown = all.where(
        (entry) => selected == null || entry.mode == selected,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (modes.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: selected == null,
                    onSelected: (_) => setState(() => filter = null),
                  ),
                  for (final mode in TransportationMode.values.where(
                    modes.contains,
                  ))
                    ChoiceChip(
                      label: Text(mode.label),
                      selected: selected == mode,
                      onSelected: (_) => setState(() => filter = mode),
                    ),
                ],
              ),
            ),
          for (final entry in shown)
            TransportationCard(
              entry: entry,
              canManage:
                  GlobalVariables.currentUid.isNotEmpty &&
                  (entry.userId == GlobalVariables.currentUid ||
                      widget.controller.tripModel.value!.createdBy ==
                          GlobalVariables.currentUid),
              onEdit:
                  () => showTransportationEditor(
                    context,
                    widget.controller.tripModel.value!,
                    existing: entry,
                  ),
              onDelete: () => _delete(entry),
            ),
        ],
      );
    },
  );

  Future<void> _delete(TransportationModel entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete transportation?'),
            content: Text('Remove “${entry.mode.label}” from this trip?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    try {
      await TransportationService.delete(entry);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not delete transportation. Check your connection and trip access.',
            ),
          ),
        );
      }
    }
  }
}

class TransportationCard extends StatelessWidget {
  const TransportationCard({
    super.key,
    required this.entry,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });
  final TransportationModel entry;
  final bool canManage;
  final VoidCallback? onEdit, onDelete;
  static IconData icon(TransportationMode mode) => switch (mode) {
    TransportationMode.flight => Icons.flight,
    TransportationMode.driving => Icons.directions_car,
    TransportationMode.rideshare || TransportationMode.taxi => Icons.local_taxi,
    TransportationMode.train => Icons.train,
    TransportationMode.bus => Icons.directions_bus,
    TransportationMode.scooter => Icons.electric_scooter,
    TransportationMode.bicycle => Icons.pedal_bike,
    TransportationMode.walking => Icons.directions_walk,
    TransportationMode.ferry ||
    TransportationMode.boat => Icons.directions_boat,
    TransportationMode.other => Icons.route,
  };
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon(entry.mode), color: const Color(0xFF1D7FC2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.mode.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  tooltip: 'Transportation actions',
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit?.call();
                    } else {
                      onDelete?.call();
                    }
                  },
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                ),
            ],
          ),
          if (entry.displayName.trim().isNotEmpty)
            _line(entry.displayName.trim()),
          if (entry.departure != null)
            _line(
              'Departure: ${TransportationModel.formatDate(entry.departure)}',
            ),
          if (entry.arrival != null)
            _line('Arrival: ${TransportationModel.formatDate(entry.arrival)}'),
          if (entry.departure == null && entry.arrival == null)
            _line('Time not set'),
          if (entry.notes.isNotEmpty) _line(entry.notes),
        ],
      ),
    ),
  );
  Widget _line(String value) =>
      Padding(padding: const EdgeInsets.only(top: 8), child: Text(value));
}

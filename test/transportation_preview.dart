// Local visual-verification harness. Uses production cards/editor with in-memory
// saves; it never connects to Firebase or writes real trip data.
import 'package:flutter/material.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transport_tab.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transportation_editor.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/transportation_editor_controller.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorSchemeSeed: const Color(0xFF1D7FC2),
      useMaterial3: true,
    ),
    home: const Preview(),
  ),
);

class Preview extends StatefulWidget {
  const Preview({super.key});
  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  final entries = <TransportationModel>[
    TransportationModel.fromMap('flight', 'preview', {
      'userId': 'owner',
      'transportTitle': 'Flight to Tokyo',
      'airlineName': 'Example Air',
      'flightNumber': 'TC123',
      'departureAirport': 'Los Angeles',
      'arrivalAirport': 'Tokyo Narita',
      'departureDate': '2027-04-10T10:00:00-07:00',
      'arrivalDate': '2027-04-11T14:00:00+09:00',
      'notes':
          'Example Air TC123 — Los Angeles to Tokyo Narita. Randy and Alex.',
    }, source: TransportationSource.flight),
    const TransportationModel(
      id: 'ride',
      tripId: 'preview',
      userId: 'owner',
      mode: TransportationMode.rideshare,
      title: 'Airport transfer',
      provider: 'Uber',
      origin: 'Narita Airport',
      destination: 'Hotel',
      notes: 'Uber from Narita Airport to hotel. Meet at arrivals',
    ),
    const TransportationModel(
      id: 'scooter',
      tripId: 'preview',
      userId: 'owner',
      mode: TransportationMode.scooter,
      notes: 'Scooter rental',
    ),
  ];
  Future<void> edit([TransportationModel? existing]) async {
    final c = TransportationEditorController(
      existing: existing,
      tripId: 'preview',
      userId: 'owner',
      displayName: 'Randy',
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      builder:
          (_) => TransportationEditor(
            controller: c,
            onSave: (entry) async {
              setState(() {
                final i = entries.indexWhere((value) => value.id == entry.id);
                if (i < 0) {
                  entries.add(entry);
                } else {
                  entries[i] = entry;
                }
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Transportation')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Getting there and getting around',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => edit(),
              icon: const Icon(Icons.add),
              label: const Text('Add Transportation'),
            ),
            const SizedBox(height: 16),
            for (final entry in entries)
              TransportationCard(
                entry: entry,
                canManage: true,
                onEdit: () => edit(entry),
                onDelete: () => setState(() => entries.remove(entry)),
              ),
          ],
        ),
      ),
    ),
  );
}

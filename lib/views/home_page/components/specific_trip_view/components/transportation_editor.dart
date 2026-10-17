import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/transportation_model.dart';
import '../controller/transportation_editor_controller.dart';

class TransportationEditor extends StatefulWidget {
  const TransportationEditor({
    super.key,
    required this.controller,
    required this.onSave,
  });

  /// Owned by this editor; disposed when the sheet leaves the widget tree.
  final TransportationEditorController controller;
  final Future<void> Function(TransportationModel entry) onSave;
  @override
  State<TransportationEditor> createState() => _TransportationEditorState();
}

class _TransportationEditorState extends State<TransportationEditor> {
  final form = GlobalKey<FormState>();
  TransportationEditorController get c => widget.controller;
  @override
  void dispose() {
    c.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
          maxWidth: 680,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: form,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.existing == null
                              ? 'Add Transportation'
                              : 'Edit Transportation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed:
                            c.saving.value
                                ? null
                                : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TransportationMode>(
                    initialValue: c.mode.value,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Mode'),
                    items:
                        TransportationMode.values
                            .map(
                              (mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(mode.label),
                              ),
                            )
                            .toList(),
                    onChanged:
                        c.saving.value
                            ? null
                            : (value) {
                              if (value != null) c.mode.value = value;
                            },
                  ),
                  const SizedBox(height: 16),
                  _dateFields('Departure', c.departure),
                  const SizedBox(height: 16),
                  _dateFields('Arrival', c.arrival),
                  _field(
                    'Notes (optional)',
                    c.notes,
                    4000,
                    lines: 5,
                    hint:
                        'Add your route, provider, booking details, or who’s traveling.',
                  ),
                  if (c.error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        c.error.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: c.saving.value ? null : _save,
                    child: Text(
                      c.saving.value ? 'Saving…' : 'Save Transportation',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    int max, {
    String? hint,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      enabled: !c.saving.value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) =>
              (value?.length ?? 0) > max
                  ? 'Use $max characters or fewer.'
                  : null,
    ),
  );

  Widget _dateFields(String title, TransportationDateController date) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('$title (optional)', style: Theme.of(context).textTheme.titleMedium),
      TextFormField(
        controller: date.date,
        readOnly: true,
        enabled: !c.saving.value,
        decoration: InputDecoration(
          labelText: 'Date',
          hintText: 'Not scheduled',
          suffixIcon: Wrap(
            children: [
              IconButton(
                tooltip: 'Choose $title date',
                icon: const Icon(Icons.calendar_today),
                onPressed:
                    c.saving.value
                        ? null
                        : () async {
                          final chosen = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(date.date.text) ??
                                DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (chosen != null && mounted) {
                            setState(() {
                              date.date.text =
                                  '${chosen.year.toString().padLeft(4, '0')}-${chosen.month.toString().padLeft(2, '0')}-${chosen.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
              ),
              IconButton(
                tooltip: 'Clear $title schedule',
                onPressed:
                    c.saving.value
                        ? null
                        : () => setState(() {
                          date.date.clear();
                          date.time.clear();
                        }),
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
        ),
      ),
      if (date.date.text.isNotEmpty) ...[
        TextFormField(
          controller: date.time,
          readOnly: true,
          enabled: !c.saving.value,
          decoration: InputDecoration(
            labelText: 'Local time (optional)',
            hintText: 'Date only',
            suffixIcon: Wrap(
              children: [
                IconButton(
                  tooltip: 'Choose $title time',
                  icon: const Icon(Icons.schedule),
                  onPressed:
                      c.saving.value
                          ? null
                          : () async {
                            final parts = date.time.text.split(':');
                            final chosen = await showTimePicker(
                              context: context,
                              initialTime:
                                  parts.length == 2
                                      ? TimeOfDay(
                                        hour: int.parse(parts[0]),
                                        minute: int.parse(parts[1]),
                                      )
                                      : const TimeOfDay(hour: 12, minute: 0),
                            );
                            if (chosen != null && mounted) {
                              setState(() {
                                date.time.text =
                                    '${chosen.hour.toString().padLeft(2, '0')}:${chosen.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                ),
                IconButton(
                  tooltip: 'Clear $title time',
                  onPressed:
                      c.saving.value
                          ? null
                          : () => setState(() {
                            date.time.clear();
                          }),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  );

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    c.error.value = '';
    try {
      final entry = c.buildEntry();
      c.saving.value = true;
      await widget.onSave(entry);
      if (mounted) Navigator.pop(context);
    } on FormatException catch (error) {
      if (mounted) c.error.value = error.message;
    } catch (_) {
      if (mounted) {
        c.error.value =
            'Could not save transportation. Check your connection and trip access, then retry.';
      }
    } finally {
      if (mounted) c.saving.value = false;
    }
  }
}

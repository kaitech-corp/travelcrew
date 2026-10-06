import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crew/services/trip_invitation_service.dart';

class InviteTravelersDialog extends StatefulWidget {
  const InviteTravelersDialog({
    super.key,
    required this.search,
    required this.send,
    required this.sendEmail,
  });
  final Future<List<TripInviteUser>> Function(String query) search;
  final Future<void> Function(String userId, String requestId) send;
  final Future<bool> Function(String email) sendEmail;

  @override
  State<InviteTravelersDialog> createState() => _InviteTravelersDialogState();
}

class _InviteTravelersDialogState extends State<InviteTravelersDialog> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _email = TextEditingController();
  final _attempts = <String, String>{};
  final _sent = <String>{};
  Timer? _debounce;
  int _generation = 0;
  bool _emailMode = false;
  bool _loading = false;
  bool _hasSearched = false;
  String? _sending;
  String? _error;
  String? _message;
  List<TripInviteUser> _users = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _searchFocus.dispose();
    _email.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    _debounce?.cancel();
    final generation = ++_generation;
    final query = value.trim();
    setState(() {
      _users = [];
      _error = null;
      _message = null;
      _loading = false;
      _hasSearched = false;
    });
    if (query.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted || generation != _generation) return;
      setState(() => _loading = true);
      try {
        final users = await widget.search(query);
        if (mounted && generation == _generation) {
          setState(() {
            _users = users;
            _loading = false;
            _hasSearched = true;
          });
        }
      } catch (error) {
        if (mounted && generation == _generation) {
          setState(() {
            _error = TripInvitationService.errorMessage(error);
            _loading = false;
          });
        }
      }
    });
  }

  void _setEmailMode(bool value) {
    _debounce?.cancel();
    ++_generation;
    setState(() {
      _emailMode = value;
      _loading = false;
      _error = null;
      _message = null;
    });
    if (!value) _searchChanged(_search.text);
  }

  Future<void> _invite(TripInviteUser user) async {
    if (_sending != null) return;
    setState(() {
      _sending = user.uid;
      _error = null;
      _message = null;
    });
    try {
      // Reuse this ID after network failures so retries cannot duplicate an invite.
      await widget.send(
        user.uid,
        _attempts.putIfAbsent(user.uid, () => const Uuid().v4()),
      );
      if (mounted) {
        setState(() {
          _sent.add(user.uid);
          _message = 'Invitation sent to ${user.displayName}.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = TripInvitationService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _sending = null);
    }
  }

  Future<void> _sendEmail() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_sending != null) return;
    setState(() {
      _sending = 'email';
      _error = null;
      _message = null;
    });
    try {
      final sent = await widget.sendEmail(email);
      if (mounted) {
        setState(() {
          if (sent) {
            _message = 'Email invitation queued for $email.';
            _email.clear();
          } else {
            _error = 'Could not send the email invitation. Please try again.';
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = TripInvitationService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _sending = null);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _sending == null,
    child: AlertDialog(
      scrollable: true,
      title: const Text('Invite travelers'),
      content: SizedBox(
        width: 440,
        height: math.min(440, MediaQuery.sizeOf(context).height * .55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Travel Crew users'),
                  selected: !_emailMode,
                  onSelected:
                      _sending != null ? null : (_) => _setEmailMode(false),
                ),
                ChoiceChip(
                  label: const Text('Email'),
                  selected: _emailMode,
                  onSelected:
                      _sending != null ? null : (_) => _setEmailMode(true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(liveRegion: true, child: Text(_message!)),
              ),
            if (_emailMode)
              Expanded(
                child: ListView(
                  children: [
                    const Text('Invite someone by email.'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      enabled: _sending == null,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendEmail(),
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _sending == null ? _sendEmail : null,
                      child: Text(
                        _sending == 'email' ? 'Sending…' : 'Send email invite',
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              TextField(
                // Status messages can change this child's position. Keep its
                // editing state, selection and keyboard connection intact.
                key: const ValueKey('traveler-search-field'),
                controller: _search,
                focusNode: _searchFocus,
                onChanged: _searchChanged,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: 'Search travelers',
                  hintText: 'Name or username',
                  counterText: '',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _search.text.isEmpty
                          ? null
                          : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              _searchChanged('');
                              _searchFocus.requestFocus();
                            },
                          ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Search by the beginning of a display name. Invitations appear in their Inbox.',
              ),
              const SizedBox(height: 8),
              if (_loading) const LinearProgressIndicator(),
              Expanded(
                child:
                    _users.isEmpty
                        ? Center(
                          child: Text(
                            _loading
                                ? 'Searching…'
                                : _search.text.trim().length < 2
                                ? 'Enter at least 2 characters.'
                                : _hasSearched && _error == null
                                ? 'No travelers found. Try another name.'
                                : '',
                          ),
                        )
                        : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            final invited =
                                _sent.contains(user.uid) ||
                                user.status == 'invited';
                            final member = user.status == 'member';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(user.displayName),
                              subtitle:
                                  user.hometown.isEmpty
                                      ? null
                                      : Text(user.hometown),
                              trailing: TextButton(
                                onPressed:
                                    invited || member || _sending != null
                                        ? null
                                        : () => _invite(user),
                                child: Text(
                                  member
                                      ? 'In crew'
                                      : invited
                                      ? 'Invited'
                                      : _sending == user.uid
                                      ? 'Sending…'
                                      : 'Invite',
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _sending == null ? () => Navigator.of(context).pop() : null,
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

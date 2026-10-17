import 'package:flutter/material.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';

class TripIdentity extends StatefulWidget {
  const TripIdentity({
    super.key,
    required this.ownerId,
    required this.isPrivate,
    this.ownerName,
  });
  final String ownerId;
  final String? ownerName;
  final bool isPrivate;

  @override
  State<TripIdentity> createState() => _TripIdentityState();
}

class _TripIdentityState extends State<TripIdentity> {
  Future<PublicUserModel?>? _owner;

  @override
  void initState() {
    super.initState();
    _loadOwner();
  }

  @override
  void didUpdateWidget(TripIdentity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId ||
        oldWidget.ownerName != widget.ownerName) {
      _loadOwner();
    }
  }

  void _loadOwner() {
    _owner =
        widget.ownerId.isNotEmpty && (widget.ownerName?.trim().isEmpty ?? true)
            ? AuthService.getUserPublicProfile(userId: widget.ownerId)
            : null;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<PublicUserModel?>(
    future: _owner,
    builder: (context, snapshot) {
      final name =
          widget.ownerName?.trim().isNotEmpty == true
              ? widget.ownerName!
              : snapshot.data?.displayName;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Created by ${name?.trim().isNotEmpty == true
                        ? name
                        : snapshot.connectionState == ConnectionState.waiting
                        ? '…'
                        : 'Unavailable'}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                widget.isPrivate ? Icons.lock_outline : Icons.public,
                size: 18,
              ),
              label: Text(widget.isPrivate ? 'Private trip' : 'Public trip'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    },
  );
}

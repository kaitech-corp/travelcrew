import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/lodging_model.dart';
import 'package:travel_crew/services/lodging_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import '../controller/specific_trip_view_controller.dart';

class LodgingTab extends StatefulWidget {
  const LodgingTab({super.key, required this.controller});
  final SpecificTripViewController controller;

  @override
  State<LodgingTab> createState() => _LodgingTabState();
}

class _LodgingTabState extends State<LodgingTab> {
  String? _tripId;
  Stream<List<LodgingModel>>? _options;

  @override
  Widget build(BuildContext context) {
    final trip = widget.controller.tripModel.value!;
    if (_tripId != trip.id) {
      _tripId = trip.id;
      _options = LodgingService.watch(trip.id);
    }
    final legacy = LodgingModel.fromTrip(trip);
    return StreamBuilder<List<LodgingModel>>(
      stream: _options,
      builder: (context, snapshot) {
        final options = [if (legacy.hasDetails) legacy, ...?snapshot.data];
        return ExpansionTile(
          key: ValueKey('${trip.id}:${options.isNotEmpty}'),
          initiallyExpanded: options.isNotEmpty,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          backgroundColor: AppColors.kLightGreyColor,
          collapsedBackgroundColor: AppColors.kLightGreyColor,
          title: Text(
            options.isEmpty
                ? 'Lodging options'
                : 'Lodging options (${options.length})',
          ),
          subtitle:
              options.isEmpty
                  ? Text(
                    snapshot.hasError
                        ? 'Unable to load lodging'
                        : snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading…'
                        : 'No lodging added yet',
                  )
                  : null,
          children: [
            if (snapshot.hasError)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Unable to load all lodging options. Reopen the trip to retry.',
                ),
              ),
            if (options.isEmpty && !snapshot.hasError)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Use + to add a place to stay.'),
              ),
            for (final option in options)
              _LodgingCard(
                key: ValueKey('${trip.id}:${option.id}'),
                tripId: trip.id,
                option: option,
                canEdit:
                    GlobalVariables.currentUid == trip.createdBy ||
                    GlobalVariables.currentUid == option.createdBy,
              ),
          ],
        );
      },
    );
  }
}

class _LodgingCard extends StatefulWidget {
  const _LodgingCard({
    super.key,
    required this.tripId,
    required this.option,
    required this.canEdit,
  });
  final String tripId;
  final LodgingModel option;
  final bool canEdit;

  @override
  State<_LodgingCard> createState() => _LodgingCardState();
}

class _LodgingCardState extends State<_LodgingCard> {
  late final _likes = LodgingService.watchLikes(
    widget.tripId,
    widget.option.id,
  );
  bool _savingLike = false;

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hotel_outlined, color: AppColors.kPrimaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  option.hotelName.trim().isEmpty
                      ? 'Place to stay'
                      : option.hotelName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.canEdit)
                IconButton(
                  tooltip: 'Edit lodging',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed:
                      () => Get.toNamed(
                        kAddLodgingScreenRoute,
                        arguments: option,
                      ),
                ),
            ],
          ),
          if (option.lodgingType.trim().isNotEmpty) Text(option.lodgingType),
          if (option.hotelAddress.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(option.hotelAddress),
            ),
          if (option.checkInDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Check-in: ${DateFormat('MMM d, yyyy · h:mm a').format(option.checkInDate!)}',
              ),
            ),
          if (option.checkOutDate != null)
            Text(
              'Check-out: ${DateFormat('MMM d, yyyy · h:mm a').format(option.checkOutDate!)}',
            ),
          if (option.expensePerNight != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '\$${option.expensePerNight!.toStringAsFixed(2)} / night',
              ),
            ),
          StreamBuilder<Set<String>>(
            stream: _likes,
            builder: (context, snapshot) {
              final uid = GlobalVariables.currentUid;
              final likes = snapshot.data ?? {};
              final liked = likes.contains(uid);
              return TextButton.icon(
                onPressed:
                    _savingLike ||
                            !snapshot.hasData ||
                            snapshot.hasError ||
                            uid.isEmpty
                        ? null
                        : () async {
                          setState(() => _savingLike = true);
                          try {
                            await LodgingService.setLiked(
                              widget.tripId,
                              option.id,
                              uid,
                              !liked,
                            );
                          } catch (_) {
                            showCustomSnackBar(
                              content:
                                  'Unable to update like. Please try again.',
                            );
                          } finally {
                            if (mounted) setState(() => _savingLike = false);
                          }
                        },
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  snapshot.hasError
                      ? 'Likes unavailable'
                      : '${likes.length} ${likes.length == 1 ? 'like' : 'likes'}',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

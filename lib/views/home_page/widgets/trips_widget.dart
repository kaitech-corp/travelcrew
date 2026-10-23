import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

class TripsWidget extends StatelessWidget {
  const TripsWidget({
    super.key,
    this.tripModel,
    this.destination = 'Bali',
    required this.images,
    this.country = 'Indonesia',
    this.imageUrl = '',
    this.startDate = '12 May',
    this.endDate = '20 May',
    this.memberAvatars = const [AppImages.kMember1Icon, AppImages.kMember2Icon],
    this.additionalMembers = 4,
    this.daysToGo = 7,
    this.tripTimingLabel,
    this.onTap,
  });
  final String destination;
  final List<String> images;
  final String country;
  final String imageUrl;
  final TripModel? tripModel;
  final String startDate;
  final String endDate;
  final List<String> memberAvatars;
  final int additionalMembers;
  final int daysToGo;
  final String? tripTimingLabel;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: 3.w, right: 5.w, bottom: 6.h, top: 6.h),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 0.91,
              strokeAlign: BorderSide.strokeAlignOutside,
              color: Color(0xFFE7E7E7),
            ),
            borderRadius: BorderRadius.circular(21.90),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTripImage(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: _buildTripDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: AnyImageView(
        url: images.isNotEmpty ? images.first : '',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorFit: BoxFit.cover,
        errorImage: AppImages.kDefaultTripImage,
      ),
    );
  }

  Widget _buildTripDetails() {
    final members = tripModel?.joindUsersList ?? [];
    final visibleAvatars =
        members.take(3).map((member) => member.profileImage ?? '').toList();
    final metadataStyle = AppStyles.labelTextStyle().copyWith(
      fontSize: AppStyles.fontSize14,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
      height: 1.2,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tripModel?.title ?? destination,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.labelTextStyle().copyWith(
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.black54,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: metadataStyle,
              ),
            ),
            if (members.isNotEmpty) ...[
              const SizedBox(width: 8),
              buildMemberAvatars(
                memberAvatars: visibleAvatars,
                additionalMembers: members.length > 3 ? members.length - 3 : 0,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 4),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  TextSpan(text: '$startDate – $endDate'),
                ],
              ),
              style: metadataStyle,
            ),
            Text(
              tripTimingLabel ?? 'in ${daysToGo}d.',
              style: metadataStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

Widget buildMemberAvatars({
  required List<String> memberAvatars,
  int additionalMembers = 0,
}) {
  const diameter = 24.0;
  const step = 16.0;
  final visible = memberAvatars.take(3).toList();
  final overflow =
      (additionalMembers > 0 ? additionalMembers : 0) +
      (memberAvatars.length > 3 ? memberAvatars.length - 3 : 0);
  final count = visible.length + (overflow > 0 ? 1 : 0);
  if (count == 0) return const SizedBox.shrink();

  return Semantics(
    label: '${visible.length + overflow} travelers',
    child: ExcludeSemantics(
      child: SizedBox(
        height: diameter,
        width: diameter + (count - 1) * step,
        child: Stack(
          children: [
            for (var index = 0; index < count; index++)
              PositionedDirectional(
                start: index * step,
                child: Container(
                  width: diameter,
                  height: diameter,
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child:
                      index < visible.length
                          ? AnyImageView(
                            isCircle: true,
                            url: visible[index],
                            containerBackgroundColor: const Color(0xFFF0F0F0),
                            errorWidget: const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.black45,
                            ),
                            fileType:
                                visible[index].startsWith('http')
                                    ? SourceType.network
                                    : SourceType.asset,
                          )
                          : Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF424242),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '+$overflow',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: Colors.white,
                                    fontSize: AppStyles.fontSize12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

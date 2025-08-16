import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class CustomPhoneField extends StatefulWidget {
  const CustomPhoneField({
    super.key,
    required this.onCountrySelected,
    required this.selectedCountry,
    required this.controller,
  });
  final ValueChanged<Country> onCountrySelected;
  final Country selectedCountry;
  final TextEditingController controller;
  @override
  CustomPhoneFieldState createState() => CustomPhoneFieldState();
}

class CustomPhoneFieldState extends State<CustomPhoneField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // show country code also
          Text(
            '+${widget.selectedCountry.phoneCode}',
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 16,
              color: AppColors().klabeltextcolor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Phone number',
                hintStyle: AppStyles.labelTextStyle().copyWith(
                  color: Colors.grey,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                onSelect: widget.onCountrySelected,
              );
            },
            child: Row(
              children: [
                Text(
                  widget.selectedCountry.flagEmoji,
                  style: AppStyles.labelTextStyle().copyWith(fontSize: 24),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_downward, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

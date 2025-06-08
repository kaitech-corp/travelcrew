import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/app_colors.dart';
import '../../services/session_services.dart';

class LoaderView extends StatelessWidget {
  const LoaderView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          (GlobalVariables.showLoader.value)
              ? SizedBox(
                height: double.infinity,
                width: double.infinity,
                // color: kBlackColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.kWhiteColor,
                        borderRadius: BorderRadiusDirectional.circular(10),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.kPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : const SizedBox.shrink(),
    );
  }
}

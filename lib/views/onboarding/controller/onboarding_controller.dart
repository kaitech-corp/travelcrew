import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/auth/login/login_screen.dart';

import '../../../models/onboarding_page_model.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final List<OnboardingPage> pages = [
    OnboardingPage(
      image: AppImages.kOnBoarding1Image,
      title: 'Plan Your Dream Trips Together',
      subtitle:
          'Create and share travel itineraries with friends in just a few taps.',
    ),
    OnboardingPage(
      image: AppImages.kOnBoarding2Image,
      title: 'Stay Connected with Your Travel Crew',
      subtitle: 'Chat, share updates, and keep everyone in the loop.',
    ),
    OnboardingPage(
      image: AppImages.kOnBoarding3Image,
      title: 'Explore and Join Exciting Trips',
      subtitle: 'Discover public trips or create your own private adventure.',
    ),
  ];
  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to the next screen (e.g., home or login)
      Get.offAll(() => const LoginScreen());
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

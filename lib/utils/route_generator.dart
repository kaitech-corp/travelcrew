import 'package:get/get.dart';
import 'package:travel_crew/views/all_expenses/all_expenses_screen.dart';
import 'package:travel_crew/views/auth/sign_up/profile_complete.dart';
import 'package:travel_crew/views/custom_widgets/date_range_picker/range_picker_dialogue.dart'
    show RangeCalendarDialog;
import 'package:travel_crew/views/expense/expense_screen.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/add_activity.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/specific_trip_view_screen.dart';
import 'package:travel_crew/views/messages/users/group_detail_screen.dart';
import 'package:travel_crew/views/profile/profile_screen.dart';

import '../views/auth/forgot_password/forgot_password_screen.dart';
import '../views/auth/login/login_screen.dart';
import '../views/auth/new_password/new_password_screen.dart';
import '../views/auth/sign_up/sign_up_screen.dart';
import '../views/create_trip/create_trip_screen.dart';
import '../views/expense/components/add_expense/add_expense_screen.dart';
import '../views/expense/components/settle_up/settle_up_screen.dart';
import '../views/home_page/home_page_screen.dart';
import '../views/main_view/main_view_screen.dart';
import '../views/messages/users/chat_screen.dart';
import '../views/my_trips/my_trips_screen.dart';
import '../views/notification/notification_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/profile/components/about/about_screen.dart';
import '../views/profile/components/change_password/change_password_screen.dart';
import '../views/profile/components/help_n_support/help_n_support_screen.dart';
import '../views/profile/components/privacy_policy/privacy_policy_screen.dart';
import '../views/splash_view/view/splash_screen.dart';
import 'app_strings.dart';
import 'screen_bindings.dart';

class RouteGenerator {
  static List<GetPage> getPages() {
    return [
      GetPage(
        name: kSplashScreenRoute,
        page: () => const SplashScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kOnboardingScreenRoute,
        page: () => const OnboardingScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kLoginScreenRoute,
        page: () => const LoginScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kForgotPasswordScreenRoute,
        page: () => const ForgotPasswordScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kProfileScreenRoute,
        page: () => const ProfileScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kHomePageScreenRoute,
        page: () => const HomePageScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kSpecificTripViewScreenRoute,
        page: () => const SpecificTripViewScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kMyTripsScreenRoute,
        page: () => const MyTripsScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kHelpNSupportScreenRoute,
        page: () => const HelpNSupportScreen(),
        binding: ScreenBindings(),
      ),
      
      GetPage(
        name: kMainViewScreenRoute,
        page: () => MainViewScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kCreateTripScreenRoute,
        page: () => CreateTripScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kNewPasswordScreenRoute,
        page: () => const NewPasswordScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kSignUpScreenRoute,
        page: () => const SignUpScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kChangePasswordScreenRoute,
        page: () => const ChangePasswordScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kPrivacyPolicyScreenRoute,
        page: () => const PrivacyPolicyScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kAddExpenseScreenRoute,
        page: () => const AddExpenseScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kExpenseScreenRoute,
        page: () => const ExpenseScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kSettleUpScreenRoute,
        page: () => const SettleUpScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kAboutScreenRoute,
        page: () => const AboutScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kGroupDetailScreenRoute,
        page: () => const GroupDetailScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kProfileSetUpScreenRoute,
        page: () => const ProfileSetupPage(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kDateRangePickerScreenRoute,
        page: () => const RangeCalendarDialog(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kMessagesScreenRoute,
        page: () => const MessagesScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kAddActivityScreenRoute,
        page: () => AddActivity(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kNotificationScreenRoute,
        page: () => const NotificationsScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        name: kAllExpensesScreenRoute,
        page: () => const AllExpensesScreen(),
        binding: ScreenBindings(),
      ),
    ];
  }
}

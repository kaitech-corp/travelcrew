import 'package:get/get.dart';
import 'package:travel_crew/views/all_expenses/controller/all_expense_cont.dart';
import 'package:travel_crew/views/import_trip/import_trip_controller.dart';
import 'package:travel_crew/views/auth/forgot_password/controller/forgot_password_controller.dart';
import 'package:travel_crew/views/auth/new_password/controller/new_password_controller.dart';
import 'package:travel_crew/views/auth/sign_up/controller/sign_up_controller.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/expense/controller/components/add_expense/controller/add_expense_controller.dart';
import 'package:travel_crew/views/expense/controller/components/settle_up/controller/settle_up_controller.dart';
import 'package:travel_crew/views/expense/controller/expense_conrtoller.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';
import 'package:travel_crew/views/main_view/controller/main_view_controller.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';
import 'package:travel_crew/views/onboarding/controller/onboarding_controller.dart';
import 'package:travel_crew/views/profile/components/about/controller/about_controller.dart';
import 'package:travel_crew/views/profile/components/connections/controller/connections_controller.dart';
import 'package:travel_crew/views/profile/components/change_password/controller/change_password_controller.dart';
import 'package:travel_crew/views/profile/components/help_n_support/controller/help_n_support_controller.dart';
import 'package:travel_crew/views/profile/components/privacy_policy/controller/privacy_policy_controller.dart';
import 'package:travel_crew/views/profile/controller/profle_controller.dart';

import '../views/auth/login/controller/login_controller.dart';
import '../views/custom_widgets/date_range_picker/controller/range_picker_controller.dart';
import '../views/messages/group/controller/group_controller.dart';
import '../views/notification/controller/notification_controller.dart';
import '../views/splash_view/controller/splash_controller.dart';

class ScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => OnboardingController());
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => ForgotPasswordController());
    // fenix: true keeps these alive / recreates them when used in the bottom nav
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => HelpNSupportController(), fenix: true);
    Get.lazyPut(() => GroupController(), fenix: true);
    // Get.lazyPut(() => OtpController());
    Get.lazyPut(() => NewPasswordController());
    Get.lazyPut(() => MainViewController(), fenix: true);
    Get.lazyPut(() => HomePageController(), fenix: true);
    Get.lazyPut(() => SpecificTripViewController(), fenix: true);
    Get.lazyPut(() => CreateTripController());
    Get.lazyPut(() => SignUpController());
    Get.lazyPut(() => MyTripsController(), fenix: true);
    Get.lazyPut(() => ChangePasswordController());
    Get.lazyPut(() => PrivacyPolicyController());
    Get.lazyPut(() => AboutController(), fenix: true);
    Get.lazyPut(() => AddExpenseController());
    Get.lazyPut(() => ExpenseController());
    Get.lazyPut(() => SettleUpController());
    Get.lazyPut(() => UsersController(), fenix: true);
    Get.lazyPut(() => RangePickerController());
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => AllExpensesController());
    Get.lazyPut(() => ImportTripController());
    Get.lazyPut(() => ConnectionsController(), fenix: true);
  }
}

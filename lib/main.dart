import 'package:flutter/material.dart';
import 'package:mobo_projects/core/designs/theme_data.dart';
import 'package:mobo_projects/features/onboarding/get_started_carousal.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_page.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_page.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';
import 'package:mobo_projects/features/add_service_fuel/add_service_fuel_log_page.dart';
import 'package:mobo_projects/features/add_service_fuel/add_service_fuel_log_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_page.dart';
import 'package:mobo_projects/features/drivers/drivers_details_page.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:mobo_projects/features/onboarding/splash_screen.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:mobo_projects/core/providers/logout_view_model.dart';
import 'package:mobo_projects/core/services/session_service.dart';
import 'package:mobo_projects/core/theme/theme_provider.dart';
import 'package:mobo_projects/features/company/providers/company_provider.dart';
import 'package:mobo_projects/features/login/pages/server_setup_screen.dart';
import 'package:mobo_projects/features/login/providers/login_provider.dart';
import 'package:mobo_projects/features/profile/providers/profile_provider.dart';
import 'package:mobo_projects/features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'features/dashboard/dashboard_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => FleetPermissionProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DriversPageProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
        ChangeNotifierProvider(create: (_) => ActivityPageProvider()),
        ChangeNotifierProvider(create: (_) => AddServiceFuelLogProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesDetailsProvider()),
        ChangeNotifierProvider(create: (_) => AddOdometerLogProvider()),
        ChangeNotifierProvider(create: (_) => AddContractsLogProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider<SessionService>.value(
          value: SessionService.instance,
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = CompanyProvider();

            /// Kick off initial load from server; will show loading in selector
            p.initialize();
            return p;
          },
        ),
      ],
      child: // const SingleButtonPage(),
          const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          themeMode: provider.themeMode,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
          routes: {
            '/driverDetails': (context) => Driverdetails(),
            '/addFuelLog': (context) => AddServiceFuelLogPage(),
            '/server_setup': (_) => const ServerSetupScreen(),
            '/home': (_) => const DashboardPage(),
            '/addOdometerLog': (_) => const AddOdometerLogPage(),
            '/addContractLog': (_) => const AddContractsLogPage(),
          },
        );
      },
    );
  }
}

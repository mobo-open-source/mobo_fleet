import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_page.dart';
import 'package:mobo_projects/features/company/providers/company_provider.dart';
import 'package:mobo_projects/features/module_check/module_check_dialog.dart';
import 'package:mobo_projects/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/widgets/loaders/loading_indicator.dart';
import 'features/login/pages/server_setup_screen.dart';
import 'features/login/pages/app_lock_screen.dart';
import 'core/services/session_service.dart';
import 'core/services/odoo_session_manager.dart';
import 'core/services/biometric_context_service.dart';
import 'core/routing/page_transition.dart';
import 'core/services/connectivity_service.dart';

class AppEntry extends StatefulWidget {
  final bool skipBiometric;

  const AppEntry({super.key, this.skipBiometric = false});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late Future<Map<String, dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();

    /// Start monitoring connectivity centrallya
    ConnectivityService.instance.startMonitoring();
    _initFuture = _checkAuthStatus();
  }

  Future<Map<String, dynamic>> _checkAuthStatus() async {
    await SessionService.instance.initialize();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedInPref = prefs.getBool('isLoggedIn') ?? false;

    bool sessionValid = false;
    if (isLoggedInPref) {
      sessionValid = await OdooSessionManager.isSessionValid();
    }

    final isLoggedIn = isLoggedInPref && sessionValid;
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (isLoggedIn) {
      sessionValid = await OdooSessionManager.isSessionValid();
      if (!sessionValid) {
      } else {
        /// Extra safeguard: ensure we can actually authenticate a client.
        /// If this fails due to temporary connectivity or server issues, DO NOT logout.
        /// Let the app proceed so the user can retry inside the app.
        try {
          final client = await OdooSessionManager.getClientEnsured();
          final sessionInfo = await client.callRPC(
            '/web/session/get_session_info',
            'call',
            {},
          );
          /// company_id is usually in: sessionInfo['user_companies']['current_company']
          final currentCompany = sessionInfo;
        } catch (e) {
          /// Intentionally do not clear session here.
        }
      }
    }

    /// If logged in and session is valid, check if Inventory (stock) module is installed
    bool inventoryInstalled = false;

    /// Force true for now
    if (isLoggedIn && sessionValid) {
      try {
        final client = await OdooSessionManager.getClientEnsured();
        final sessionInfo = await client.callRPC(
          '/web/session/get_session_info',
          'call',
          {},
        );
        final currentCompanyId =
            sessionInfo['user_companies']?['current_company'];

        if (currentCompanyId == null) {
          inventoryInstalled = true;

          /// ⬅️ IMPORTANT fallback
        } else {
          /// 2️⃣ Check module WITH correct company context
          final count = await client.callKw({
            'model': 'ir.module.module',
            'method': 'search_count',
            'args': [
              [
                ['name', '=', 'fleet'],
                ['state', '=', 'installed'],
              ],
            ],
            'kwargs': {},
          });

          inventoryInstalled = (count as num) > 0;
          if (inventoryInstalled) {

            try {
              final sessionService = SessionService.instance;
              final currentSession =
                  await OdooSessionManager.getCurrentSession();

              if (currentSession != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<CompanyProvider>().initialize();
                  context.read<ProfileProvider>().fetchUserProfile();
                });
                await sessionService.storeAccount(currentSession, currentSession.password,markAsCurrent: true);
              }
            } catch (e) {
            }
          }
        }
      } catch (e) {
        inventoryInstalled = false;

        /// Keep as false; the MissingInventoryScreen will allow retry
      }
    }

    return {
      'isLoggedIn': isLoggedIn,
      'biometricEnabled': biometricEnabled,
      'inventoryInstalled': inventoryInstalled,
    };
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const ServerSetupScreen();
        }

        final isLoggedIn = snapshot.data!['isLoggedIn'] as bool;
        final biometricEnabled = snapshot.data!['biometricEnabled'] as bool;
        final inventoryInstalled =
            snapshot.data!['inventoryInstalled'] as bool? ?? false;

        /// Check if biometric should be skipped
        final biometricContext = BiometricContextService();
        final shouldSkipBiometric =
            widget.skipBiometric || biometricContext.shouldSkipBiometric;

        /// Show biometric lock screen if enabled and logged in
        if (biometricEnabled &&
            isLoggedIn &&
            !shouldSkipBiometric &&
            inventoryInstalled) {
          return AppLockScreen(
            onAuthenticationSuccess: () {
              /// After biometric unlock, re-enter AppEntry (skipping biometric)
              /// so that startup checks (including inventory module check)
              /// can run and route either to HomeScaffold or MissingInventoryScreen.
              Navigator.pushReplacement(
                context,
                dynamicRoute(context, const AppEntry(skipBiometric: true)),
              );
            },
          );
        } else if (isLoggedIn) {
          /// If logged in but inventory not installed, show guidance screen

          if (!inventoryInstalled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const ModuleCheckDialog(),
              );
            });

            return ServerSetupScreen();

            /// 👇 Login screen stays in the background
            // return const BottomNavigationBarPage();
          }

          /// No biometric, go directly to app
          return const BottomNavigationBarPage();
        }

        /// Not logged in, show login screen
        return const ServerSetupScreen();
      },
    );
  }
}

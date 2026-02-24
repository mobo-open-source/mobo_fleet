import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_projects/features/activity/activity_page.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_page.dart';
import 'package:mobo_projects/features/drivers/drivers_page.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/features/vehicles/vehicles_page.dart';
import 'package:mobo_projects/core/routing/page_transition.dart';
import 'package:mobo_projects/features/company/providers/company_provider.dart';
import 'package:mobo_projects/features/company/widgets/company_selector_widget.dart';
import 'package:mobo_projects/features/profile/pages/profile_screen.dart';
import 'package:mobo_projects/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';

class BottomNavigationBarPage extends StatefulWidget {
  final int initialIndex;
  final int? activityTabIndex;
  final int? vehicleId;
  final bool isTest;

  const BottomNavigationBarPage({
    super.key,
    this.initialIndex = 0,
    this.vehicleId,
    this.activityTabIndex,
    this.isTest = false,
  });

  @override
  State<BottomNavigationBarPage> createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  late int _currentIndex;
  int? _vehicleId;
  int? _activityTabIndex;

  static const List<String> appBarTitles = [
    'Dashboard',
    'Vehicles',
    'Drivers',
    'Activity',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _vehicleId = widget.vehicleId;
    _activityTabIndex = widget.activityTabIndex;
    if (widget.isTest) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile();
    });
  }

  List<Widget> get screens => [
    DashboardPage(),
    VehiclesPage(),
    DriversPage(),
    ActivityPage(vehicleId: _vehicleId, activityTabIndex: _activityTabIndex),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index != 3) {
        _vehicleId = null;
        _activityTabIndex = null;
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Theme.of(context).scaffoldBackgroundColor;
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: scaffold,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          appBarTitles[_currentIndex],
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            letterSpacing: 0,
          ),
        ),
        actions: _buildProfileActions(context),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: SnakeNavigationBar.color(
        backgroundColor: isDarkTheme
            ? AllDesigns.greyShade900Color
            : AllDesigns.whiteColor,
        unselectedItemColor: isDarkTheme
            ? AllDesigns.grey50
            : AllDesigns.blackColor,
        selectedItemColor: isDarkTheme
            ? AllDesigns.whiteColor
            : AllDesigns.appColor,
        snakeViewColor: AllDesigns.appColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        snakeShape: SnakeShape.indicator,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedDashboardSquare02,
              size: 25,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedShippingTruck02,
              size: 25,
            ),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUserMultiple03,
              size: 25,
            ),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 25),
            label: 'Activity',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProfileActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      CompanySelectorWidget(
        onCompanyChanged: () async {
          if (!mounted) return;
          final provider = context.read<CompanyProvider>();
          final companyName =
              provider.selectedCompany?['name']?.toString() ?? 'company';
          await context.read<ProfileProvider>().fetchUserProfile(
            forceRefresh: true,
          );
          await context.read<BottomNavProvider>().refreshAll(context);
          CustomSnackbar.showSuccess(context, 'Switched to $companyName');
        },
      ),
      Container(
        margin: const EdgeInsets.only(right: 8),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final userAvatar = profileProvider.userAvatar;
            final isLoading = profileProvider.isLoading && userAvatar == null;

            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('avatar_loading'),
                        width: 32,
                        height: 32,
                        child: Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          highlightColor: isDark
                              ? Colors.grey[600]!
                              : Colors.grey[200]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        key: ValueKey(
                          userAvatar != null
                              ? 'avatar_with_image'
                              : 'avatar_placeholder',
                        ),
                        radius: 16,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        child: userAvatar != null
                            ? ClipOval(
                                child: Image.memory(
                                  userAvatar,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return HugeIcon(
                                      icon: HugeIcons.strokeRoundedUserCircle,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      size: 18,
                                    );
                                  },
                                ),
                              )
                            : CircleAvatar(
                                key: const ValueKey('avatar_placeholder'),
                                radius: 16,
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: ClipOval(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedUserCircle,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    size: 18,
                                  ),
                                ),
                              ),
                      ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  dynamicRoute(context, const ProfileScreen()),
                ).then((_) {
                  if (mounted) {
                    context.read<ProfileProvider>().fetchUserProfile(
                      forceRefresh: true,
                    );
                  }
                });
              },
            );
          },
        ),
      ),
    ];
  }
}

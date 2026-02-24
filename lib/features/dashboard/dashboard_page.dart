import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_view.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  final bool isTest;
  const DashboardPage({super.key, this.isTest = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<void> _onRefresh() async {
    await context.read<DashboardProvider>().refreshDashboard(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isTest) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fleetPerm = context.read<FleetPermissionProvider>();
      await fleetPerm.ensurePermissionChecked();
      if (!fleetPerm.canAccessFleet) return;
      final dashboardProvider = context.read<DashboardProvider>();
      if (dashboardProvider.modelFleetDashboardData == null) {
        await dashboardProvider.fetchDashboardNewData(context);
      }
      final session = await OdooSessionManager.getCurrentSession();
      if (session?.userId != null) {
        await dashboardProvider.fetchUserDetails(session!.userId!);
        dashboardProvider.setGreetings();
        dashboardProvider.safeNotify();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTest) {
      return _buildDashboardContent(context);
    }
    return FleetPermissionView(
      pageName: "Dashboard",
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 60,
        edgeOffset: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              if (!provider.isDashboardDataLoading &&
                  provider.modelFleetDashboardData == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.fetchDashboardNewData(context);
                });
              }
              if (provider.isDashboardDataLoading ||
                  provider.modelFleetDashboardData == null) {
                return dashboardShimmerWidget(context, isDarkTheme);
              }
              final data = provider.modelFleetDashboardData;
              if (provider.isDashboardDataLoading || data == null) {
                return dashboardShimmerWidget(context, isDarkTheme);
              }

              if (data.quickStats == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Lottie.asset(
                          'assets/lotties/empty ghost.json',
                          repeat: true,
                          animate: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildText(
                        text: "No Records Available",
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                );
              }

              final quickStats = data.quickStats;
              final costOverview = data.costOverview;
              final upcoming = data.upcoming;

              return RefreshIndicator(
                onRefresh: _onRefresh,
                displacement: 60,
                edgeOffset: 10,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildWelcomeCard(
                        context: context,
                        wishText:
                            "Good ${provider.greetings} ${provider.userName}!",
                        wishTextFontSize: 16,
                        subText: "Manage Your Fleet Operation Efficiently",
                        subTextColor: AppTheme.secondaryColor,
                        subTextFontSize: 15,
                        provider: provider,
                        isDarkTheme: isDarkTheme,
                      ),
                      const SizedBox(height: 15),
                      buildText(
                        text: "Quick Stats",
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 10,
                                left: 8,
                              ),
                              child: buildWidgetQuickStats(
                                isDarkTheme: isDarkTheme,
                                context: context,
                                count: quickStats?.totalVehicles.toInt() ?? 0,
                                headText: "Total vehicles",
                                subtext: "Count of Total vehicles",
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 15),

                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: buildWidgetQuickStats(
                                isDarkTheme: isDarkTheme,

                                context: context,
                                count: quickStats?.activeDrivers.toInt() ?? 0,
                                headText: "Active Drivers",
                                subtext: "Count of Active Drivers",
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 15),

                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: buildWidgetQuickStats(
                                isDarkTheme: isDarkTheme,
                                context: context,
                                count:
                                    quickStats?.vehiclesInService.toInt() ?? 0,
                                headText: "Vehicle Service",
                                subtext: "Vehicles in service",
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                right: 8,
                              ),
                              child: buildWidgetQuickStats(
                                isDarkTheme: isDarkTheme,

                                context: context,
                                count: quickStats?.vehiclesInUse.toInt() ?? 0,
                                headText: "Vehicle (in use)",
                                subtext: "Vehicles currently in use",
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        text: "Cost Overview",
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: buildWidgetCostOverview(
                              isDarkTheme: isDarkTheme,

                              context: context,
                              costOverviewCount:
                                  costOverview?.monthlyFleetCost.toDouble() ??
                                  0.00,
                              costOverviewMainText: "Monthly Fleet cost",
                              costOverviewSubText: "Monthly cost of fleet",
                              color: Colors.green,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: buildWidgetCostOverview(
                              isDarkTheme: isDarkTheme,

                              context: context,
                              costOverviewCount:
                                  costOverview?.fuelCost.toDouble() ?? 0.00,
                              costOverviewMainText: "Fuel Cost",
                              costOverviewSubText: "Fuel expenses",
                              color: Colors.blue,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 2,
                            child: buildWidgetCostOverview(
                              isDarkTheme: isDarkTheme,
                              context: context,
                              costOverviewCount:
                                  costOverview?.serviceAndRepairCost
                                      .toDouble() ??
                                  0.00,
                              costOverviewMainText: "Service & Repair",
                              costOverviewSubText: "Maintenance expenses",
                              color: Colors.orange,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildText(
                        text: "Upcoming",
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                      const SizedBox(height: 10),
                      StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: buildWidgetUpcoming(
                              isDarkTheme: isDarkTheme,
                              context: context,
                              upcomingCount:
                                  upcoming?.contractRenewal.toDouble() ?? 0.00,
                              upcomingMainText: "Contract renewals",
                              upcomingSubText: "Contracts to renew",
                              color: Colors.green,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 1,
                            child: buildWidgetUpcoming(
                              isDarkTheme: isDarkTheme,
                              context: context,
                              upcomingCount:
                                  upcoming?.serviceDues.toDouble() ?? 0.00,
                              upcomingMainText: "Services due",
                              upcomingSubText: "Pending services",
                              color: Colors.blue,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                          StaggeredGridTile.fit(
                            crossAxisCellCount: 2,
                            child: buildWidgetUpcoming(
                              isDarkTheme: isDarkTheme,
                              context: context,
                              upcomingCount:
                                  upcoming?.insuranceExpiry.toDouble() ?? 0.00,
                              upcomingMainText: "Insurance expiry",
                              upcomingSubText: "Insurance expiration",
                              color: Colors.orange,
                              icon: HugeIcons.strokeRoundedProfile,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget Text
Widget buildText({
  required String? text,
  required double? fontSize,
  required FontWeight fontWeight,
  Color? color,
}) {
  return Text(
    text ?? "",
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
      color: color,
    ),
    overflow: TextOverflow.ellipsis,
  );
}

/// Widget Welcome Card
Widget buildWelcomeCard({
  required String? wishText,
  required double? wishTextFontSize,
  required String? subText,
  required Color subTextColor,
  required BuildContext context,
  required double? subTextFontSize,
  required DashboardProvider provider,
  required bool isDarkTheme,
}) {
  final size = MediaQuery.of(context).size;

  return LayoutBuilder(
    builder: (context, constraints) {
      return Card(
        key: const Key('welcome_card'),
        color: AllDesigns.appColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
            horizontal: size.width * 0.04,
          ),
          child: Row(
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText(
                        text: wishText,
                        fontSize: wishTextFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(height: size.height * 0.005),
                      buildText(
                        text: subText,
                        fontSize: subTextFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AllDesigns.whiteColor.withOpacity(.7),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  key: const Key('welcome_avatar'),
                  radius: 27,
                  backgroundColor: Colors.white.withOpacity(.3),
                  child:
                      provider.uint8list != null &&
                          provider.uint8list!.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            provider.uint8list!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return provider.iconHandle(
                                color: AllDesigns.whiteColor,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Widget QuickStats
Widget buildWidgetQuickStats({
  required BuildContext context,
  required String? headText,
  required int count,
  required String? subtext,
  required Color? color,
  required bool isDarkTheme,
}) {
  final size = MediaQuery.of(context).size;
  return Container(
    key: const Key('test_case_quick_stats_container_key'),
    width: size.width * 0.7,
    decoration: BoxDecoration(
      color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkTheme ? 0.25 : 0.12),
          offset: const Offset(0, 3),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildText(
            text: headText.toString(),
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade600Color,
          ),
          const SizedBox(height: 10),
          buildText(
            text: count.toString(),
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
          const SizedBox(height: 10),
          buildText(
            text: subtext.toString(),
            fontWeight: FontWeight.normal,
            fontSize: 12,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade500Color,
          ),
          const SizedBox(height: 10),
          Container(
            height: 3,
            width: size.width * 0.10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Widget Cost Overview
Widget buildWidgetCostOverview({
  required BuildContext context,
  required double? costOverviewCount,
  required String? costOverviewMainText,
  required String? costOverviewSubText,
  required Color? color,
  required List<List<dynamic>> icon,
  required bool isDarkTheme,
}) {
  return Container(
    key: const Key('test_case_cost_overview_container_key'),
    decoration: BoxDecoration(
      color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.whiteColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: isDarkTheme ? AllDesigns.black12 : color!.withOpacity(.1),
          offset: const Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: buildText(
                    text: costOverviewCount.toString(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                buildText(
                  text: costOverviewMainText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                ),
                const SizedBox(height: 5),
                buildText(
                  text: costOverviewSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade500Color,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: color?.withOpacity(0.1) ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: HugeIcon(icon: icon, color: color, size: 20),
          ),
        ],
      ),
    ),
  );
}

/// Widget Upcoming
Widget buildWidgetUpcoming({
  required BuildContext context,
  required double? upcomingCount,
  required String? upcomingMainText,
  required String? upcomingSubText,
  required Color? color,
  required List<List<dynamic>> icon,
  required bool isDarkTheme,
}) {
  return Container(
    key: const Key('test_case_upcoming_container_key'),
    decoration: BoxDecoration(
      color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.whiteColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: isDarkTheme ? AllDesigns.black12 : color!.withOpacity(0.08),
          offset: const Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: buildText(
                    text: upcomingCount.toString(),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),

                buildText(
                  text: upcomingMainText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                ),
                const SizedBox(height: 5),

                buildText(
                  text: upcomingSubText,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade500Color,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: color?.withOpacity(0.1) ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: HugeIcon(icon: icon, color: color, size: 20),
          ),
        ],
      ),
    ),
  );
}

/// Widget Dashboard Shimmer
Widget dashboardShimmerWidget(BuildContext context, bool isDarkTheme) {
  final size = MediaQuery.of(context).size;
  final baseColor = isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade300;
  final highlightColor = isDarkTheme
      ? AllDesigns.greyShade800Color
      : AllDesigns.greyShade100Color;
  final boxColor = isDarkTheme ? Colors.grey.shade800 : Colors.white;
  return Shimmer.fromColors(
    key: const Key('test_case_dashboard_shimmer_check'),
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(height: size.height * 0.14, color: boxColor),

          const SizedBox(height: 20),

          _title(color: boxColor),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: _box(
                    width: size.width * 0.7,
                    height: 120,
                    color: boxColor,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          _title(color: boxColor),
          const SizedBox(height: 10),

          _box(height: 100, color: boxColor),
          const SizedBox(height: 10),
          _box(height: 100, color: boxColor),

          const SizedBox(height: 20),
          _title(color: boxColor),
          const SizedBox(height: 10),

          _box(height: 100, color: boxColor),
          const SizedBox(height: 10),
          _box(height: 100, color: boxColor),
        ],
      ),
    ),
  );
}

Widget _box({
  double height = 20,
  double width = double.infinity,
  required Color color,
}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

Widget _title({required Color color}) {
  return Container(
    height: 20,
    width: 150,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

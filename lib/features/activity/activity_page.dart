import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/features/activity/activity_page_filter_bottom_sheet.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_view.dart';
import 'package:mobo_projects/features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ActivityPage extends StatefulWidget {
  /// test added start
  final bool skipPermissionGate;

  /// test added start
  final int? vehicleId;
  final int? activityTabIndex;
  const ActivityPage({
    super.key,
    this.vehicleId,
    this.activityTabIndex,
    this.skipPermissionGate = false,
  });

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// test case added
      if (!widget.skipPermissionGate) {
        final perm = context.read<FleetPermissionProvider>();
        if (!perm.canAccessFleet) return;
      }

      /// test case ended
      final provider = Provider.of<ActivityPageProvider>(
        context,
        listen: false,
      );
      provider.setVehicleId(widget.vehicleId);
      switch (widget.activityTabIndex) {
        case ActivityTabs.odometer:
          provider.setSelectedActivityLog(1);
          break;

        case ActivityTabs.service:
          provider.setSelectedActivityLog(2);
          break;

        case ActivityTabs.contract:
          provider.setSelectedActivityLog(3);
          break;

        default:
          provider.setSelectedActivityLog(0);
      }
      provider.fetchUserDetails();
      provider.onRefresh();
      provider.markInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skipPermissionGate) {
      ///  tests
      return _buildPageContent(context);
    }

    ///  production
    return FleetPermissionView(
      pageName: "Activity",
      child: _buildPageContent(context),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ActivityPageProvider>(
      builder: (context, provider, index) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ///  Switching Activity (logs)
                          buildWidgetActivityLog(
                            context: context,
                            headText: "Fuel logs",
                            index: 0,
                            isDarkTheme: isDarkTheme,
                          ),
                          buildWidgetActivityLog(
                            context: context,
                            headText: "Odometer logs",
                            index: 1,
                            isDarkTheme: isDarkTheme,
                          ),
                          buildWidgetActivityLog(
                            context: context,
                            headText: "Service logs",
                            index: 2,
                            isDarkTheme: isDarkTheme,
                          ),
                          buildWidgetActivityLog(
                            context: context,
                            headText: "Contracts logs",
                            index: 3,
                            isDarkTheme: isDarkTheme,
                          ),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: buildSearchBar(
                  onTap:
                      provider.selectedActivityIndex == 2 ||
                          provider.selectedActivityIndex == 3
                      ? () {
                          /// Filter bottomSheet for respective indexed logs
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: isDarkTheme
                                ? AllDesigns.greyShade800Color
                                : Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => ActivityPageFilterBottomSheet(
                              isDarkTheme: isDarkTheme,
                              activityIndex: provider.selectedActivityIndex,
                            ),
                          );
                        }
                      : null,
                  context: context,
                  leftIcon:
                      provider.selectedActivityIndex == 2 ||
                          provider.selectedActivityIndex == 3
                      ? HugeIcons.strokeRoundedFilterHorizontal
                      : HugeIcons.strokeRoundedSearch01,
                  rightIcon: HugeIcons.strokeRoundedCancel01,
                  iconColor: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade800Color,
                  iconSize: 18,
                  controller: provider.searchActivityText,
                  provider: provider,
                  mainWidgetColor: AllDesigns.appColor,
                  isDarkTheme: isDarkTheme,
                  hintText: provider.searchHintText,
                ),
              ),
              const SizedBox(height: 10),

              /// Refresh indicator for selected Index
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.onRefresh(),
                  displacement: 60,
                  edgeOffset: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: _buildSelectedContent(
                      provider.selectedActivityIndex,
                      isDarkTheme,
                      provider,
                    ),
                  ),
                ),
              ),
            ],
          ),

          /// Floating Action Button
          floatingActionButton: Consumer<FleetPermissionProvider>(
            builder: (context, perm, _) {
              if (!perm.isFleetAdmin) {
                return const SizedBox.shrink();
              }
              return _buildSpeedDial(context, isDarkTheme);
            },
          ),
        );
      },
    );
  }

  /// Widget Search Bar
  Widget buildSearchBar({
    List<List<dynamic>>? leftIcon,
    required List<List<dynamic>> rightIcon,
    required double iconSize,
    required Color iconColor,
    required TextEditingController controller,
    required BuildContext context,
    required ActivityPageProvider provider,
    required Color mainWidgetColor,
    required bool isDarkTheme,
    required String hintText,
    required void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        provider.updateSearch(value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkTheme ? AllDesigns.greyShade800Color : Colors.white,
        prefixIcon: Material(
          color: Colors.transparent,
          child: InkWell(
            key:
                provider.selectedActivityIndex == 2 ||
                    provider.selectedActivityIndex == 3
                ? const Key('activity_filter_select')
                : null,
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HugeIcon(
                icon: leftIcon?.toList() ?? [],
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
        suffixIcon: provider.searchActivityText.text.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('activity_clear_search'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    controller.clear();
                    provider.clearSearch();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HugeIcon(
                      icon: rightIcon,
                      size: iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),

        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade700Color,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Widget Text
  Widget buildText({
    required String? text,
    required double? fontSize,
    required Color color,
    required FontWeight fontWeight,
    required double? letterSpacing,
  }) {
    return Text(
      text ?? "",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }

  /// widget Switching Activity (logs)
  Widget buildWidgetActivityLog({
    required BuildContext context,
    required String? headText,
    required int index,
    required bool isDarkTheme,
  }) {
    final provider = Provider.of<ActivityPageProvider>(context);
    final bool isSelected = provider.selectedActivityIndex == index;

    return InkWell(
      key: Key('activity_tab_$index'),
      onTap: () {
        provider.setSelectedActivityLog(index);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AllDesigns.blackColor : AllDesigns.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AllDesigns.blackColor
                  : AllDesigns.greyShade300Color,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Center(
            child: Text(
              headText ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AllDesigns.white : AllDesigns.blackColor,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// widget Switching Activity Logs view
  Widget _buildSelectedContent(
    int index,
    bool isDarkTheme,
    ActivityPageProvider provider,
  ) {
    switch (index) {
      case 0:
        return _buildActivityFuelLogs(isDarkTheme: isDarkTheme);
      case 1:
        return _buildActivityOdometerLogs(isDarkTheme: isDarkTheme);
      case 2:
        return _buildActivityServiceLogs(isDarkTheme: isDarkTheme);
      case 3:
        return _buildActivityContractsLogs(isDarkTheme: isDarkTheme);
      default:
        return Container();
    }
  }

  /// widget Activity Fuel Log
  Widget _buildActivityFuelLogs({required bool isDarkTheme}) {
    return Consumer<ActivityPageProvider>(
      builder: (context, provider, child) {
        if (provider.modelActivityFuelLog == null &&
            provider.isFuelDataLoading) {
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, index) => const SizedBox(height: 15),
                  itemCount: 10,
                  itemBuilder: (_, index) {
                    return activityShimmerItem(context, isDarkTheme);
                  },
                ),
              ),
            ],
          );
        }

        final fuelLogData = provider.modelActivityFuelLog?.records;

        if (!provider.isFuelDataLoading &&
            (fuelLogData == null || fuelLogData.isEmpty)) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
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
                        text: "No Fuel Records Available",
                        fontSize: 18,
                        color: isDarkTheme
                            ? AllDesigns.white
                            : AllDesigns.blackColor,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            fuelPaginationWidget(provider, isDarkTheme),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: fuelLogData?.length ?? 0,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final fuelData = fuelLogData?[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? AllDesigns.greyShade800Color
                            : AllDesigns.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText(
                                  text: "Fuel Logs",
                                  fontSize: 16,
                                  color: AllDesigns.appColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AllDesigns.greyShade300Color
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AllDesigns.greyShade500Color,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedCalendar04,
                                          color: isDarkTheme
                                              ? AllDesigns.whiteColor
                                              : AllDesigns.greyShade700Color,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        buildText(
                                          text: fuelData?.date ?? "-",
                                          color: isDarkTheme
                                              ? AllDesigns.whiteColor
                                              : AllDesigns.greyShade700Color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedUser,
                              keyText: "Driver: ",
                              valueText: fuelData?.purchaser.toString() ?? "-",
                              isDarkTheme: isDarkTheme,
                            ),
                            const SizedBox(height: 5),
                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedCar05,
                              keyText: "Vehicle: ",
                              valueText: fuelData?.vehicle.toString() ?? "-",
                              isDarkTheme: isDarkTheme,
                            ),

                            const SizedBox(height: 5),
                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedBuilding03,
                              keyText: "Vendor: ",
                              valueText: fuelData?.vendor.toString() ?? "-",
                              isDarkTheme: isDarkTheme,
                            ),
                            const SizedBox(height: 20),
                            Consumer<SettingsProvider>(
                              builder: (context, settings, _) {
                                return safeLabelValueRow(
                                  label: "Total Amount",
                                  value:
                                      "${settings.selectedCurrencySymbol} ${fuelData?.amount.toString()}",
                                  labelFontSize: 15,
                                  valueFontSize: 15,
                                  labelWeight: FontWeight.w700,
                                  valueWeight: FontWeight.w700,
                                  isDarkTheme: isDarkTheme,
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// widget Service Pagination Widget
  Widget servicePaginationWidget(
    ActivityPageProvider provider,
    bool isDarkTheme,
  ) {
    if (provider.serviceTotalCount == 0) return const SizedBox();
    return activityPaginationBase(
      text:
          '${provider.serviceStartIndex}-${provider.serviceEndIndex}/${provider.serviceTotalCount}',
      canGoPrevious: provider.canServicePrevious,
      onPrevious: provider.previousServicePage,
      canGoNext: provider.canServiceNext,
      onNext: provider.nextServicePage,
      isDarkTheme: isDarkTheme,
    );
  }

  /// Widget Pagination Base
  Widget activityPaginationBase({
    required String text,
    required bool canGoPrevious,
    required VoidCallback? onPrevious,
    required bool canGoNext,
    required VoidCallback? onNext,
    required bool isDarkTheme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? AllDesigns.whiteColor.withOpacity(.2)
                : AllDesigns.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AllDesigns.whiteColor.withOpacity(.3)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: buildText(
            text: text,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: .5,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade700Color,
          ),
        ),

        const SizedBox(width: 10),

        InkWell(
          onTap: canGoPrevious ? onPrevious : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_left,
              size: 20,
              color: canGoPrevious
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ),

        const SizedBox(width: 10),

        InkWell(
          onTap: canGoNext ? onNext : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: canGoNext
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget Contract Pagination
  Widget contractPaginationWidget(
    ActivityPageProvider provider,
    bool isDarkTheme,
  ) {
    if (provider.contractTotalCount == 0) return const SizedBox();

    return activityPaginationBase(
      text:
          '${provider.contractStartIndex}-${provider.contractEndIndex}/${provider.contractTotalCount}',
      canGoPrevious: provider.canContractPrevious,
      onPrevious: provider.previousContractPage,
      canGoNext: provider.canContractNext,
      onNext: provider.nextContractPage,
      isDarkTheme: isDarkTheme,
    );
  }

  /// Widget Fuel Pagination
  Widget fuelPaginationWidget(ActivityPageProvider provider, bool isDarkTheme) {
    if (provider.fuelTotalCount == 0) return const SizedBox();
    return activityPaginationBase(
      text:
          '${provider.fuelStartIndex}-${provider.fuelEndIndex}/${provider.fuelTotalCount}',
      canGoPrevious: provider.canFuelPrevious,
      onPrevious: provider.previousFuelPage,
      canGoNext: provider.canFuelNext,
      onNext: provider.nextFuelPage,
      isDarkTheme: isDarkTheme,
    );
  }

  /// Widget Activity Odometer Logs
  Widget _buildActivityOdometerLogs({required bool isDarkTheme}) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ActivityPageProvider>(
      builder: (context, provider, child) {
        if (provider.isOdometerInitialLoad &&
            provider.isOdometerDataLoading &&
            provider.modelActivityOdometerLog == null) {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 5),
            itemCount: 10,
            itemBuilder: (_, __) => activityShimmerItem(context, isDarkTheme),
          );
        }

        final odometerData = provider.modelActivityOdometerLog?.records;

        if (odometerData == null || odometerData.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        text: "No Odometer Records Available",
                        fontSize: 18,
                        color: isDarkTheme
                            ? AllDesigns.white
                            : AllDesigns.blackColor,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            odometerPaginationWidget(provider, isDarkTheme),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: odometerData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final odometer = odometerData[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkTheme
                            ? AllDesigns.greyShade800Color
                            : AllDesigns.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: AllDesigns.black12, blurRadius: 10),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText(
                                  text: "Odometer Logs",
                                  fontSize: 16,
                                  color: AllDesigns.appColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AllDesigns.greyShade300Color
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AllDesigns.greyShade500Color,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedCalendar04,
                                          color: isDarkTheme
                                              ? AllDesigns.whiteColor
                                              : AllDesigns.greyShade700Color,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        buildText(
                                          text: odometer.date ?? "-",
                                          color: isDarkTheme
                                              ? AllDesigns.whiteColor
                                              : AllDesigns.greyShade700Color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedUser,
                              keyText: "Driver: ",
                              valueText: odometer.driver.name,
                              isDarkTheme: isDarkTheme,
                            ),
                            const SizedBox(height: 5),

                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedCar05,
                              keyText: "Vehicle: ",
                              valueText: odometer.vehicle.name,
                              isDarkTheme: isDarkTheme,
                            ),
                            const SizedBox(height: 5),

                            buildRowWidget(
                              icon: HugeIcons.strokeRoundedDashboardSpeed02,
                              keyText: "Odometer Value: ",
                              valueText: "${odometer.value} (${odometer.unit})",
                              isDarkTheme: isDarkTheme,
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget Activity Service Logs
  Widget _buildActivityServiceLogs({required bool isDarkTheme}) {
    return Consumer<ActivityPageProvider>(
      builder: (context, provider, child) {
        final int activeFilterCount = provider.activeServiceFilterCount;
        final List serviceData =
            provider.modelActivityServiceLog?.records ?? [];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: activeFilterCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AllDesigns.blackColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$activeFilterCount Active",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          "No filters applied",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.blackColor,
                          ),
                        ),
                ),
                servicePaginationWidget(provider, isDarkTheme),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildServiceBody(
                context: context,
                provider: provider,
                serviceData: serviceData,
                isDarkTheme: isDarkTheme,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget Service Body
  Widget _buildServiceBody({
    required BuildContext context,
    required ActivityPageProvider provider,
    required List serviceData,
    required bool isDarkTheme,
  }) {
    if (provider.isServiceInitialLoad &&
        provider.isServiceDataLoading &&
        provider.modelActivityServiceLog == null) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => activityShimmerItem(context, isDarkTheme),
      );
    }

    if (serviceData.isEmpty) {
      final bool hasFilters = provider.selectedServiceFilters.isNotEmpty;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                    text: hasFilters
                        ? "No Vehicles Available"
                        : "No Service Records Available",
                    fontSize: 18,
                    color: isDarkTheme ? Colors.white : AllDesigns.blackColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),

                  const SizedBox(height: 10),

                  if (hasFilters)
                    buildText(
                      text: "Try Adjusting your filters",
                      fontSize: 14,
                      color: isDarkTheme
                          ? Colors.white
                          : AllDesigns.greyShade600Color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),

                  const SizedBox(height: 10),

                  if (hasFilters)
                    buildContainerWidget(
                      width: MediaQuery.of(context).size.width * 0.5,
                      borderColors: AllDesigns.appColor,
                      onTap: () async {
                        await provider.clearServiceFiltersAndReload();
                      },
                      buttonName: "Clear All filters",
                      buttonTextColor: AllDesigns.appColor,
                      containerColor: AllDesigns.whiteColor,
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: serviceData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final service = serviceData[index];
        return _buildServiceItem(service, isDarkTheme);
      },
    );
  }

  /// Widget Service item
  Widget _buildServiceItem(dynamic service, bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkTheme
              ? AllDesigns.greyShade800Color
              : AllDesigns.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText(
                    text: "Service Logs",
                    fontSize: 16,
                    color: AllDesigns.appColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AllDesigns.greyShade300Color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AllDesigns.greyShade500Color),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar04,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade700Color,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          buildText(
                            text: service.date ?? "-",
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade700Color,
                            letterSpacing: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedNotebook02,
                keyText: "Description: ",
                valueText: service.description,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedPowerService,
                keyText: "Service Type: ",
                valueText: service.serviceType.name,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedCar05,
                keyText: "Vehicle: ",
                valueText: service.vehicle.name,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedUser,
                keyText: "Driver: ",
                valueText: service.purchaser.name,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedBuilding03,
                keyText: "Vendor: ",
                valueText: service.vendor.name,
                isDarkTheme: isDarkTheme,
              ),

              const SizedBox(height: 20),

              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return safeLabelValueRow(
                    label: "Total Amount",
                    value:
                        "${settings.selectedCurrencySymbol} ${service.amount}",
                    isDarkTheme: isDarkTheme,
                    labelFontSize: 15,
                    valueFontSize: 15,
                    labelWeight: FontWeight.w700,
                    valueWeight: FontWeight.w700,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget Activity Contracts Logs
  Widget _buildActivityContractsLogs({required bool isDarkTheme}) {
    return Consumer<ActivityPageProvider>(
      builder: (context, provider, child) {
        final int activeFilterCount = provider.activeContractFilterCount;
        final List contractData =
            provider.modelActivityContractLog?.records ?? [];

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: activeFilterCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AllDesigns.blackColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$activeFilterCount Active",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Text(
                          "No filters applied",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.blackColor,
                          ),
                        ),
                ),
                contractPaginationWidget(provider, isDarkTheme),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _buildContractBody(
                context: context,
                provider: provider,
                contractData: contractData,
                isDarkTheme: isDarkTheme,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget Contract View
  Widget _buildContractBody({
    required BuildContext context,
    required ActivityPageProvider provider,
    required List contractData,
    required bool isDarkTheme,
  }) {
    if (provider.isContractInitialLoad &&
        provider.isContractDataLoading &&
        provider.modelActivityContractLog == null) {
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => activityShimmerItem(context, isDarkTheme),
      );
    }

    if (contractData.isEmpty) {
      final bool hasFilters = provider.selectedContractFilters.isNotEmpty;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
                    text: hasFilters
                        ? "No Vehicles Available"
                        : "No Contract Records Available",
                    fontSize: 18,
                    color: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.blackColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),

                  const SizedBox(height: 10),

                  if (hasFilters)
                    buildText(
                      text: "Try adjusting your filters",
                      fontSize: 14,
                      color: isDarkTheme
                          ? Colors.white
                          : AllDesigns.greyShade600Color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),

                  const SizedBox(height: 10),

                  if (hasFilters)
                    buildContainerWidget(
                      width: MediaQuery.of(context).size.width * 0.5,
                      borderColors: AllDesigns.appColor,
                      onTap: () async {
                        await provider.clearContractFiltersAndReload();
                      },
                      buttonName: "Clear All filters",
                      buttonTextColor: AllDesigns.appColor,
                      containerColor: AllDesigns.whiteColor,
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: contractData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final contract = contractData[index];
        return _buildContractItem(contract, isDarkTheme);
      },
    );
  }

  /// Widget Contract Activity Log
  Widget _buildContractItem(dynamic contract, bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkTheme
              ? AllDesigns.greyShade800Color
              : AllDesigns.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText(
                    text: "Contracts Logs",
                    fontSize: 16,
                    color: AllDesigns.appColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AllDesigns.greyShade300Color.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AllDesigns.greyShade500Color),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar04,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade700Color,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          buildText(
                            text: contract.startDate ?? "-",
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade700Color,
                            letterSpacing: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedCalendar04,
                keyText: "Expiration Date: ",
                valueText: contract.expirationDate,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedCar05,
                keyText: "Vehicle: ",
                valueText: contract.vehicle.name,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedBuilding03,
                keyText: "Vendor: ",
                valueText: contract.insurer.name,
                isDarkTheme: isDarkTheme,
              ),
              const SizedBox(height: 5),

              buildRowWidget(
                icon: HugeIcons.strokeRoundedUser,
                keyText: "Driver: ",
                valueText: contract.purchaser.name,
                isDarkTheme: isDarkTheme,
              ),

              const SizedBox(height: 20),

              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return safeLabelValueRow(
                    label: "Recurring Cost",
                    value:
                        "${settings.selectedCurrencySymbol} ${contract.costGenerated}",
                    labelFontSize: 15,
                    valueFontSize: 15,
                    labelWeight: FontWeight.w700,
                    valueWeight: FontWeight.w700,
                    isDarkTheme: isDarkTheme,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget Odometer Pagination
  Widget odometerPaginationWidget(
    ActivityPageProvider provider,
    bool isDarkTheme,
  ) {
    if (provider.odometerTotalCount == 0) return const SizedBox();

    return activityPaginationBase(
      text:
          '${provider.odometerStartIndex}-${provider.odometerEndIndex}/${provider.odometerTotalCount}',
      canGoPrevious: provider.canOdometerPrevious,
      onPrevious: provider.previousOdometerPage,
      canGoNext: provider.canOdometerNext,
      onNext: provider.nextOdometerPage,
      isDarkTheme: isDarkTheme,
    );
  }

  /// Speed Dial
  Widget _buildSpeedDial(BuildContext context, isDarkTheme) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AllDesigns.appColor,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.3,
      spacing: 12,
      spaceBetweenChildren: 12,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      children: [
        SpeedDialChild(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedConfiguration01,
            color: AllDesigns.white,
            size: 25,
          ),
          backgroundColor: AllDesigns.appColor,
          label: 'Create Fuel/Service Log',
          labelStyle: TextStyle(
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/addFuelLog');
          },
        ),
        SpeedDialChild(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedDashboardSpeed02,
            color: AllDesigns.white,
            size: 25,
          ),
          backgroundColor: AllDesigns.appColor,
          label: 'Create Odometer Log',
          labelStyle: TextStyle(
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/addOdometerLog');
          },
        ),
        SpeedDialChild(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedBook02,
            color: AllDesigns.white,
            size: 25,
          ),
          backgroundColor: AllDesigns.appColor,
          label: 'Create Contract Log',
          labelStyle: TextStyle(
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
          ),
          onTap: () {
            Navigator.pushNamed(context, '/addContractLog');
          },
        ),
      ],
    );
  }

  /// Widget Row For data
  buildRowWidget({
    required String? keyText,
    required String? valueText,
    required List<List<dynamic>> icon,
    required bool isDarkTheme,
  }) {
    return Row(
      children: [
        Row(
          children: [
            HugeIcon(
              icon: icon,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
              size: 15,
            ),
            const SizedBox(width: 8),
            buildText(
              text: keyText,
              fontSize: 13,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade600Color,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            valueText ?? "-",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Safe Label Values in Row
  Widget safeLabelValueRow({
    required String label,
    required String value,
    required bool isDarkTheme,
    double labelFontSize = 13,
    double valueFontSize = 13,
    FontWeight labelWeight = FontWeight.w400,
    FontWeight valueWeight = FontWeight.w400,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: labelWeight,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: valueWeight,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget Activity Shimmer
  Widget activityShimmerItem(BuildContext context, bool isDarkTheme) {
    final size = MediaQuery.of(context).size;
    final baseColor = isDarkTheme
        ? AllDesigns.greyShade800Color
        : Colors.grey.shade300;
    final highlightColor = isDarkTheme
        ? AllDesigns.greyShade700Color
        : Colors.grey.shade100;

    final cardColor = isDarkTheme ? AllDesigns.greyShade800Color : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.15,
              height: size.width * 0.15,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: cardColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: size.width * 0.5,
                    color: cardColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: size.width * 0.3,
                    color: cardColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Icon
  Widget buildIcon({
    required List<List<dynamic>> icon,
    required Color? color,
    required double? size,
  }) {
    return HugeIcon(icon: icon, color: color, size: size);
  }

  /// Widget Container
  Widget buildContainerWidget({
    required void Function()? onTap,
    required String? buttonName,
    required Color buttonTextColor,
    required Color? containerColor,
    required Color borderColors,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColors),
        ),
        child: Center(
          child: buildText(
            text: buttonName,
            fontSize: 15,
            color: buttonTextColor,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

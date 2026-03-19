import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_vehicle_data.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_view.dart';
import 'package:mobo_projects/features/vehicles_details/edit_vehicles_details_page.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_page.dart';
import 'package:mobo_projects/shared/services/review_service.dart';
import 'package:provider/provider.dart';
import 'vehicles_provider.dart';
import 'package:shimmer/shimmer.dart';

class VehiclesPage extends StatefulWidget {
  final bool skipPermissionGate;
  VehiclesPage({super.key, this.skipPermissionGate = false});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!widget.skipPermissionGate) {
        final perm = context.read<FleetPermissionProvider>();
        if (!perm.canAccessFleet) return;
      }
      final provider = Provider.of<VehiclesProvider>(context, listen: false);
      provider.fetchVehiclesPageData();
      await ReviewService().printReviewStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skipPermissionGate) {
      return _buildPageContent(context);
    }
    return FleetPermissionView(
      pageName: "Vehicles",
      child: _buildPageContent(context),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color mainWidgetColor = Theme.of(context).primaryColor;
    return Consumer<VehiclesProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                buildSearchBar(
                  isDarkTheme: isDarkTheme,
                  context: context,
                  leftIcon: HugeIcons.strokeRoundedFilterHorizontal,
                  rightIcon: HugeIcons.strokeRoundedCancel01,
                  iconColor: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade800Color,
                  iconSize: 18,
                  controller: provider.searchFilterController,
                  provider: provider,
                  mainWidgetColor: mainWidgetColor,
                ),
                const SizedBox(height: 10),
                _vehicleFilterPaginationWidget(
                  provider: provider,
                  isDarkTheme: isDarkTheme,
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (provider.isLoading) {
                        return ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: 10,
                          itemBuilder: (_, __) =>
                              vehicleShimmerItem(context, isDarkTheme),
                        );
                      }

                      if (provider.isClearingAllFields) {
                        return ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: 10,
                          itemBuilder: (_, __) =>
                              vehicleShimmerItem(context, isDarkTheme),
                        );
                      }

                      if (provider.isFilterApplying) {
                        return ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: 10,
                          itemBuilder: (_, __) =>
                              vehicleShimmerItem(context, isDarkTheme),
                        );
                      }

                      if (provider.filteredVehicles.isEmpty) {
                        return RefreshIndicator(
                          color: AllDesigns.appColor,
                          onRefresh: provider.refreshVehicles,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
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
                                        text: "No Vehicles Available",
                                        fontSize: 18,
                                        color: isDarkTheme
                                            ? Colors.white
                                            : AllDesigns.blackColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0,
                                      ),
                                      const SizedBox(height: 10),
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
                                      Consumer<VehiclesProvider>(
                                        builder: (context, provider, child) {
                                          return buildContainerWidget(
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.5,
                                            borderColors: AllDesigns.appColor,
                                            onTap: () {
                                              provider.clearAllFilter();
                                            },

                                            buttonName: "Clear All filters",
                                            buttonTextColor:
                                                AllDesigns.appColor,
                                            containerColor:
                                                AllDesigns.whiteColor,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AllDesigns.appColor,
                        onRefresh: provider.refreshVehicles,
                        child: ListView.separated(
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: provider.filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final records = provider.filteredVehicles[index];
                            return _buildVehicleItem(
                              context,
                              records,
                              isDarkTheme,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: Consumer<FleetPermissionProvider>(
            builder: (context, perm, _) {
              if (!perm.isFleetAdmin) {
                return const SizedBox.shrink();
              }
              return _buildSpeedDial(context);
            },
          ),
        );
      },
    );
  }

  Widget paginationControls(VehiclesProvider provider, bool isDarkTheme) {
    if (provider.totalCount == 0) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? AllDesigns.whiteColor.withOpacity(.2)
                : AllDesigns.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: buildText(
            text:
                '${provider.startIndex}-${provider.endIndex}/${provider.totalCount}',
            fontSize: 12,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade700Color,
            fontWeight: FontWeight.w400,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: provider.canGoPrevious ? provider.previousPage : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: provider.canGoNext ? provider.nextPage : null,
        ),
      ],
    );
  }

  Widget _buildVehicleItem(
    BuildContext context,
    FleetVehicle records,
    bool isDarkTheme,
  ) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehiclesDetailsPage(
              imageBytes: records.imageBytes,
              vehicleId: records.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
          boxShadow: [BoxShadow(color: AllDesigns.black12, blurRadius: 5)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AllDesigns.whiteColor, width: 1),
                ),
                child: CircleAvatar(
                  radius: size.width * 0.09,
                  backgroundColor: isDarkTheme
                      ? AllDesigns.greyShade800Color
                      : Colors.white,
                  backgroundImage: records.imageBytes != null
                      ? MemoryImage(records.imageBytes!)
                      : null,
                  child: records.imageBytes == null
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedCar05,
                          size: 20,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildText(
                      text: records.licensePlate,
                      fontSize: 14,
                      color: AllDesigns.appColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                    const SizedBox(height: 4),
                    buildText(
                      text: records.model,
                      fontSize: 14,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.greyShade600Color,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0,
                    ),
                    buildText(
                      text: records.driver,
                      fontSize: 14,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.greyShade600Color,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vehicleFilterPaginationWidget({
    required VehiclesProvider provider,
    required bool isDarkTheme,
  }) {
    final bool hasFilters = provider.selectedFilters.isNotEmpty;
    final bool hasData = provider.totalCount > 0;

    /// Hide only when no filters AND no data
    if (!hasFilters && !hasData) return const SizedBox();

    return Row(
      children: [
        /// Filter count (ALWAYS show if filters applied)
        hasFilters
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AllDesigns.blackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    buildText(
                      text: "${provider.activeFiltersCount} Active",
                      fontSize: 12,
                      color: AllDesigns.whiteColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: buildText(
                  text: "No filters applied",
                  fontSize: 12,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.blackColor,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),

        const Spacer(),

        /// Pagination (ONLY if data exists)
        if (hasData) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? AllDesigns.whiteColor.withOpacity(.2)
                  : AllDesigns.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AllDesigns.whiteColor.withOpacity(.3)),
            ),
            child: buildText(
              text:
                  '${provider.startIndex}-${provider.endIndex}/${provider.totalCount}',
              fontSize: 12,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
              fontWeight: FontWeight.w400,
              letterSpacing: .5,
            ),
          ),

          const SizedBox(width: 6),

          InkWell(
            onTap: provider.canGoPrevious ? provider.previousPage : null,
            child: Icon(
              Icons.chevron_left,
              size: 20,
              color: provider.canGoPrevious
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),

          const SizedBox(width: 6),

          InkWell(
            onTap: provider.canGoNext ? provider.nextPage : null,
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: provider.canGoNext
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ],
      ],
    );
  }

  Widget paginationWidget(
    BuildContext context,
    VehiclesProvider provider,
    bool isDarkTheme,
  ) {
    if (provider.totalCount == 0) return const SizedBox();
    final bool noFiltersApplied = provider.selectedFilters.isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        noFiltersApplied
            ? Padding(
                padding: const EdgeInsets.only(left: 10),
                child: buildText(
                  text: "No filters applied",
                  fontSize: 12,
                  color: AllDesigns.blackColor,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              )
            : Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AllDesigns.blackColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    buildIcon(
                      icon: HugeIcons.strokeRoundedFilterHorizontal,
                      color: isDarkTheme
                          ? AllDesigns.blackColor
                          : AllDesigns.whiteColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    buildText(
                      text: "${provider.activeFiltersCount} Active",
                      fontSize: 12,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.whiteColor,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ],
                ),
              ),

        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkTheme
                ? AllDesigns.whiteColor.withOpacity(.2)
                : AllDesigns.white,
            borderRadius: BorderRadius.circular(20),
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
            text:
                '${provider.startIndex}-${provider.endIndex}/${provider.totalCount}',
            fontSize: 12,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade700Color,
            fontWeight: FontWeight.w400,
            letterSpacing: .5,
          ),
        ),

        InkWell(
          onTap: provider.canGoPrevious ? provider.previousPage : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_left,
              size: 20,
              color: provider.canGoPrevious
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ),

        const SizedBox(width: 10),
        InkWell(
          onTap: provider.canGoNext ? provider.nextPage : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: provider.canGoNext
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSearchBar({
    required List<List<dynamic>> leftIcon,
    required List<List<dynamic>> rightIcon,
    required double iconSize,
    required Color iconColor,
    required TextEditingController controller,
    required BuildContext context,
    required VehiclesProvider provider,
    required Color mainWidgetColor,
    required bool isDarkTheme,
  }) {
    return TextFormField(
      key: const Key("test_case_vehicles_"),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkTheme ? AllDesigns.greyShade800Color : Colors.white,
        prefixIcon: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              buildBottomSheet(
                context: context,
                provider: provider,
                mainWidgetColor: mainWidgetColor,
                isDarkTheme: isDarkTheme,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: HugeIcon(
                key: const Key("vehiclesPage_filter_open_key"),
                icon: leftIcon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
        ),

        suffixIcon: provider.searchFilterController.text.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    controller.clear();
                    provider.fetchVehicles(
                      domain: [],
                      resetPage: true,
                      fetchCount: true,
                    );
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
        hintText: "Search Vehicles",
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

  Widget vehicleShimmerItem(BuildContext context, bool isDarkTheme) {
    final size = MediaQuery.of(context).size;

    final baseColor = isDarkTheme
        ? AllDesigns.greyShade800Color
        : Colors.grey.shade300;
    final highlightColor = isDarkTheme
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    final cardColor = isDarkTheme
        ? AllDesigns.grey.withOpacity(.1)
        : Colors.white;

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
              width: size.width * 0.18,
              height: size.width * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardColor,
              ),
            ),

            const SizedBox(width: 12),

            /// Text shimmer lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: size.width * 0.45,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: size.width * 0.35,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: size.width * 0.25,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void buildBottomSheet({
    required BuildContext context,
    required VehiclesProvider provider,
    required Color mainWidgetColor,
    required bool isDarkTheme,
  }) {
    showModalBottomSheet<void>(
      backgroundColor: isDarkTheme
          ? AllDesigns.greyShade800Color
          : Colors.white,
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText(
                      text: "Filter & Group By",
                      fontSize: 20,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.blackColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                    InkWell(
                      onTap: () {
                        provider.clearAllFilter();
                        Navigator.pop(context);
                      },
                      child: buildIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: isDarkTheme
                            ? AllDesigns.whiteColor
                            : AllDesigns.greyShade700Color,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildText(
                          text: "Active filters",
                          fontSize: 20,
                          color: isDarkTheme
                              ? AllDesigns.whiteColor
                              : AllDesigns.appColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                        Consumer<VehiclesProvider>(
                          builder: (context, provider, child) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: provider.selectedFilters.isEmpty
                                  ? Text(
                                      "No active filters",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: isDarkTheme
                                            ? AllDesigns.appColor
                                            : AllDesigns.black54,
                                        letterSpacing: 0,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: provider.selectedFilters.map((
                                        filter,
                                      ) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AllDesigns.appColor
                                                .withOpacity(0.1),
                                            border: Border.all(
                                              color: AllDesigns.appColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check,
                                                size: 18,
                                                color: AllDesigns.appColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                filter,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AllDesigns.appColor,
                                                  letterSpacing: 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        buildText(
                          text: "Filters",
                          fontSize: 20,
                          color: isDarkTheme
                              ? AllDesigns.whiteColor
                              : AllDesigns.appColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                        const SizedBox(height: 10),

                        Consumer<VehiclesProvider>(
                          builder: (context, provider, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Car");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected("Car")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color: provider.isFilterSelected("Car")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Car",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Car")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Bike");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected("Bike")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color: provider.isFilterSelected("Bike")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Bike",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Bike")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Available");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected("Available")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected("Available")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Available",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Available")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Trailer Hook");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected(
                                            "Trailer Hook",
                                          )
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected(
                                            "Trailer Hook",
                                          )
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Trailer Hook",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected(
                                            "Trailer Hook",
                                          )
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter(
                                        "Planned for Change",
                                      );
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected(
                                            "Planned for Change",
                                          )
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected(
                                            "Planned for Change",
                                          )
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Planned for Change",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected(
                                            "Planned for Change",
                                          )
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const Divider(endIndent: 10, indent: 10),
                        const SizedBox(height: 10),
                        Consumer<VehiclesProvider>(
                          builder: (context, provider, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Need Action");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected(
                                            "Need Action",
                                          )
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected(
                                            "Need Action",
                                          )
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Need Action",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected(
                                            "Need Action",
                                          )
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const Divider(endIndent: 10, indent: 10),
                        const SizedBox(height: 10),
                        Consumer<VehiclesProvider>(
                          builder: (context, provider, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Archived");
                                    },
                                    child: FilterCard(
                                      isDarkTheme: isDarkTheme,
                                      borderColor:
                                          provider.isFilterSelected("Archived")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected("Archived")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Archived",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Archived")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        buildText(
                          text: "Status",
                          fontSize: 20,
                          color: isDarkTheme
                              ? AllDesigns.whiteColor
                              : AllDesigns.appColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                        const SizedBox(height: 10),

                        Consumer<VehiclesProvider>(
                          builder: (context, provider, child) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Active");
                                    },
                                    child: FilterCard(
                                      isDarkTheme: isDarkTheme,
                                      borderColor:
                                          provider.isFilterSelected("Active")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color: provider.isFilterSelected("Active")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Active",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Active")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("In Active");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected("In Active")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color:
                                          provider.isFilterSelected("In Active")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "In Active",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("In Active")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      provider.toggleFilter("Sold");
                                    },
                                    child: FilterCard(
                                      borderColor:
                                          provider.isFilterSelected("Sold")
                                          ? AllDesigns.appColor.withOpacity(.1)
                                          : AllDesigns.white.withOpacity(.1),
                                      color: provider.isFilterSelected("Sold")
                                          ? AllDesigns.appColor
                                          : AllDesigns.appColor.withOpacity(.1),
                                      filteredName: "Sold",
                                      provider: provider,
                                      filterTextColor:
                                          provider.isFilterSelected("Sold")
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.greyShade700Color,
                                      isDarkTheme: isDarkTheme,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Consumer<VehiclesProvider>(
                        builder: (context, provider, child) {
                          return Expanded(
                            child: buildContainerWidget(
                              borderColors: AllDesigns.whiteColor,
                              onTap: () {
                                provider.clearAllFilter();
                                Navigator.pop(context);
                              },
                              buttonName: "Clear All",
                              buttonTextColor: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.blackColor,
                              containerColor: isDarkTheme
                                  ? Colors.grey.shade900
                                  : AllDesigns.whiteColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Consumer<VehiclesProvider>(
                        builder: (context, provider, child) {
                          return Expanded(
                            flex: 2,
                            child: buildContainerWidget(
                              borderColors: AllDesigns.appColor,
                              onTap: () {
                                provider.applyFilterAll(context);
                              },
                              buttonName: "Apply",
                              buttonTextColor: Colors.white,
                              containerColor: mainWidgetColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget FilterCard({
    required Color color,
    required String? filteredName,
    required Color filterTextColor,
    required VehiclesProvider provider,
    Color? borderColor,
    required bool isDarkTheme,
  }) {
    return Row(
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.only(right: 20, left: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor ?? Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (provider.isFilterSelected(filteredName.toString()))
                buildIcon(
                  icon: HugeIcons.strokeRoundedTick02,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.blackColor,
                  size: 20,
                ),
              const SizedBox(width: 10),
              buildText(
                text: filteredName,
                fontSize: 15,
                color: filterTextColor,

                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

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

  Widget buildText({
    required String? text,
    required double? fontSize,
    required Color color,
    required FontWeight fontWeight,
    required double? letterSpacing,
    int maxLines = 2,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text ?? "",
      maxLines: maxLines,
      softWrap: true,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }

  Widget buildIcon({
    required List<List<dynamic>> icon,
    required Color? color,
    required double? size,
  }) {
    return HugeIcon(icon: icon, color: color, size: size);
  }

  Widget _buildSpeedDial(BuildContext context) {
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
          child: buildIcon(
            icon: HugeIcons.strokeRoundedCar05,
            color: AllDesigns.white,
            size: 25,
          ),
          backgroundColor: AllDesigns.appColor,
          label: 'Create Vehicle',

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditVehiclesDetailsPage(vehicleId: 0),
              ),
            );
          },
        ),
      ],
    );
  }
}

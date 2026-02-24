import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'drivers_page_provider.dart';

class DriversPage extends StatefulWidget {
  final bool skipPermissionGate;
  const DriversPage({super.key, this.skipPermissionGate = false});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  Future<void> _onRefresh() async {
    final provider = context.read<DriversPageProvider>();
    await provider.fetchDrivers();
    provider.driverSearchFilterController.clear();
    provider.resetPagination();
    provider.updateDriverSearch("");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final perm = context.read<FleetPermissionProvider>();
      if (!perm.canAccessFleet) return;
      context.read<DriversPageProvider>().fetchDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.skipPermissionGate
        ? _buildContentPage(context)
        : FleetPermissionView(
            pageName: "DriversPage",
            child: _buildContentPage(context),
          );
  }

  /// Drivers page
  Widget _buildContentPage(BuildContext context) {
    final Color mainWidgetColor = Theme.of(context).primaryColor;
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer<DriversPageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildSearchBar(
                  context: context,
                  leftIcon: HugeIcons.strokeRoundedSearch01,
                  rightIcon: HugeIcons.strokeRoundedCancel01,
                  iconColor: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade800Color,
                  iconSize: 18,
                  controller: provider.driverSearchFilterController,
                  provider: provider,
                  mainWidgetColor: mainWidgetColor,
                  isDarkTheme: isDarkTheme,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: () {
                    if (provider.isInitialLoad) {
                      return _driversShimmerList(isDarkTheme: isDarkTheme);
                    }

                    if (provider.isLoading &&
                        provider.modelDriverLists == null) {
                      return _driversShimmerList(isDarkTheme: isDarkTheme);
                    }

                    if (provider.modelDriverLists == null ||
                        provider.modelDriverLists!.records.isEmpty) {
                      return Center(
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
                              text: "No DriversPage Available",
                              fontSize: 18,
                              color: isDarkTheme
                                  ? AllDesigns.white
                                  : AllDesigns.blackColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          paginationWidget(context, provider, isDarkTheme),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _driverWidgetList(
                              provider: provider,
                              isDarkTheme: isDarkTheme,
                            ),
                          ),
                        ],
                      ),
                    );
                  }(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget Pagination
  Widget paginationWidget(
    BuildContext context,
    DriversPageProvider provider,
    bool isDarkTheme,
  ) {
    if (provider.totalCount == 0) return const SizedBox();
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
            text:
                '${provider.startIndex}-${provider.endIndex}/${provider.totalCount}',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: .5,
            color: isDarkTheme
                ? AllDesigns.white
                : AllDesigns.greyShade700Color,
          ),
        ),

        const SizedBox(width: 10),
        InkWell(
          onTap: provider.canGoPrevious ? provider.previousPage : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.chevron_left,
              size: 20,
              color: provider.canGoPrevious && !provider.isPageChanging
                  ? AllDesigns.appColor
                  : AllDesigns.greyShade500Color,
            ),
          ),
        ),

        const SizedBox(width: 10),
        InkWell(
          onTap: provider.canGoNext && !provider.isPageChanging
              ? provider.nextPage
              : null,
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

  /// Widget Shimmer Drivers
  Widget _driversShimmerList({required bool isDarkTheme}) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDarkTheme
              ? AllDesigns.greyShade800Color
              : Colors.grey.shade300,
          highlightColor: isDarkTheme
              ? AllDesigns.greyShade700Color
              : Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
      },
    );
  }

  /// Widget Drivers List
  Widget _driverWidgetList({
    required DriversPageProvider provider,
    required bool isDarkTheme,
  }) {
    if (provider.totalCount == 0) return const SizedBox();

    final drivers = provider.modelDriverLists?.records ?? [];

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: drivers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final driver = drivers[index];

        final Uint8List? driverImage = provider.decodeBase64Image(
          driver?.avatar128,
        );

        final ImageProvider? imageProvider = provider.safeMemoryImage(
          driverImage,
        );

        return _driverListCard(
          context: context,
          driver: driver,
          imageProvider: imageProvider,
          isDarkTheme: isDarkTheme,
        );
      },
    );
  }

  /// Widget Driver Card
  Widget _driverListCard({
    required BuildContext context,
    required dynamic driver,
    required ImageProvider? imageProvider,
    required bool isDarkTheme,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/driverDetails',
          arguments: {
            'name': driver?.completeName ?? "",
            'phone': driver?.phone ?? "",
            'id': driver?.id ?? 0,
            'photo': driver?.avatar128,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkTheme
              ? AllDesigns.greyShade800Color
              : AllDesigns.whiteColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? AllDesigns.greyShade600Color
                    : AllDesigns.black12,
                borderRadius: BorderRadius.circular(15),
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? Text(
                      (driver?.completeName?.isNotEmpty ?? false)
                          ? driver.completeName![0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkTheme
                            ? AllDesigns.whiteColor
                            : AllDesigns.greyShade600Color,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    driver?.completeName ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AllDesigns.appColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    driver?.email ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkTheme
                          ? AllDesigns.greyShade300Color
                          : AllDesigns.greyShade700Color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    driver?.phone ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkTheme
                          ? AllDesigns.greyShade300Color
                          : AllDesigns.greyShade700Color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    driver?.city ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkTheme
                          ? AllDesigns.greyShade300Color
                          : AllDesigns.greyShade700Color,
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

  /// Widget Search bar
  Widget buildSearchBar({
    List<List<dynamic>>? leftIcon,
    required List<List<dynamic>> rightIcon,
    required double iconSize,
    required Color iconColor,
    required TextEditingController controller,
    required BuildContext context,
    required DriversPageProvider provider,
    required Color mainWidgetColor,
    required bool isDarkTheme,
  }) {
    return TextFormField(
      key: Key('driver_search_field'),
      controller: controller,
      onChanged: (value) {
        provider.updateDriverSearch(value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: isDarkTheme ? AllDesigns.greyShade800Color : Colors.white,
        prefixIcon: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
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
        suffixIcon: provider.driverSearchFilterController.text.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    controller.clear();
                    provider.updateDriverSearch("");
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

        hintText: "Search Driver",
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
}

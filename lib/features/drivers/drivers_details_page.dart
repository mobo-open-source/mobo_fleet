import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Driverdetails extends StatefulWidget {
  final bool showFromDrivers;
  final int? vehicleId;
  const Driverdetails({
    super.key,
    this.showFromDrivers = false,
    this.vehicleId,
  });

  @override
  State<Driverdetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<Driverdetails> {
  String driverName = "-";
  String driverPhone = "-";
  int driverId = 0;
  String? driverPhotoBase64;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DriversPageProvider>();
      provider.fetchVehicles();
      provider.fetchDrivingHistory();
      if (widget.showFromDrivers && widget.vehicleId != null) {
        provider.fetchVehicleDrivingHistory(vehicleId: widget.vehicleId);
      }
    });
  }

  Future<void> _onRefresh(DriversPageProvider provider) async {
    await provider.fetchVehicles();
    await provider.fetchDrivingHistory();

    if (widget.showFromDrivers && widget.vehicleId != null) {
      await provider.fetchVehicleDrivingHistory(vehicleId: widget.vehicleId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      driverName = args['name'] ?? "-";
      driverPhone = args['phone'] ?? "-";
      driverId = args['id'] ?? 0;
      driverPhotoBase64 = args['photo'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DriversPageProvider>();

    final Uint8List? driverImageBytes = provider.decodeBase64Image(
      driverPhotoBase64,
    );
    final ImageProvider? driverImageProvider = provider.safeMemoryImage(
      driverImageBytes,
    );
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Consumer<DriversPageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: size.height * 0.08,
            leading: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: buildIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.blackColor,
                  size: 25,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildText(
                  text: widget.showFromDrivers
                      ? "Driving History"
                      : "Driver's History",
                  fontSize: 22,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.blackColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: RefreshIndicator(
              color: AllDesigns.appColor,
              backgroundColor: AllDesigns.whiteColor,
              onRefresh: () => _onRefresh(provider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.showFromDrivers
                        ? _buildVehicleDrivingHistory(
                            provider,
                            context,
                            isDarkTheme,
                          )
                        : provider.isLoading
                        ? buildDriverDetailsShimmer(isDarkTheme)
                        : _driverDetailsWidget(
                            context: context,
                            provider: provider,
                            driverName: driverName,
                            driverPhone: driverPhone,
                            driverId: driverId,
                            isDarkTheme: isDarkTheme,
                            driverImageProvider: driverImageProvider,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _driverDetailsWidget({
  required DriversPageProvider provider,
  required String driverName,
  String? driverPhone,
  required int driverId,
  required BuildContext context,
  required bool isDarkTheme,
  required ImageProvider? driverImageProvider,
}) {
  final size = MediaQuery.of(context).size;

  bool matchesDriver(dynamic driverField) {
    if (driverField == null) return false;
    if (driverField is List && driverField.length >= 2) {
      return driverField[0] == driverId || driverField[1] == driverName;
    }
    return driverField == driverId || driverField == driverName;
  }

  final filteredVehicles = provider.modelFleetDashboardVehicleData?.records
      .where((vehicle) => matchesDriver(vehicle.driver))
      .toList();

  return Container(
    width: size.width * 0.9,
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
                image: driverImageProvider != null
                    ? DecorationImage(
                        image: driverImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: driverImageProvider == null
                  ? Text(
                      driverName.isNotEmpty ? driverName[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildText(
                text: driverName.toString(),
                fontSize: 20,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: buildText(
            text: "Assigned Vehicles",
            fontSize: 16,
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),

        if (filteredVehicles == null || filteredVehicles.isEmpty)
          buildText(
            text: "No vehicles have Registered",
            fontSize: 12,
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          )
        else
          Column(
            children: filteredVehicles.map((vehicle) {
              return Consumer<DriversPageProvider>(
                builder: (context, provider, _) {
                  final historyRecords =
                      provider.modelDrivingHistory?.records
                          .where(
                            (record) =>
                                record.driverId?.id == driverId &&
                                record.vehicleId?.id == vehicle.id,
                          )
                          .toList() ??
                      [];

                  final showHistory =
                      provider.vehicleDropdownStatus[vehicle.id] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? AllDesigns.greyShade700Color
                          : AllDesigns.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AllDesigns.greyShade300Color),
                      boxShadow: [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(
                              text: "Model ",
                              fontSize: 12,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade600Color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                            buildText(
                              text: vehicle.model,
                              fontSize: 12,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.blackColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(
                              text: "License Plate",
                              fontSize: 12,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade600Color,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                            buildText(
                              text: vehicle.licensePlate == false
                                  ? ""
                                  : vehicle.licensePlate,
                              fontSize: 12,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.blackColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: buildText(
            text: "Driving History",
            fontSize: 16,
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),

        if (filteredVehicles == null || filteredVehicles.isEmpty)
          buildText(
            text: "No vehicles have Registered",
            fontSize: 12,
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          )
        else
          Column(
            children: filteredVehicles.map((vehicle) {
              return Consumer<DriversPageProvider>(
                builder: (context, provider, _) {
                  final historyRecords =
                      provider.modelDrivingHistory?.records
                          .where(
                            (record) =>
                                record.driverId?.id == driverId &&
                                record.vehicleId?.id == vehicle.id,
                          )
                          .toList() ??
                      [];

                  final showHistory =
                      provider.vehicleDropdownStatus[vehicle.id] ?? false;

                  return Container(
                    key: const Key('test_case_container_finder'),
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? AllDesigns.greyShade700Color
                          : AllDesigns.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AllDesigns.greyShade300Color),

                      boxShadow: [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildText(
                              text:
                                  "${vehicle.model} - (${vehicle.licensePlate ?? '-'}) ",
                              fontSize: 12,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.blackColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0,
                            ),
                            InkWell(
                              onTap: () {
                                provider.toggleVehicleDropdown(vehicle.id);
                              },
                              child: buildIcon(
                                icon: showHistory
                                    ? HugeIcons.strokeRoundedArrowUp01
                                    : HugeIcons.strokeRoundedArrowDown01,
                                color: isDarkTheme
                                    ? AllDesigns.whiteColor
                                    : AllDesigns.blackColor,
                                size: 25,
                                key: ValueKey(
                                  'driver_history_arrow_${vehicle.id}',
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (showHistory)
                          Container(
                            height: historyRecords.isEmpty ? 50 : 170,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkTheme
                                  ? AllDesigns.greyShade700Color
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: AllDesigns.greyShade300Color,
                              ),
                            ),
                            child: historyRecords.isEmpty
                                ? Center(
                                    child: buildText(
                                      text: "No Driving History",
                                      fontSize: 14,
                                      color: isDarkTheme
                                          ? AllDesigns.whiteColor
                                          : AllDesigns.blackColor,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0,
                                    ),
                                  )
                                : ListView.separated(
                                    separatorBuilder: (context, _) =>
                                        const SizedBox(height: 10),
                                    itemCount: historyRecords.length,
                                    itemBuilder: (context, index) {
                                      final history = historyRecords[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText(
                                                  key: const Key(
                                                    'test_case_driversHistory_start_date',
                                                  ),
                                                  text: "Start Date ",
                                                  fontSize: 12,
                                                  color: isDarkTheme
                                                      ? AllDesigns.whiteColor
                                                      : AllDesigns
                                                            .greyShade600Color,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                                buildText(
                                                  key: const Key(
                                                    'test_case_driversHistory_start_date_value',
                                                  ),
                                                  text: history.safeDateStart,
                                                  fontSize: 12,
                                                  color: isDarkTheme
                                                      ? AllDesigns.whiteColor
                                                      : AllDesigns.blackColor,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                buildText(
                                                  key: const Key(
                                                    'test_case_driversHistory_end_date',
                                                  ),
                                                  text: "End Date ",
                                                  fontSize: 12,
                                                  color: isDarkTheme
                                                      ? AllDesigns.whiteColor
                                                      : AllDesigns
                                                            .greyShade600Color,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                                buildText(
                                                  key: const Key(
                                                    'test_case_driversHistory_end_date_value',
                                                  ),
                                                  text: history.safeDateEnd,
                                                  fontSize: 12,
                                                  color: isDarkTheme
                                                      ? AllDesigns.whiteColor
                                                      : AllDesigns.blackColor,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

Widget _buildVehicleDrivingHistory(
    DriversPageProvider provider,
  BuildContext context,
  bool isDarkTheme,
) {
  if (provider.isDrivingHistoryLoading) {
    return buildDrivingHistoryShimmer();
  }

  if (provider.drivingHistory.isEmpty) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset('assets/lotties/empty ghost.json'),
            ),
            const SizedBox(height: 10),
            buildText(
              text: "No Driving History found",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
              letterSpacing: 0,
            ),
          ],
        ),
      ),
    );
  }

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: provider.drivingHistory.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final log = provider.drivingHistory[index];

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AllDesigns.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(
              text: log.driverName.isEmpty ? "" : log.driverName,
              fontSize: 16,
              color: AllDesigns.appColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),

            const SizedBox(height: 6),

            buildText(
              text: log.vehicleName.isEmpty ? "" : log.vehicleName,
              fontSize: 14,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade600Color,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  size: 20,
                ),
                const SizedBox(width: 5),
                buildText(
                  text: log.dateStartFormatted.isEmpty
                      ? ''
                      : log.dateStartFormatted,
                  fontSize: 13,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0,
                ),
                const SizedBox(width: 5),

                buildIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  size: 20,
                ),
                const SizedBox(width: 5),

                buildText(
                  text:
                      "Valid until ${log.dateEndFormatted.isEmpty ? '' : log.dateEndFormatted}",
                  fontSize: 13,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0,
                ),
              ],
            ),
            const SizedBox(height: 6),
            buildText(
              text: "Attachments: ${log.attachmentNumber}",
              fontSize: 13,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade600Color,
              fontWeight: FontWeight.w300,
              letterSpacing: 0,
            ),
          ],
        ),
      );
    },
  );
}

Widget buildText({
  required String? text,
  required double? fontSize,
  required Color color,
  required FontWeight fontWeight,
  required double? letterSpacing,
  Key? key,
}) {
  return Text(
    text ?? "",
    key: key,
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
  void Function()? onTap,
  Key? key,
}) {
  return InkWell(
    onTap: onTap,
    child: HugeIcon(icon: icon, color: color, size: size, key: key),
  );
}

Widget buildDrivingHistoryShimmer() {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 5,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                height: 14,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 12,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget buildDriverDetailsShimmer(bool isDarkTheme) {
  return Shimmer.fromColors(
    baseColor: isDarkTheme ? Colors.grey.shade700 : Colors.grey.shade300,
    highlightColor: isDarkTheme ? Colors.grey.shade500 : Colors.grey.shade100,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),
        ...List.generate(2, (_) => _vehicleCardShimmer()),
        const SizedBox(height: 15),
        ...List.generate(2, (_) => _vehicleCardShimmer()),
      ],
    ),
  );
}

Widget _vehicleCardShimmer() {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}

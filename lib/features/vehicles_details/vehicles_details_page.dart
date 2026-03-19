import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';

import 'package:mobo_projects/models/model_fetched_fleet_fuel_type_selections.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_page.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_details_page.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/edit_vehicles_details_page.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../models/model_fleet_vehicle_details.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';

class VehiclesDetailsPage extends StatefulWidget {
  final int vehicleId;
  final Uint8List? imageBytes;

  VehiclesDetailsPage({
    super.key,
    required this.vehicleId,
    required this.imageBytes,
  });

  @override
  State<VehiclesDetailsPage> createState() => _VehiclesDetailsPageState();
}

class _VehiclesDetailsPageState extends State<VehiclesDetailsPage> {
  Color getVehicleStateColor(String state) {
    switch (state.toLowerCase().trim()) {
      case 'new request':
        return Colors.blue;

      case 'to order':
        return Colors.blueAccent;

      case 'ordered':
        return Colors.lightBlue;

      case 'registered':
        return Colors.green;

      case 'waitinglist':
        return Colors.red;

      default:
        return AllDesigns.appColor;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VehiclesDetailsProvider>();
      provider.fetchVehicleDetails(widget.vehicleId);
      provider.loadFuelTypes();
    });
  }

  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer<VehiclesDetailsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leadingWidth: 50,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
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

            title: Text(
              "Vehicles Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
              ),
            ),

            actions: [
              buildIcon(
                key: Key('edit_icon_key'),
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.greyShade600Color,
                size: 25,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditVehiclesDetailsPage(vehicleId: widget.vehicleId),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                key: const Key("popup_menu_key"),
                color: isDarkTheme
                    ? AllDesigns.greyShade600Color
                    : AllDesigns.white,
                icon: buildIcon(
                  size: 25,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  icon: HugeIcons.strokeRoundedMoreVertical,
                ),
                onSelected: (String value) {
                  switch (value) {
                    case 'driversHistory':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DriversDetailsPage(
                            showFromDrivers: true,
                            vehicleId: widget.vehicleId,
                          ),
                        ),
                      );
                      break;
                    case 'contracts':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BottomNavigationBarPage(
                            initialIndex: 3,
                            vehicleId: widget.vehicleId,
                            activityTabIndex: ActivityTabs.contract,
                          ),
                        ),
                      );
                      break;

                    case 'services':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BottomNavigationBarPage(
                            initialIndex: 3,
                            vehicleId: widget.vehicleId,
                            activityTabIndex: ActivityTabs.service,
                          ),
                        ),
                      );
                      break;

                    case 'odometer':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BottomNavigationBarPage(
                            initialIndex: 3,
                            vehicleId: widget.vehicleId,
                            activityTabIndex: ActivityTabs.odometer,
                          ),
                        ),
                      );
                      break;
                  }
                },

                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'driversHistory',
                    child: _popupMenuItem(
                      icon: HugeIcons.strokeRoundedClock04,
                      text: 'Drivers History',
                      isDarkTheme: isDarkTheme,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'contracts',
                    child: _popupMenuItem(
                      icon: HugeIcons.strokeRoundedBook02,
                      text: 'Contracts',
                      isDarkTheme: isDarkTheme,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'services',
                    child: _popupMenuItem(
                      icon: HugeIcons.strokeRoundedConfiguration01,
                      text: 'Services',
                      isDarkTheme: isDarkTheme,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'odometer',
                    child: _popupMenuItem(
                      icon: HugeIcons.strokeRoundedDashboardSpeed02,
                      text: 'Odometer',
                      isDarkTheme: isDarkTheme,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Consumer<VehiclesDetailsProvider>(
                builder: (context, provider, child) {
                  if (provider.isVehicleDetailsLoading) {
                    return _buildVehicleDetailsShimmer(context, isDarkTheme);
                  }
                  if (!provider.isVehicleDetailsLoading &&
                      (provider.modelFleetVehicleDetails == null ||
                          provider.modelFleetVehicleDetails!.records.isEmpty)) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
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
                            Text(
                              "No Vehicle Details found",
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkTheme
                                    ? Colors.white
                                    : AllDesigns.blackColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final vehicle = provider.modelFleetVehicleDetails!.records.first;
                  final String vehicleType = provider.isCar
                      ? 'car'
                      : provider.isBike
                      ? 'bike'
                      : '';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        buildDetail1Container(
                          driver: vehicle?.driver?.name ?? "",
                          model: vehicle?.model?.name ?? "",
                          licensePlate: vehicle?.licensePlate ?? "",
                          vehicleType: vehicleType,
                          context: context,
                          chasisno: vehicle?.vinSn ?? "",
                          tags: provider?.vehicleTags ?? [],
                          provider: provider,
                          isDarkTheme: isDarkTheme,
                        ),
                        const SizedBox(height: 10),
                        buildDetail2Container(
                          vehicleType: vehicleType,
                          driverName: vehicle?.driver?.name ?? "",
                          state: vehicle?.state?.name ?? "",
                          mobilityCard: vehicle?.mobilityCard ?? "",
                          provider: provider,
                          assignedDate:
                              vehicle?.nextAssignationDate.toString() ?? "",
                          futureDriver: vehicle?.futureDriver?.name ?? "",
                          cancellationDate:
                              vehicle?.writeOffDate.toString() ?? "",
                          fleetManager: vehicle?.manager?.name ?? "",
                          lastOdometer: vehicle?.odometer.toString() ?? "",
                          odometerUnit: vehicle?.odometerUnit ?? "",
                          location: vehicle?.location ?? "",
                          orderDate: vehicle?.orderDate.toString() ?? "",
                          chassisNo: vehicle?.vinSn.toString() ?? "",
                          registrationDate:
                              vehicle?.acquisitionDate.toString() ?? "",
                          category: vehicle?.category?.name.toString() ?? "",
                          isDarkTheme: isDarkTheme,
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: Row(
                            children: [
                              buildWidgetVehicleDetailsLog(
                                context: context,
                                headText: "Tax Info",
                                index: 0,
                                isDarkTheme: isDarkTheme,
                              ),
                              buildWidgetVehicleDetailsLog(
                                key: const Key(
                                  "test_case_switch_vehicleDetails_model_key",
                                ),
                                context: context,
                                headText: "Model",
                                index: 1,
                                isDarkTheme: isDarkTheme,
                              ),
                              buildWidgetVehicleDetailsLog(
                                key: const Key(
                                  "test_case_switch_vehicleDetails__notes_key",
                                ),
                                context: context,
                                headText: "Note",
                                index: 2,
                                isDarkTheme: isDarkTheme,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildBottomDetailsContainer(
                          context: context,
                          provider: provider,
                          isDarkTheme: isDarkTheme,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _popupMenuItem({
    required List<List<dynamic>> icon,
    required String text,
    required bool isDarkTheme,
  }) {
    return Row(
      children: [
        IconTheme.merge(
          data: IconThemeData(color: Colors.black, size: 20),
          child: HugeIcon(
            icon: icon,
            size: 20,
            color: isDarkTheme
                ? AllDesigns.whiteColor
                : AllDesigns.greyShade800Color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkTheme ? AllDesigns.whiteColor : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDetail1Container({
    required String driver,
    required String model,
    required String licensePlate,
    required String chasisno,
    required BuildContext context,
    required List<TagItem> tags,
    required String? vehicleType,
    required VehiclesDetailsProvider provider,
    required bool isDarkTheme,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkTheme ? AllDesigns.greyShade800Color : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.black
                : AllDesigns.blackColor.withOpacity(.1),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildText(
                licensePlate,
                fontSize: 18,
                color: AllDesigns.appColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              buildText(
                model,
                fontSize: 18,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.greyShade600Color,
                fontWeight: FontWeight.normal,
                letterSpacing: 0,
              ),
              Container(
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: vehicleType == 'car'
                        ? AssetImageConvert.carImage
                        : vehicleType == 'bike'
                        ? AssetImageConvert.bikeImage
                        : AssetImageConvert.emptyImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5),

              tags.isEmpty
                  ? Expanded(
                      child: buildText(
                        "No Tags",
                        fontSize: 12,
                        color: isDarkTheme
                            ? AllDesigns.red
                            : AllDesigns.greyShade600Color,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tags.map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkTheme
                                      ? AllDesigns.whiteColor
                                      : AllDesigns.blue50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AllDesigns.grey),
                                ),
                                child: buildText(
                                  tag.name,
                                  fontSize: 12,
                                  color: AllDesigns.blackColor,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetail2Container({
    required String driverName,
    required String state,
    required String mobilityCard,
    required String futureDriver,
    required String assignedDate,
    required String orderDate,
    required String registrationDate,
    required String cancellationDate,
    required String lastOdometer,
    required String fleetManager,
    required String odometerUnit,
    required String location,
    required String chassisNo,
    required VehiclesDetailsProvider provider,
    required bool isDarkTheme,
    required String category,
    required String vehicleType,
  }) {
    final formattedAssignedDate = provider.formatTextDate(assignedDate);
    final formattedOrderDate = provider.formatTextDate(orderDate);
    final formattedRegistrationDate = provider.formatTextDate(registrationDate);
    final formattedCancellationDate = provider.formatTextDate(cancellationDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.black
                : AllDesigns.blackColor.withOpacity(.1),
            offset: const Offset(0, 6),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: buildText(
                  driverName,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AllDesigns.appColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getVehicleStateColor(state).withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: buildText(
                  state,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: getVehicleStateColor(state),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          buildRowWidget(
            keyText: "Driver",
            valueText: provider.displayValue(driverName),
            icon: HugeIcons.strokeRoundedPrisonGuard,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Future Driver",
            valueText: provider.displayValue(futureDriver),
            icon: HugeIcons.strokeRoundedUserMinus01,
            isDarkTheme: isDarkTheme,
          ),
          if (vehicleType == 'car')
            Row(
              children: [
                buildIcon(
                  icon: HugeIcons.strokeRoundedCar05,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade700Color,
                  size: 15,
                ),
                const SizedBox(width: 8),
                buildText(
                  "Plan To Change Car",
                  fontSize: 13,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  fontWeight: FontWeight.w400,
                ),
                const Spacer(),
                Checkbox(
                  value: provider.planToChangeCar,
                  onChanged: null,
                  checkColor: AllDesigns.whiteColor,
                  activeColor: AllDesigns.appColor,
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AllDesigns.appColor;
                    }
                    return AllDesigns.whiteColor;
                  }),
                ),
              ],
            ),
          if (vehicleType == 'bike')
            Row(
              children: [
                buildIcon(
                  icon: HugeIcons.strokeRoundedScooter03,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade700Color,
                  size: 15,
                ),
                const SizedBox(width: 8),
                buildText(
                  "Plan To Change Bike",
                  fontSize: 13,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                  fontWeight: FontWeight.w400,
                ),
                const Spacer(),
                Checkbox(
                  value: provider.planToChangeBike,
                  onChanged: null,
                  checkColor: AllDesigns.whiteColor,
                  activeColor: AllDesigns.appColor,
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AllDesigns.appColor;
                    }
                    return AllDesigns.whiteColor;
                  }),
                ),
              ],
            ),

          buildRowWidget(
            keyText: "Assignment Date",
            valueText: provider.displayValue(formattedAssignedDate),
            icon: HugeIcons.strokeRoundedCalendar03,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Category",
            valueText: provider.displayValue(category),
            icon: HugeIcons.strokeRoundedIdentityCard,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Order Date",
            valueText: provider.displayValue(formattedOrderDate),
            icon: HugeIcons.strokeRoundedCalendar03,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Registration Date",
            valueText: provider.displayValue(formattedRegistrationDate),
            icon: HugeIcons.strokeRoundedCalendar03,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Cancellation Date",
            valueText: provider.displayValue(formattedCancellationDate),
            icon: HugeIcons.strokeRoundedCalendar03,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Chassis Number",
            valueText: provider.displayValue(chassisNo),
            icon: HugeIcons.strokeRoundedIdentityCard,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Last Odometer",
            valueText: '${provider.displayValue(lastOdometer)}  $odometerUnit',
            icon: HugeIcons.strokeRoundedDashboardSpeed02,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Fleet Manager",
            valueText: provider.displayValue(fleetManager),
            icon: HugeIcons.strokeRoundedPrisonGuard,
            isDarkTheme: isDarkTheme,
          ),
          buildRowWidget(
            keyText: "Location",
            valueText: provider.displayValue(location),
            icon: HugeIcons.strokeRoundedLocation04,
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

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
            buildIcon(
              icon: icon,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
              size: 15,
            ),
            const SizedBox(width: 8),
            buildText(
              keyText.toString(),
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
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow({
    required List<List<dynamic>> icon,
    required String text,
    required bool isDarkTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildIcon(
          icon: icon,
          onTap: null,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade700Color,
          size: 20,
        ),
        Expanded(
          child: buildText(
            color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            text,
            fontSize: 12,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _doubleInfoRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        Expanded(child: right),
      ],
    );
  }

  Widget buildBottomDetailsContainer({
    required BuildContext context,
    required VehiclesDetailsProvider provider,
    required bool isDarkTheme,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height * 0.5,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
        boxShadow: [
          BoxShadow(
            color: isDarkTheme
                ? Colors.black
                : AllDesigns.blackColor.withOpacity(.1),
            offset: const Offset(0, 6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildSelectedContent(
                provider.selectedVehicleDetailsIndex,
                isDarkTheme,
                provider,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (provider.isTaxInfoEdit ||
              provider.isModelInfoEdit ||
              provider.isNotesInfoEdit) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: provider.isVehiclesDetailsUpdating
                  ? null
                  : () async {
                      final vehiclesProvider = context.read<VehiclesProvider>();
                      final dashboardProvider = context
                          .read<DashboardProvider>();

                      final bool success = await provider
                          .updateVehicleDetails();
                      if (!mounted) return;
                      if (success) {
                        await vehiclesProvider.fetchVehicles(domain: []);

                        Navigator.of(context).pop(true);

                        CustomSnackbar.showSuccess(
                          context,
                          "Vehicle updated successfully",
                        );
                        await dashboardProvider.refreshDashboard(context);
                      } else {
                        CustomSnackbar.showError(
                          context,
                          "Vehicle update failed",
                        );
                      }
                      provider.editClearFunction();
                      provider.closeAllDropdowns();
                    },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: provider.isVehiclesDetailsUpdating
                      ? AllDesigns.greyShade300Color
                      : AllDesigns.appColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isVehiclesDetailsUpdating) ...[
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: AllDesigns.whiteColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      buildText(
                        "Updating...",
                        fontSize: 16,
                        color: AllDesigns.whiteColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ] else ...[
                      buildIcon(
                        icon: HugeIcons.strokeRoundedFileAdd,
                        color: provider.isVehiclesDetailsUpdating
                            ? AllDesigns.black54
                            : AllDesigns.whiteColor,
                        size: 25,
                      ),
                      const SizedBox(width: 8),
                      buildText(
                        "Update",
                        fontSize: 20,
                        color: provider.isVehiclesDetailsUpdating
                            ? AllDesigns.greyShade700Color
                            : AllDesigns.whiteColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget buildWidgetVehicleDetailsLog({
    Key? key,
    required BuildContext context,
    required String? headText,
    required int index,
    required bool isDarkTheme,
  }) {
    final provider = context.watch<VehiclesDetailsProvider>();
    final bool isSelected = provider.selectedVehicleDetailsIndex == index;
    return InkWell(
      onTap: () => provider.setSelectedVehicleDetailsLog(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        key: key,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? AllDesigns.blackColor : AllDesigns.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkTheme
                  ? AllDesigns.blackColor
                  : AllDesigns.blackColor.withOpacity(.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 100),
          child: buildText(
            headText ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            color: isSelected ? AllDesigns.whiteColor : AllDesigns.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContent(
    int index,
    bool isDarkTheme,
    VehiclesDetailsProvider provider,
  ) {
    switch (index) {
      case 0:
        return _buildTaxInfoWidget(isDarkTheme: isDarkTheme);
      case 1:
        return _buildModelWidget(isDarkTheme: isDarkTheme, provider: provider);
      case 2:
        return _buildNotesWidget(isDarkTheme: isDarkTheme);
      default:
        return Container();
    }
  }

  Widget _buildTaxInfoWidget({required bool isDarkTheme}) {
    final provider = Provider.of<VehiclesDetailsProvider>(
      context,
      listen: false,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildIcon(
                key: Key('edit_tax_info_icon'),
                onTap: () => provider.toggleTaxInfoEditMode(),
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: provider.isTaxInfoEdit
                    ? AllDesigns.appColor
                    : isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildTextData(
            "FISCALITY",
            fontWeight: FontWeight.w700,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextData(
            "Horse Power Taxation",
            fontWeight: FontWeight.w300,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextFormField(
            controller: provider.horsePowerTaxationController,
            readOnly: !provider.isTaxInfoEdit,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 15),
          buildTextData(
            "CONTRACT",
            fontWeight: FontWeight.w700,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          _widgetVehiclesDatePicker(
            readonly: !provider.isTaxInfoEdit,
            provider: provider,
            text: "First Contract Date",
            controller: provider.firstContractDateController,
            isDarkTheme: isDarkTheme,
          ),

          const SizedBox(height: 10),
          buildTextData(
            "Catalog Value (VAT Incl.)",
            fontWeight: FontWeight.w300,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextFormField(
            controller: provider.catalogValueController,
            readOnly: !provider.isTaxInfoEdit,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
          buildTextData(
            "Purchase Value",
            fontWeight: FontWeight.w300,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextFormField(
            controller: provider.purchaseValueController,
            readOnly: !provider.isTaxInfoEdit,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
          buildTextData(
            "Residual Value",
            fontWeight: FontWeight.w300,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextFormField(
            controller: provider.residualValueController,
            readOnly: !provider.isTaxInfoEdit,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildModelWidget({
    required bool isDarkTheme,
    required VehiclesDetailsProvider provider,
  }) {
    return SingleChildScrollView(
      key: Key("test_case_model_widget_key"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildIcon(
                onTap: () => provider.toggleModelInfoEdit(),
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: provider.isModelInfoEdit
                    ? AllDesigns.appColor
                    : isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildTextData(
            "MODEL",
            fontWeight: FontWeight.w700,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          commonDropDownWidgetCard<int>(
            headText: "",
            subText: "Model Year",
            leadingIcon: HugeIcons.strokeRoundedCalendar01,
            controller: provider.modelYearController,
            hintText: "Select Year",
            dropdownIcon: HugeIcons.strokeRoundedArrowDown01,
            showDropdown: provider.showYearDropdown,
            isModelEdit: provider.isModelInfoEdit,
            isLoading: false,
            items: provider.filteredYears,
            titleBuilder: (year) => year.toString(),
            onSearch: provider.filterYears,
            onFieldTap: provider.toggleYearDropdown,
            onItemTap: provider.selectYear,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 15),
          buildTextData(
            "Color",
            fontWeight: FontWeight.w300,
            isDarkTheme: isDarkTheme,
          ),
          const SizedBox(height: 10),
          buildTextFormField(
            controller: provider.modelColorController,
            readOnly: !provider.isModelInfoEdit,
          ),
          const SizedBox(height: 15),
          if (provider.isCar) ...[
            buildTextData(
              "Seating Capacity",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.modelSeatingCapacityController,
              readOnly: !provider.isModelInfoEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 15),
            buildTextData(
              "Number of Doors",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.modelNoOfDoorsController,
              readOnly: !provider.isModelInfoEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            Row(
              children: [
                buildTextData(
                  "Trailer Hitch",
                  fontWeight: FontWeight.w300,
                  isDarkTheme: isDarkTheme,
                ),
                const SizedBox(height: 20),
                Checkbox(
                  value: provider.isChecked,
                  onChanged: (bool? value) {
                    provider.trailerHitchedToggle(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            buildTextData(
              "ENGINE",
              fontWeight: FontWeight.w700,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            commonDropDownWidgetCard<FuelTypeSelectionItem>(
              headText: "",
              subText: "Fuel Type",
              controller: provider.engineFuelTypeController,
              hintText: "",
              dropdownIcon: HugeIcons.strokeRoundedArrowDown01,
              showDropdown: provider.showFuelTypeDropdown,
              isModelEdit: provider.isModelInfoEdit,
              isLoading: provider.isFuelTypeLoading,
              items: provider.filteredFuelTypes,
              titleBuilder: (item) => item.label,
              onSearch: provider.filterFuelTypes,
              onFieldTap: provider.toggleFuelTypeDropdown,
              onItemTap: provider.selectFuelType,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 5),
            commonDropDownWidgetCard<TransmissionTypeSelectionItem>(
              headText: "",
              subText: "Transmission Type",
              controller: provider.engineTransmissionController,
              hintText: "",
              dropdownIcon: HugeIcons.strokeRoundedArrowDown01,
              showDropdown: provider.showTransmissionDropDown,
              isModelEdit: provider.isModelInfoEdit,
              isLoading: provider.isTransmissionTypeLoading,
              items: provider.filteredTransmissionTypes,
              titleBuilder: (item) => item.label,
              onSearch: provider.filterTransmissionTypes,
              onFieldTap: provider.toggleTransmissionTypeDropDown,
              onItemTap: provider.selectTransmissionType,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextData(
              "Power",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.enginePowerController,
              readOnly: !provider.isModelInfoEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            buildTextData(
              "Range",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.engineRangeController,
              readOnly: !provider.isModelInfoEdit,
            ),
            const SizedBox(height: 10),
            buildTextData(
              "CO₂ Emissions",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.engineC02EmissionController,
              readOnly: !provider.isModelInfoEdit,
            ),
            const SizedBox(height: 10),
            buildTextData(
              "Emission Standard",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.engineEmissionStandardController,
              readOnly: !provider.isModelInfoEdit,
            ),
          ],
          const SizedBox(height: 15),
          if (provider.isBike) ...[
            commonDropDownWidgetCard<BikeFrameTypeItem>(
              headText: "",
              subText: "Bike Frame Type",
              controller: provider.bikeFrameTypeController,
              hintText: "Select Frame Type",
              dropdownIcon: HugeIcons.strokeRoundedArrowDown01,
              showDropdown: provider.showBikeFrameTypeDropdown,
              isModelEdit: provider.isModelInfoEdit,
              isLoading: provider.isBikeFrameTypeLoading,
              items: provider.filteredBikeFrameTypes,
              titleBuilder: (item) => item.label,
              onSearch: provider.filterBikeFrameTypes,
              onFieldTap: provider.toggleBikeFrameTypeDropdown,
              onItemTap: provider.selectBikeFrameType,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextData(
              "Frame Size (cm)",
              fontWeight: FontWeight.w300,
              isDarkTheme: isDarkTheme,
            ),
            const SizedBox(height: 10),
            buildTextFormField(
              controller: provider.bikeFrameSizeController,
              readOnly: !provider.isModelInfoEdit,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                buildTextData(
                  "Electric Assistance",
                  fontWeight: FontWeight.w300,
                  isDarkTheme: isDarkTheme,
                ),
                const Spacer(),
                Checkbox(
                  value: provider.hasElectricAssistance,
                  onChanged: provider.isModelInfoEdit
                      ? provider.toggleElectricAssistance
                      : null,
                  activeColor: AllDesigns.appColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesWidget({required bool isDarkTheme}) {
    final provider = Provider.of<VehiclesDetailsProvider>(
      context,
      listen: false,
    );

    final String notes = provider.vehicleDetailsNotes.text.trim();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildIcon(
                onTap: () {
                  if (!provider.isNotesInfoEdit) {
                    provider.vehicleDetailsNotes.text = provider.stripHtmlTags(
                      provider.vehicleDetailsNotes.text,
                    );
                  }
                  provider.toggleNotesInfoEdit();
                },
                icon: HugeIcons.strokeRoundedPencilEdit01,
                color: provider.isNotesInfoEdit
                    ? AllDesigns.appColor
                    : isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
                size: 25,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.isNotesInfoEdit)
            buildTextFormField(
              controller: provider.vehicleDetailsNotes,
              maxLines: 6,
            )
          else
            notes.isEmpty
                ? buildText(
                    "No notes available",
                    fontSize: 14,
                    color: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.greyShade600Color,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Html(
                          data: notes,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(14),
                              color: AllDesigns.blackColor,
                            ),
                          },
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }

  Widget commonDropDownWidgetCard<T>({
    required String headText,
    required String subText,
    List<List<dynamic>>? leadingIcon,
    required TextEditingController controller,
    required VoidCallback onFieldTap,
    required ValueChanged<String> onSearch,
    required String hintText,
    required List<List<dynamic>> dropdownIcon,
    required bool showDropdown,
    required bool isLoading,
    required bool isModelEdit,
    required List<T> items,
    required String Function(T item) titleBuilder,
    String Function(T item)? subtitleBuilder,
    required void Function(T item) onItemTap,
    String emptyText = "No data found",
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(
              subText,
              fontSize: 16,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
              fontWeight: FontWeight.w300,
              letterSpacing: 0,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller,
              onTap: onFieldTap,
              onChanged: onSearch,
              decoration: InputDecoration(
                prefixIcon: leadingIcon == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: buildIcon(
                          icon: leadingIcon,
                          color: isDarkTheme
                              ? AllDesigns.whiteColor
                              : AllDesigns.greyShade700Color,
                          size: 22,
                        ),
                      ),

                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),

                suffixIcon: GestureDetector(
                  onTap: onFieldTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: buildIcon(
                      icon: dropdownIcon,
                      color: AllDesigns.greyShade700Color,
                      size: 22,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),

                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AllDesigns.greyShade700Color,
                  letterSpacing: 0,
                ),
                filled: true,
                fillColor: AllDesigns.greyShade300Color.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (showDropdown && isModelEdit && controller.text.trim().isEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: AllDesigns.greyShade300Color),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                    ? Center(
                        child: Text(
                          emptyText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AllDesigns.greyShade300Color,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            onTap: () => onItemTap(item),
                            title: Text(titleBuilder(item)),
                            subtitle: subtitleBuilder == null
                                ? null
                                : Text(subtitleBuilder(item)),
                          );
                        },
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    bool readOnly = false,
    int? maxLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: AllDesigns.greyShade300Color.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AllDesigns.appColor),
        ),
      ),
    );
  }

  Widget _widgetVehiclesDatePicker({
    required TextEditingController controller,
    required VehiclesDetailsProvider provider,
    String? text,
    required bool readonly,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text.toString(),
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: readonly,
          onTap: () {
            !readonly ? provider.chooseDate(context, controller) : null;
          },
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: buildIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.greyShade700Color,
                size: 25,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AllDesigns.greyShade300Color.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget buildText(
    String text, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double letterSpacing = 0,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }

  Widget buildTextData(
    String text, {
    FontWeight fontWeight = FontWeight.w400,
    required bool isDarkTheme,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: fontWeight,
        color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
        letterSpacing: 1,
      ),
    );
  }

  Widget buildIcon({
    required List<List<dynamic>> icon,
    required Color color,
    required double size,
    VoidCallback? onTap,
    Key? key,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: HugeIcon(icon: icon, size: size, color: color, key: key),
      ),
    );
  }

  Widget _buildVehicleDetailsShimmer(BuildContext context, bool isDarkTheme) {
    final size = MediaQuery.of(context).size;
    final baseColor = isDarkTheme
        ? AllDesigns.greyShade800Color
        : Colors.grey.shade300;

    final highlightColor = isDarkTheme
        ? AllDesigns.greyShade700Color
        : Colors.grey.shade100;

    final cardColor = isDarkTheme ? AllDesigns.greyShade800Color : Colors.white;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            _shimmerCard(
              height: 260,
              cardColor: cardColor,
              child: Column(
                children: [
                  _shimmerLine(width: 120, height: 18),
                  const SizedBox(height: 8),
                  _shimmerLine(width: 160, height: 16),
                  const SizedBox(height: 16),
                  _shimmerBox(width: 150, height: 100),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _shimmerLine(width: 50),
                      const SizedBox(width: 10),
                      Expanded(child: _shimmerLine()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _shimmerCard(
              cardColor: cardColor,
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerLine(width: 180, height: 20),
                  const SizedBox(height: 16),
                  _shimmerInfoRow(),
                  _shimmerInfoRow(),
                  _shimmerInfoRow(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _shimmerLine()),
                      const SizedBox(width: 16),
                      Expanded(child: _shimmerLine()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _shimmerLine()),
                      const SizedBox(width: 16),
                      Expanded(child: _shimmerLine()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _shimmerCard(
              height: size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _shimmerPill(),
                      const SizedBox(width: 10),
                      _shimmerPill(),
                      const SizedBox(width: 10),
                      _shimmerPill(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      children: List.generate(
                        6,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _shimmerLine(height: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              cardColor: cardColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({
    required double height,
    required Widget child,
    required Color cardColor,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _shimmerLine({double width = double.infinity, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _shimmerInfoRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _shimmerBox(width: 22, height: 22),
          const SizedBox(width: 8),
          Expanded(child: _shimmerLine()),
        ],
      ),
    );
  }

  Widget _shimmerPill() {
    return Container(
      width: 90,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

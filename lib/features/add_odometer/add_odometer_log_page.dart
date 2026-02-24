import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart'
    as Drivers;
import '../../core/designs/custom_designs.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';

class AddOdometerLogPage extends StatefulWidget {
  const AddOdometerLogPage({super.key});

  @override
  State<AddOdometerLogPage> createState() => _AddOdometerLogPageState();
}

class _AddOdometerLogPageState extends State<AddOdometerLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddOdometerLogProvider>(
        context,
        listen: false,
      );
      provider.setTodayDateIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final Color commonFillColor = isDarkTheme
        ? AllDesigns.greyShade300Color.withOpacity(0.4)
        : AllDesigns.greyShade300Color.withOpacity(0.5);

    return Consumer<AddOdometerLogProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.blackColor,
                  size: 25,
                ),
                onPressed: () {
                  provider.resetData();
                  Navigator.pop(context);
                },
              ),
            ),
            title: buildText(
              text: "Create Odometer Log",
              fontSize: 20,
              color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                createOdometerLogInfoCard(
                  isDarkTheme: isDarkTheme,
                  title: "Add Odometer Log",
                  children: [
                    _widgetDatePicker(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    commonTypeAhead<VehicleItem>(
                      fillColor: commonFillColor,
                      label: "Vehicle",
                      controller: provider.vehicleController,
                      isDarkTheme: isDarkTheme,

                      suggestionsCallback: provider.searchVehicles,
                      suggestionItemBuilder: (context, vehicle) {
                        return ListTile(
                          tileColor: isDarkTheme
                              ? AllDesigns.greyShade800Color
                              : Colors.white,
                          leading: Icon(
                            vehicle.vehicleType == 'car'
                                ? Icons.directions_car
                                : Icons.two_wheeler,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                          title: Text(
                            vehicle.model.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text("Plate: ${vehicle.licensePlate}"),
                        );
                      },
                      onSelected: provider.selectVehicle,
                      fieldBuilder: (context, controller, focusNode) {
                        final Color fieldFillColor = commonFillColor;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          cursorColor: isDarkTheme
                              ? Colors.white
                              : Colors.black,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Vehicle",
                            hintStyle: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade500Color,
                            ),
                            prefixIcon: Icon(
                              Icons.directions_car,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade700Color,
                            ),
                            filled: true,
                            fillColor: fieldFillColor,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    commonTypeAhead<Drivers.Record>(
                      label: "Driver",
                      controller: provider.driverController,
                      isDarkTheme: isDarkTheme,
                      suggestionsCallback: provider.searchDrivers,
                      fillColor: commonFillColor,

                      suggestionItemBuilder: (context, driver) {
                        Uint8List? imageBytes;

                        if (driver.avatar128 != null &&
                            driver.avatar128!.isNotEmpty) {
                          try {
                            imageBytes = base64Decode(driver.avatar128!);
                          } catch (_) {}
                        }

                        return ListTile(
                          tileColor: isDarkTheme
                              ? AllDesigns.greyShade800Color
                              : Colors.white,
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: AllDesigns.greyShade300Color,
                            backgroundImage: imageBytes != null
                                ? MemoryImage(imageBytes)
                                : null,
                            child: imageBytes == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.black87,
                                  )
                                : null,
                          ),
                          title: Text(
                            driver.completeName ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.blackColor,
                            ),
                          ),
                          subtitle: Text(
                            driver.phone ?? "",
                            style: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : Colors.black54,
                            ),
                          ),
                        );
                      },

                      onSelected: provider.selectDriver,

                      fieldBuilder: (context, controller, focusNode) {
                        final Color fieldFillColor = commonFillColor;

                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          cursorColor: isDarkTheme
                              ? Colors.white
                              : Colors.black,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search Driver",
                            hintStyle: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade500Color,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade700Color,
                            ),
                            filled: true,
                            fillColor: fieldFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _widgetFutureDriver(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetOdometerValue(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                      commonFillColor: commonFillColor,
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: (provider.isSaveLoading || !provider.canSave)
                          ? null
                          : () async {
                              final success = await provider
                                  .createOdometerLog();
                              if (!success) {
                                CustomSnackbar.showError(
                                  context,
                                  "Failed to add odometer log",
                                );
                                return;
                              }
                              final activityProvider = context
                                  .read<ActivityPageProvider>();

                              activityProvider.setSelectedActivityLog(
                                ActivityTabs.odometer,
                              );

                              await activityProvider
                                  .fetchOdometerActivityDetails(
                                    resetPage: true,
                                  );

                              Navigator.pop(context);

                              CustomSnackbar.showSuccess(
                                context,
                                "Odometer log added successfully",
                              );
                            },

                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: provider.isSaveLoading
                              ? AllDesigns.appColor
                              : provider.canSave
                              ? AllDesigns.appColor
                              : AllDesigns.greyShade300Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (provider.isSaveLoading) ...[
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: AllDesigns.whiteColor,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              buildText(
                                text: "Adding...",
                                fontSize: 16,
                                color: AllDesigns.whiteColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ] else ...[
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedFileAdd,
                                color: AllDesigns.whiteColor,
                                size: 25,
                              ),
                              const SizedBox(width: 8),
                              buildText(
                                text: "Add odometer log",
                                fontSize: 18,
                                color: AllDesigns.whiteColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _widgetFutureDriver({
    required AddOdometerLogProvider provider,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: "Driver (Employee)",
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: provider.driverEmployeeController,
          readOnly: true,
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Select Driver Employee",
            hintStyle: TextStyle(
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
            ),
            filled: true,
            fillColor: AllDesigns.greyShade300Color.withOpacity(0.4),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget commonTypeAhead<T>({
    required String label,
    required TextEditingController controller,
    required bool isDarkTheme,
    required Color fillColor,

    required Future<List<T>> Function(String) suggestionsCallback,
    required Widget Function(BuildContext, T) suggestionItemBuilder,
    required void Function(T) onSelected,
    required Widget Function(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusNode,
    )
    fieldBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: label,
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TypeAheadField<T>(
          constraints: BoxConstraints(maxHeight: 220),
          controller: controller,
          debounceDuration: const Duration(milliseconds: 300),
          suggestionsCallback: suggestionsCallback,
          itemBuilder: suggestionItemBuilder,
          onSelected: onSelected,
          builder: fieldBuilder,
          emptyBuilder: (context) {
            return ListTile(
              tileColor: AllDesigns.whiteColor,
              title: Text("No data found"),
            );
          },
          loadingBuilder: (context) {
            return Material(
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _widgetOdometerValue({
    required AddOdometerLogProvider provider,
    required bool isDarkTheme,
    required Color commonFillColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: "Odometer Value",
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),

        const SizedBox(height: 10),
        TextFormField(
          controller: provider.odometerController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}$'), // allows decimals safely
            ),
          ],
          onChanged: provider.setOdometerValue,
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Enter odometer value",
            hintStyle: TextStyle(
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
            ),
            prefixIcon: Icon(
              Icons.speed,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
            ),
            filled: true,
            fillColor: commonFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildText({
    required String? text,
    required double? fontSize,
    required Color color,
    required FontWeight fontWeight,
    required double? letterSpacing,
  }) {
    return Text(
      text ?? "",
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }

  Widget createOdometerLogInfoCard({
    required String title,
    required List<Widget> children,
    required bool isDarkTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            spreadRadius: 2,
            blurRadius: 10,
            color: isDarkTheme ? AllDesigns.blackColor : Colors.grey.shade300,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: buildText(
              letterSpacing: 0,
              text: title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
            ),
          ),

          Divider(
            color: isDarkTheme ? AllDesigns.whiteColor : Colors.grey.shade200,
            indent: 10,
            endIndent: 10,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _widgetDatePicker({
    required AddOdometerLogProvider provider,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: "Date",
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: provider.dateController,
          readOnly: true,
          onTap: () {
            provider.chooseDate(context);
          },
          decoration: InputDecoration(
            hintText: "Select the Date",
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.greyShade700Color,
                size: 22,
              ),
            ),
            filled: true,
            fillColor: AllDesigns.greyShade300Color.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

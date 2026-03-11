import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/models/model_vendors_list.dart';
import 'package:mobo_projects/models/model_add_log_drivers_list.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/add_service_fuel/add_service_fuel_log_provider.dart';
import 'package:mobo_projects/shared/services/review_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../../shared/widgets/snackbars/custom_snackbar.dart';

class AddServiceFuelLogPage extends StatefulWidget {
  const AddServiceFuelLogPage({super.key});

  @override
  State<AddServiceFuelLogPage> createState() => _AddServiceFuelLogPageState();
}

class _AddServiceFuelLogPageState extends State<AddServiceFuelLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AddServiceFuelLogProvider>(
        context,
        listen: false,
      );
      provider.fetchVehiclesList();
      provider.fetchServiceList();
      provider.fetchVendorsList();
      provider.fetchDriversList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AddServiceFuelLogProvider>(
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
                  provider.resetFieldForm();
                  Navigator.pop(context);
                },
              ),
            ),
            title: buildText(
              text: "Create Service / Fuel Log",
              fontSize: 20,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
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
                createFuelLogInfoCard(
                  isDarkTheme: isDarkTheme,
                  title: "Add Fuel / Service Log",
                  children: [
                    _widgetServiceTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      mainText: "Description (Optional)",
                      controller: provider.descriptionController,
                      hintText: "Enter the description",
                      inputFormatters: [],
                      keyboardType: TextInputType.text,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard<VehicleItem>(
                      headText: "Vehicle Information",
                      subText: "Vehicles",
                      leadingIcon: HugeIcons.strokeRoundedCar05,
                      controller: provider.vehicleController,
                      hintText: "Select Vehicle",
                      dropdownIcon: provider.showVehicleList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showVehicleList,
                      isLoading: provider.isVehicleLoading,
                      items: provider.filteredVehicles,
                      onFieldTap: () => provider.toggleVehicleList(context),
                      onSearch: provider.updateVehicleSearch,
                      onItemTap: provider.selectVehicle,
                      titleBuilder: (v) => v.model.name,
                      subtitleBuilder: (v) => "Plate: ${v.licensePlate}",
                      isDarkTheme: isDarkTheme,
                    ),

                    if (provider.vehicleError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Vehicle is required",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard(
                      headText: "Service Information",
                      subText: "Services",
                      leadingIcon: HugeIcons.strokeRoundedTools,
                      controller: provider.serviceTypeController,
                      onFieldTap: () => provider.toggleServiceList(context),
                      onSearch: provider.updateServiceTypeSearch,
                      hintText: "Select Service Type",
                      dropdownIcon: provider.showServiceList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showServiceList,
                      isLoading: provider.isServiceLoading,
                      items: provider.filteredServiceTypes,
                      titleBuilder: (v) => v.name,
                      onItemTap: provider.selectServiceType,
                      isDarkTheme: isDarkTheme,
                    ),
                    if (provider.serviceError)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Service type is required",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard<DriverItem>(
                      headText: "Driver Information",
                      subText: "Drivers",
                      leadingIcon: HugeIcons.strokeRoundedUser,
                      controller: provider.driverController,
                      hintText: "Select Driver",
                      dropdownIcon: provider.showDriversList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showDriversList,
                      isLoading: provider.isDriverLoading,
                      items: provider.filteredDrivers,
                      onFieldTap: provider.toggleDriversList,
                      onSearch: provider.updateDriverSearch,
                      onItemTap: provider.selectDriver,
                      titleBuilder: (d) => d.name,
                      subtitleBuilder: (d) => d.phone,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetServiceDatePicker(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetServiceTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      mainText: "Odometer Value",
                      controller: provider.odometerController,
                      hintText: "Enter the Odometer value",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      isDarkTheme: isDarkTheme,
                    ),

                    const SizedBox(height: 10),
                    _widgetServiceTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      mainText: "Cost",
                      controller: provider.costController,
                      hintText: "Enter the cost",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard(
                      headText: "Vendor Information",
                      subText: "Vendors",
                      leadingIcon: HugeIcons.strokeRoundedTools,
                      controller: provider.vendorController,
                      onFieldTap: provider.toggleVendorsList,
                      onSearch: provider.updateVendorsSearch,
                      hintText: "Select Vendors",
                      dropdownIcon: provider.showVendorsList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showVendorsList,
                      isLoading: provider.isVendorLoading,
                      items: provider.filteredVendors,
                      titleBuilder: (v) => v?.name ?? "",
                      onItemTap: provider.selectVendor,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetServiceTextFormFieldWidget(
                      maxLines: 3,
                      provider: provider,
                      mainText: "Notes",
                      controller: provider.notesController,
                      hintText: "Enter the Description",
                      inputFormatters: [],
                      keyboardType: TextInputType.text,
                      isDarkTheme: isDarkTheme,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: provider.isSaveLoading
                      ? null
                      : () async {
                          if (!provider.validateRequiredFields()) {
                            CustomSnackbar.showError(
                              context,
                              "Please fill required fields",
                            );
                            return;
                          }
                          provider.validateTypedVehicle(context);
                          provider.validateTypedService(context);

                          if (provider.selectedVehicle == null ||
                              provider.selectedServiceType == null) {
                            return;
                          }

                          final success = await provider.createServiceLog();

                          if (!success) {
                            CustomSnackbar.showError(
                              context,
                              "Create fuel log unsuccessful",
                            );
                            return;
                          }
                          final activityProvider = context
                              .read<ActivityPageProvider>();
                          activityProvider.setSelectedActivityLog(
                            ActivityTabs.service,
                          );
                          activityProvider.fetchFuelLogActivity();
                          activityProvider.fetchServiceActivityDetails();

                          Navigator.pop(context);

                          CustomSnackbar.showSuccess(
                            context,
                            "Successfully added into the Service",
                          );
                          await ReviewService().trackSignificantEvent();
                          ReviewService().checkAndShowRating(context);
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
                            color: provider.canSave
                                ? AllDesigns.whiteColor
                                : AllDesigns.whiteColor,
                            size: 25,
                          ),
                          const SizedBox(width: 8),
                          buildText(
                            text: "Add fuel log",
                            fontSize: 20,
                            color: provider.canSave
                                ? AllDesigns.whiteColor
                                : AllDesigns.whiteColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  ///Widget Vendor Avatar
  Widget _buildVendorAvatar(VendorItem vendor) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AllDesigns.greyShade300Color,
      backgroundImage: vendor.avatar128 != null
          ? MemoryImage(vendor.avatar128!)
          : null,
      child: vendor.avatar128 == null
          ? const Icon(Icons.store, color: Colors.black54)
          : null,
    );
  }

  /// Text Widget
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

  /// Service / Fuel info card
  Widget createFuelLogInfoCard({
    required String title,
    required List<Widget> children,
    required bool isDarkTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme
            ? AllDesigns.greyShade800Color
            : AllDesigns.whiteColor,
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
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
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

  /// Widget Service TextFormField
  Widget _widgetServiceTextFormFieldWidget({
    required AddServiceFuelLogProvider provider,
    required String? mainText,
    required TextEditingController controller,
    List<List<dynamic>>? icon,
    required String? hintText,
    required List<TextInputFormatter>? inputFormatters,
    required TextInputType? keyboardType,
    required int? maxLines,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: mainText,
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefix: icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: HugeIcon(
                      icon: icon,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.greyShade700Color,
                      size: 22,
                    ),
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
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
              letterSpacing: 0,
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

  /// Widget Date Picker
  Widget _widgetServiceDatePicker({
    required AddServiceFuelLogProvider provider,
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
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
              letterSpacing: 0,
            ),
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

  /// Widget common DropDown
  Widget commonDropDownWidgetCard<T>({
    required String headText,
    required String subText,
    required List<List<dynamic>> leadingIcon,
    required TextEditingController controller,
    required VoidCallback onFieldTap,
    required ValueChanged<String> onSearch,
    required String hintText,
    required List<List<dynamic>> dropdownIcon,
    required bool showDropdown,
    required bool isLoading,
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
        buildText(
          text: subText,
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          onTap: onFieldTap,
          onChanged: onSearch,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: HugeIcon(
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
                child: HugeIcon(
                  icon: dropdownIcon,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade700Color,
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
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
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

        if (showDropdown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDarkTheme
                    ? AllDesigns.greyShade800Color
                    : Colors.white,
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
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          onTap: () => onItemTap(item),

                          leading: item is DriverItem
                              ? _buildDriverAvatar(item)
                              : item is VendorItem
                              ? _buildVendorAvatar(item)
                              : null,

                          title: Text(
                            titleBuilder(item),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: subtitleBuilder == null
                              ? null
                              : Text(subtitleBuilder(item)),
                        );
                      },
                    ),
            ),
          ),
      ],
    );
  }

  /// Driver image view
  Widget _buildDriverAvatar(DriverItem driver) {
    Uint8List? imageBytes;
    if (driver.avatar128 != null && driver.avatar128!.isNotEmpty) {
      try {
        imageBytes = base64Decode(driver.avatar128!);
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AllDesigns.greyShade300Color,
      backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
      child: imageBytes == null
          ? const Icon(Icons.person, color: Colors.black54)
          : null,
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';
import 'package:mobo_projects/core/designs/widget_snackbar.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';

import 'package:mobo_projects/models/model_fetch_fleet_manager.dart';
import 'package:mobo_projects/models/model_fetch_vehicle_category.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:mobo_projects/shared/services/review_service.dart';
import 'package:provider/provider.dart';
import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart'
    as Driverfetch;
import '../../models/model_vehicles_list.dart';

class EditVehiclesDetailsPage extends StatefulWidget {
  final int vehicleId;

  EditVehiclesDetailsPage({super.key, required this.vehicleId});

  @override
  State<EditVehiclesDetailsPage> createState() =>
      _EditVehiclesDetailsPageState();
}

class _EditVehiclesDetailsPageState extends State<EditVehiclesDetailsPage> {
  bool get isEditMode => widget.vehicleId > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VehiclesDetailsProvider>();

      if (isEditMode) {
        provider.fetchVehicleDetails(widget.vehicleId);
      } else {
        provider.initializeAddVehicle();
        provider.fetchVehicleCategories();
      }
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
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: SizedBox(
              height: 36,
              width: 36,
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
              isEditMode ? "Edit Vehicles Details" : "Add Vehicle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
              ),
            ),
          ),
          body: SingleChildScrollView(
            key: const Key('test_case_singleChildScroll_key'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                vehicleInfoCard(
                  title: "Vehicle Information",
                  isDarkTheme: isDarkTheme,
                  children: [
                    commonDropDownWidgetCard<VehicleItem>(
                      headText: "Vehicle Information",
                      subText: "Model *",
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
                    const SizedBox(height: 10),
                    _widgetVehiclesTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      "License Plate",
                      controller: provider.licensePlateController,
                      icon: HugeIcons.strokeRoundedIdentityCard,
                      hintText: "Enter license plate number",
                      inputFormatters: [],
                      keyboardType: TextInputType.text,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    buildEditTagsCard(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                vehicleInfoCard(
                  isDarkTheme: isDarkTheme,
                  title: "Driver Information",
                  children: [
                    commonDropDownWidgetCard<Driverfetch.Record>(
                      headText: "Driver Information",
                      subText: "Driver",
                      leadingIcon: HugeIcons.strokeRoundedUser,
                      controller: provider.driverController,
                      hintText: "Select Driver",
                      dropdownIcon: provider.showDriverList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showDriverList,
                      isLoading: provider.isDriverLoading,
                      items: provider.filteredDrivers,
                      onFieldTap: provider.toggleDriverList,
                      onSearch: provider.updateDriverSearch,
                      onItemTap: provider.selectDriver,
                      titleBuilder: (d) => d.completeName ?? "Unknown",
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard<Driverfetch.Record>(
                      headText: "Future Driver Information",
                      subText: "Future Driver",
                      leadingIcon: HugeIcons.strokeRoundedUser,
                      controller: provider.futureDriverController,
                      hintText: "Select Future Driver ",
                      dropdownIcon: provider.showFutureDriverList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showFutureDriverList,
                      isLoading: provider.isFutureDriverLoading,
                      items: provider.filteredFutureDrivers,
                      onFieldTap: provider.toggleFutureDriverList,
                      onSearch: provider.updateFutureDriverSearch,
                      onItemTap: provider.selectFutureDriver,
                      titleBuilder: (d) => d.completeName ?? "Unknown",
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),

                    if (provider.isCar)
                      Row(
                        children: [
                          buildTextData(
                            "Plan to Change Car",
                            16,
                            fontWeight: FontWeight.w300,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade500Color,
                          ),
                          Checkbox(
                            value: provider.planToChangeCar,
                            onChanged: provider.setPlanToChangeCar,
                          ),
                        ],
                      ),

                    if (provider.isBike)
                      Row(
                        children: [
                          buildTextData(
                            "Plan to Change Bike",
                            16,
                            fontWeight: FontWeight.w300,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade500Color,
                          ),
                          Checkbox(
                            value: provider.planToChangeBike,
                            onChanged: provider.setPlanToChangeBike,
                          ),
                        ],
                      ),

                    const SizedBox(height: 10),
                    _widgetVehiclesDatePicker(
                      controller: provider.assignedDateController,
                      provider: provider,
                      text: "Assignment Date",
                      isDarkTheme: isDarkTheme,
                      hintText: "Choose Assignment Date",
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                vehicleInfoCard(
                  isDarkTheme: isDarkTheme,

                  title: "Vehicle",
                  children: [
                    commonDropDownWidgetCard<VehicleCategoryItem>(
                      headText: "Vehicle Category",
                      subText: "Category",
                      leadingIcon: HugeIcons.strokeRoundedCar04,
                      controller: provider.categoryController,
                      hintText: "Select Category",
                      dropdownIcon: provider.showVehicleCategoryList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showVehicleCategoryList,
                      isLoading: provider.isVehicleCategoryLoading,
                      items: provider.filteredCategory,
                      onFieldTap: provider.toggleVehicleCategoryList,
                      onSearch: provider.updateVehicleCategorySearch,
                      onItemTap: provider.selectVehicleCategory,
                      titleBuilder: (c) => c.name,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetVehiclesDatePicker(
                      controller: provider.orderDateController,
                      provider: provider,
                      text: "Order Date",
                      isDarkTheme: isDarkTheme,
                      hintText: "Choose Order Date",
                    ),

                    const SizedBox(height: 10),
                    _widgetVehiclesDatePicker(
                      controller: provider.registrationDateController,
                      provider: provider,
                      text: "Registration Date",
                      isDarkTheme: isDarkTheme,
                      hintText: "Choose Registration Date",
                    ),
                    const SizedBox(height: 10),
                    _widgetVehiclesDatePicker(
                      controller: provider.cancellationDateController,
                      provider: provider,
                      text: "Cancellation Date",
                      isDarkTheme: isDarkTheme,
                      hintText: "Choose Cancellation Date",
                    ),
                    const SizedBox(height: 10),
                    _widgetVehiclesTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      "Chassis Number",
                      controller: provider.chassisNumberController,
                      icon: HugeIcons.strokeRoundedIdentityCard,
                      hintText: "Enter the Chassis number",
                      inputFormatters: [],
                      keyboardType: TextInputType.text,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    _widgetVehiclesTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      "Last Odometer",
                      controller: provider.lastOdometerController,
                      icon: HugeIcons.strokeRoundedDashboardSpeed01,
                      hintText: "Enter the Last Odometer run",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      isDarkTheme: isDarkTheme,
                    ),
                    const SizedBox(height: 10),
                    commonDropDownWidgetCard<UserRecord>(
                      isDarkTheme: isDarkTheme,
                      headText: "Fleet Manager",
                      subText: "Fleet Manager",
                      leadingIcon: HugeIcons.strokeRoundedUser,
                      controller: provider.fleetManagerController,
                      hintText: "Select Fleet Manager",
                      dropdownIcon: provider.showFleetManagerList
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      showDropdown: provider.showFleetManagerList,
                      isLoading: provider.isFleetManagerLoading,
                      items: provider.filteredFleetManagers,
                      onFieldTap: provider.toggleFleetManagerList,
                      onSearch: provider.updateFleetManagerSearch,
                      onItemTap: (UserRecord user) {
                        provider.selectFleetManager(user);
                      },

                      titleBuilder: (UserRecord user) => user.name,
                    ),
                    const SizedBox(height: 10),
                    _widgetVehiclesTextFormFieldWidget(
                      maxLines: 1,
                      provider: provider,
                      "Location",
                      controller: provider.locationController,
                      icon: HugeIcons.strokeRoundedLocation04,
                      hintText: "Enter the location",
                      inputFormatters: [],
                      keyboardType: TextInputType.text,
                      isDarkTheme: isDarkTheme,
                    ),
                    Row(
                      children: [
                        buildTextData(
                          "Make Vehicle Available",
                          14.0,
                          fontWeight: FontWeight.w300,
                          color: isDarkTheme
                              ? AllDesigns.whiteColor
                              : AllDesigns.greyShade900Color,
                        ),
                        const SizedBox(width: 12),
                        Checkbox(
                          value: provider.isCarAvailable,
                          onChanged: (bool? value) {
                            provider.vehicleAvailabilityToggle(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: provider.isVehiclesDetailsUpdating
                      ? null
                      : () async {
                          if (!provider.validateVehicleModel()) {
                            CustomSnackbar.showError(
                              context,
                              "Please fill required fields",
                            );
                            return;
                          }

                          final dashboardProvider = context
                              .read<DashboardProvider>();
                          final vehiclesProvider = context
                              .read<VehiclesProvider>();

                          bool success;

                          if (isEditMode) {
                            success = await provider.updateVehicleDetails();
                          } else {
                            success = await provider.addNewVehicleDetails();
                          }

                          if (!mounted) return;
                          if (success) {
                            await vehiclesProvider.fetchVehicles(domain: []);
                            await dashboardProvider.refreshDashboard(context);

                            Navigator.of(context).pop();
                            await ReviewService().trackSignificantEvent();
                            await ReviewService().checkAndShowRating(context);
                            CustomSnackbar.showSuccess(
                              context,
                              isEditMode
                                  ? "Vehicle updated successfully"
                                  : "Vehicle added successfully",
                            );
                            provider.clearLoading();
                          } else {
                            CustomSnackbar.showError(
                              context,
                              isEditMode
                                  ? "Vehicle update failed"
                                  : "Vehicle adding failed",
                            );
                          }
                          provider.closeAllDropdowns();
                        },

                  child: Container(
                    key: Key("add_edit_vehicle_key"),
                    height: 50,
                    decoration: BoxDecoration(
                      color: provider.isVehiclesDetailsUpdating
                          ? AllDesigns.greyShade300Color
                          : (!isEditMode &&
                                provider.vehicleController.text.trim().isEmpty)
                          ? AllDesigns.greyShade300Color
                          : AllDesigns.appColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (provider.isVehiclesDetailsUpdating) ...[
                          buildText(
                            isEditMode ? "Vehicle Updating" : "Vehicle Adding",
                            fontSize: 16,
                            color: AllDesigns.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(width: 10),
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: AllDesigns.whiteColor,
                            size: 20,
                          ),
                        ] else ...[
                          buildIcon(
                            icon: HugeIcons.strokeRoundedFileAdd,
                            color: AllDesigns.whiteColor,
                            size: 25,
                          ),
                          const SizedBox(width: 8),
                          buildText(
                            isEditMode ? "Update" : "Add Vehicle",
                            fontSize: 20,
                            color: AllDesigns.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverAvatar(Driverfetch.Record driver) {
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

  Widget vehicleInfoCard({
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
            offset: const Offset(-1, 0),
            spreadRadius: 1,
            blurRadius: 2,
            color: isDarkTheme ? Colors.black38 : Colors.grey.shade300,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: buildText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.blackColor,
            ),
          ),

          Divider(color: Colors.grey.shade200, endIndent: 10, indent: 10),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
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
    required List<T> items,
    required String Function(T item) titleBuilder,
    String Function(T item)? subtitleBuilder,
    required void Function(T item) onItemTap,
    bool? isModelEdit,
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
                  : AllDesigns.greyShade500Color,
              fontWeight: FontWeight.w300,
              letterSpacing: 0,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller,
              onTap: onFieldTap,
              onChanged: (value) {
                if (controller.text.isNotEmpty &&
                    value.trim() == controller.text.trim()) {
                  return;
                }
                onSearch(value);
              },
              decoration: InputDecoration(
                prefixIcon: buildIcon(
                  icon: leadingIcon ?? [],
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade700Color,
                  size: 22,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),

                suffixIcon: GestureDetector(
                  onTap: onFieldTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: buildIcon(
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
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDarkTheme
                        ? AllDesigns.greyShade800Color
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
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
                          separatorBuilder: (context, _) => SizedBox(height: 5),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              onTap: () => onItemTap(item),
                              leading: item is Driverfetch.Record
                                  ? _buildDriverAvatar(item)
                                  : null,
                              title: Text(
                                titleBuilder(item),
                                style: TextStyle(fontWeight: FontWeight.w600),
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
        ),
      ],
    );
  }

  Widget buildEditTagsCard({
    required VehiclesDetailsProvider provider,
    required bool isDarkTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          "Tags",
          fontSize: 16,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w300,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AllDesigns.greyShade300Color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: provider.selectedTags.isEmpty
              ? buildText(
                  "No Tags",
                  fontSize: 14,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade600Color,
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.selectedTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AllDesigns.greyShade300Color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          buildIcon(
                            color: AllDesigns.blackColor,
                            icon: HugeIcons.strokeRoundedCancel01,
                            size: 14,
                            onTap: () => provider.toggleTagSelection(tag),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),

        const SizedBox(height: 12),
        GestureDetector(
          onTap: provider.toggleTagsList,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkTheme ? AllDesigns.white : AllDesigns.blackColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade900Color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                buildText(
                  "Add Tags",
                  fontSize: 14,
                  color: provider.showTagsList
                      ? AllDesigns.appColor
                      : isDarkTheme
                      ? AllDesigns.whiteColor
                      : AllDesigns.greyShade700Color,
                ),
              ],
            ),
          ),
        ),
        if (provider.showTagsList)
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AllDesigns.greyShade300Color),
            ),
            child: provider.isTagsLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: provider.filteredTags.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final tag = provider.filteredTags[index];
                      final isSelected = provider.selectedTags.any(
                        (t) => t.id == tag.id,
                      );
                      return ListTile(
                        tileColor: Colors.transparent,
                        onTap: () => provider.toggleTagSelection(tag),
                        title: Text(tag.name),
                        trailing: isSelected
                            ? buildIcon(
                                icon: HugeIcons.strokeRoundedTick02,
                                color: AllDesigns.appColor,
                                size: 30,
                              )
                            : null,
                      );
                    },
                  ),
          ),
      ],
    );
  }

  Widget _widgetVehiclesTextFormFieldWidget(
    String? mainText, {
    required VehiclesDetailsProvider provider,
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
          mainText.toString(),
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
            prefixIcon: icon == null
                ? null
                : buildIcon(
                    icon: icon,
                    color: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.greyShade700Color,
                    size: 22,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 22,
              minHeight: 22,
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

  Widget _widgetVehiclesDatePicker({
    required TextEditingController controller,
    required VehiclesDetailsProvider provider,
    required String text,
    required bool isDarkTheme,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text,
          fontSize: 14,
          color: AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: true,

          onTap: () {
            provider.chooseDate(context, controller);
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
              letterSpacing: 0,
            ),
            prefixIcon: buildIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade700Color,
              size: 22,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 22,
              minHeight: 22,
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
    String text,
    double fontsize, {
    FontWeight fontWeight = FontWeight.w400,
    required Color color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0,
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    bool readOnly = false,
    int? maxLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AllDesigns.greyShade500Color, fontSize: 14),
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

  Widget buildIcon({
    required List<List<dynamic>> icon,
    required Color color,
    required double size,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: HugeIcon(icon: icon, size: size, color: color),
      ),
    );
  }
}

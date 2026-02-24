import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_projects/models/model_service_type_list.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart'
    as vendor_drivers;
import '../../core/designs/custom_designs.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';

class AddContractsLogPage extends StatefulWidget {
  const AddContractsLogPage({super.key});

  @override
  State<AddContractsLogPage> createState() => _AddContractsLogPageState();
}

class _AddContractsLogPageState extends State<AddContractsLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AddContractsLogProvider>();
      provider.setTodayDateIfEmpty(provider.contractStartDateTxtController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final Color commonFillColor = isDarkTheme
        ? AllDesigns.greyShade300Color.withOpacity(0.4)
        : AllDesigns.greyShade300Color.withOpacity(0.5);
    return Consumer<AddContractsLogProvider>(
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
            title: Text(
              "Create Contracts Log",
              style: TextStyle(
                fontSize: 20,
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.blackColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                createContractLogInfoCard(
                  isDarkTheme: isDarkTheme,
                  title: "Information",
                  children: [
                    _widgetTextFieldValue(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                      controller: provider.referenceTxtController,
                      text: "Reference",
                      hintText: "Enter Reference",

                      icon: HugeIcons.strokeRoundedNotebook02,
                    ),
                    const SizedBox(height: 10),
                    _widgetDatePicker(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                      textField: "Contract Start Date",
                      controller: provider.contractStartDateTxtController,
                      hintText: "Select Date",
                    ),
                    const SizedBox(height: 10),
                    commonTypeAhead<ServiceTypeItem>(
                      hideOnEmpty: false,
                      label: "Type",
                      controller: provider.includedServiceTypeTxtController,
                      isDarkTheme: isDarkTheme,
                      suggestionsCallback: provider.searchServiceTypes,
                      suggestionItemBuilder: (context, service) {
                        return ListTile(
                          tileColor: isDarkTheme
                              ? AllDesigns.greyShade800Color
                              : Colors.white,
                          leading: HugeIcon(
                            icon: HugeIcons.strokeRoundedTools,
                            color: isDarkTheme
                                ? AllDesigns.whiteColor
                                : AllDesigns.greyShade700Color,
                            size: 22,
                          ),
                          title: Text(
                            service.name,
                            style: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : Colors.black54,
                            ),
                          ),
                          subtitle: Text(
                            service.category,
                            style: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : Colors.black54,
                            ),
                          ),
                        );
                      },
                      onSelected: provider.selectServiceType,
                      fieldBuilder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Search contract Type",
                            hintStyle: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade500Color,
                            ),
                            filled: true,
                            fillColor: isDarkTheme
                                ? AllDesigns.greyShade300Color.withOpacity(0.4)
                                : AllDesigns.greyShade300Color.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    _widgetDatePicker(
                      provider: provider,
                      isDarkTheme: isDarkTheme,
                      textField: "Contract Expiration Date",
                      controller: provider.contractExpirationTxtController,
                      hintText: "Select Date",
                    ),
                    const SizedBox(height: 10),
                    commonTypeAhead<vendor_drivers.Record>(
                      label: "Vendor (Driver)",
                      controller: provider.vendorTxtController,
                      isDarkTheme: isDarkTheme,
                      hideOnEmpty: false,
                      suggestionsCallback: provider.searchPartners,
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
                                ? HugeIcon(
                                    icon: HugeIcons.strokeRoundedUser,
                                    color: AllDesigns.greyShade700Color,
                                    size: 22,
                                  )
                                : null,
                          ),
                          title: Text(
                            driver.completeName ?? "-",
                            style: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : Colors.black,
                            ),
                          ),
                        );
                      },

                      onSelected: provider.selectPartner,
                      fieldBuilder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: "Search Driver",
                            hintStyle: TextStyle(
                              color: isDarkTheme
                                  ? AllDesigns.whiteColor
                                  : AllDesigns.greyShade500Color,
                            ),
                            filled: true,
                            fillColor: commonFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      buildWidgetActivityLog(
                        context: context,
                        headText: "Vehicle",
                        index: 0,
                        isDarkTheme: isDarkTheme,
                      ),
                      buildWidgetActivityLog(
                        context: context,
                        headText: "Cost",
                        index: 1,
                        isDarkTheme: isDarkTheme,
                      ),
                      buildWidgetActivityLog(
                        context: context,
                        headText: "Terms and Conditions",
                        index: 2,
                        isDarkTheme: isDarkTheme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
                _buildSwitchContractsView(provider, isDarkTheme),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    if (provider.isSaveLoading) return;
                    if (provider.selectedVehicleId == null) {
                      CustomSnackbar.showError(
                        context,
                        "Please select a vehicle",
                      );
                      return;
                    }
                    final success = await provider.createContractLog();
                    if (!success) {
                      CustomSnackbar.showError(
                        context,
                        "Failed to add contract log",
                      );
                      return;
                    }
                    final activityProvider = context
                        .read<ActivityPageProvider>();
                    activityProvider.setSelectedActivityLog(
                      ActivityTabs.contract,
                    );
                    await activityProvider.fetchContractActivityDetails(
                      resetPage: true,
                    );
                    Navigator.pop(context);
                    CustomSnackbar.showSuccess(
                      context,
                      "Contract log added successfully",
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
                            text: "Add Contract log",
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  /// widget switch Contracts
  Widget _buildSwitchContractsView(
    AddContractsLogProvider provider,
    bool isDarkTheme,
  ) {
    switch (provider.selectedActivityIndex) {
      case 0:
        return _vehicleView(provider, isDarkTheme);
      case 1:
        return _costView(provider, isDarkTheme);
      case 2:
        return _termsView(provider, isDarkTheme);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Widget Vehicle view
  Widget _vehicleView(AddContractsLogProvider provider, bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          commonTypeAhead<VehicleItem>(
            hideOnEmpty: false,
            label: "Vehicle",
            controller: provider.vehicleTxtController,
            isDarkTheme: isDarkTheme,
            suggestionsCallback: provider.searchVehicles,
            suggestionItemBuilder: (context, vehicle) {
              return ListTile(
                tileColor: isDarkTheme
                    ? AllDesigns.greyShade800Color
                    : Colors.white,
                leading: HugeIcon(
                  icon: vehicle.vehicleType == 'car'
                      ? HugeIcons.strokeRoundedCar05
                      : HugeIcons.strokeRoundedMotorbike02,
                  color: isDarkTheme ? AllDesigns.whiteColor : Colors.black87,
                ),

                title: Text(
                  vehicle.model.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Plate: ${vehicle.licensePlate}",
                  style: TextStyle(
                    color: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.blackColor,
                  ),
                ),
              );
            },
            onSelected: provider.selectVehicle,
            fieldBuilder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: isDarkTheme ? Colors.white : Colors.black,
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
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCar05,
                      size: 22,
                      color: isDarkTheme
                          ? AllDesigns.whiteColor
                          : AllDesigns.greyShade700Color,
                    ),
                  ),
                  filled: true,
                  fillColor: isDarkTheme
                      ? AllDesigns.greyShade300Color.withOpacity(0.4)
                      : AllDesigns.greyShade300Color.withOpacity(0.5),

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
          _widgetTextFormFieldValue(
            provider: provider,
            isDarkTheme: isDarkTheme,
            controller: provider.driverPurchaseTxtController,
            maxLines: 1,
            text: "Driver",
            hintText: "Select Driver",
          ),
        ],
      ),
    );
  }

  /// Widget Cost view
  Widget _costView(AddContractsLogProvider provider, bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _widgetTextFormFieldValue(
            provider: provider,
            isDarkTheme: isDarkTheme,
            controller: provider.activationCostTxtController,
            maxLines: 1,
            text: "Activation Cost",
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
          ),
          const SizedBox(height: 10),
          _widgetDatePicker(
            provider: provider,
            isDarkTheme: isDarkTheme,
            textField: "Date",
            controller: provider.costDateTxtController,
            hintText: "Select Date",
          ),
          const SizedBox(height: 10),
          _widgetTextFormFieldValue(
            text: "Recurring Cost",
            provider: provider,
            isDarkTheme: isDarkTheme,
            controller: provider.recurringCostTxtController,
            maxLines: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget Terms view
  Widget _termsView(AddContractsLogProvider provider, bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AllDesigns.greyShade800Color : AllDesigns.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _widgetTextFormFieldValue(
            provider: provider,
            isDarkTheme: isDarkTheme,
            controller: provider.termsConditionsTxtController,
            maxLines: 3,
            hintText:
                "Write here all other information relative to this contract ",
          ),
        ],
      ),
    );
  }

  /// Widgets for Additional Fields
  Widget _widgetTextFormFieldValue({
    required AddContractsLogProvider provider,
    required bool isDarkTheme,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    String? text,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: text,
          fontSize: 14,
          color: isDarkTheme
              ? AllDesigns.whiteColor
              : AllDesigns.greyShade500Color,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        const SizedBox(height: 10),
        TextFormField(
          maxLines: maxLines,
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: inputFormatters,
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
            ),
            filled: true,
            fillColor: isDarkTheme
                ? AllDesigns.greyShade300Color.withOpacity(0.4)
                : AllDesigns.greyShade300Color.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Widget Activity Log
  Widget buildWidgetActivityLog({
    required BuildContext context,
    required String? headText,
    required int index,
    required bool isDarkTheme,
  }) {
    final provider = Provider.of<AddContractsLogProvider>(context);
    final bool isSelected = provider.selectedActivityIndex == index;

    return InkWell(
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

  /// Widget TypeAhead
  Widget commonTypeAhead<T>({
    required String label,
    required TextEditingController controller,
    required bool isDarkTheme,
    required bool hideOnEmpty,
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
          hideOnEmpty: hideOnEmpty,
          hideOnLoading: false,
          hideOnError: true,
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

  /// Widget TextField with value
  Widget _widgetTextFieldValue({
    required AddContractsLogProvider provider,
    required bool isDarkTheme,
    required String text,
    required String hintText,
    List<TextInputFormatter>? inputFormatters,
    required TextEditingController controller,
    void Function(String)? onChanged,
    List<List<dynamic>>? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: text,
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
          inputFormatters: inputFormatters,

          onChanged: onChanged,
          style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: HugeIcon(
                icon: icon ?? [],
                color: isDarkTheme
                    ? AllDesigns.whiteColor
                    : AllDesigns.greyShade700Color,
                size: 22,
              ),
            ),
            filled: true,
            fillColor: isDarkTheme
                ? AllDesigns.greyShade300Color.withOpacity(0.4)
                : AllDesigns.greyShade300Color.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Contract Log Info Card
  Widget createContractLogInfoCard({
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

  /// Widget Date Picker
  Widget _widgetDatePicker({
    required AddContractsLogProvider provider,
    required bool isDarkTheme,
    required String textField,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: textField,
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
          readOnly: true,
          onTap: () => provider.chooseDate(context, controller),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDarkTheme
                  ? AllDesigns.whiteColor
                  : AllDesigns.greyShade500Color,
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
            filled: true,
            fillColor: isDarkTheme
                ? AllDesigns.greyShade300Color.withOpacity(0.4)
                : AllDesigns.greyShade300Color.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// widget Text
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
}

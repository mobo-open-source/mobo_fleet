import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:mobo_projects/features/add_contracts/fetch_fleet_services_types.dart';
import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart';

import 'package:mobo_projects/models/model_service_type_list.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';
import '../../shared/widgets/snackbars/custom_snackbar.dart';

class AddContractsLogProvider extends ChangeNotifier {
  AddContractsLogProvider() {
    includedServiceTypeTxtController.addListener(onServiceTypeTextChanged);
    vendorTxtController.addListener(_onVendorTextChanged);
    vehicleTxtController.addListener(_onVehicleTextChanged);
  }

  static const contract = 'contract';

  final TextEditingController referenceTxtController = TextEditingController();
  final TextEditingController contractStartDateTxtController =
      TextEditingController();
  final TextEditingController includedServiceTypeTxtController =
      TextEditingController();
  final TextEditingController contractExpirationTxtController =
      TextEditingController();
  final TextEditingController vendorTxtController = TextEditingController();
  final TextEditingController termsConditionsTxtController =
      TextEditingController();
  final TextEditingController activationCostTxtController =
      TextEditingController();
  final TextEditingController recurringCostTxtController =
      TextEditingController();
  final TextEditingController costDateTxtController = TextEditingController();
  final TextEditingController vehicleTxtController = TextEditingController();
  final TextEditingController driverPurchaseTxtController =
      TextEditingController();

  VehicleItem? selectedVehicle;
  ServiceTypeItem? selectedServiceType;

  int? selectedVehicleId;
  int selectedActivityIndex = 0;
  int? driverPurchaseId;
  int? selectedPartnerId;
  int? selectedServiceTypeId;

  Record? selectedDriver;

  bool _isVehicleLoading = false;
  bool get isVehicleLoading => _isVehicleLoading;

  bool _isVendorLoading = false;
  bool get isVendorLoading => _isVendorLoading;

  bool isSaveLoading = false;

  bool _isServiceTypeLoading = false;
  bool get isServiceTypeLoading => _isServiceTypeLoading;

  final Map<TextEditingController, DateTime> _selectedDates = {};

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void _onVehicleTextChanged() {
    if (vehicleTxtController.text.trim().isEmpty) {
      selectedVehicle = null;
      selectedVehicleId = null;
      driverPurchaseTxtController.clear();
      notifyListeners();
    }
  }

  // Fetch Vehicle according to search
  Future<List<VehicleItem>> searchVehicles(String query) async {
    _isVehicleLoading = true;
    notifyListeners();
    try {
      final result = await FetchFleetManager.fetchVehicles(
        query: query.trim(),
      );
      return result.records;
    } finally {
      _isVehicleLoading = false;
      notifyListeners();
    }
  }

  /// Select vehicle
  void selectVehicle(VehicleItem vehicle) {
    selectedVehicle = vehicle;
    selectedVehicleId = vehicle.id;
    vehicleTxtController.text = vehicle.model.name;
    final driver = vehicle.driverEmployee;
    if (driver != null && driver.id != null) {
      driverPurchaseTxtController.text = driver.name ?? '';
      driverPurchaseId = driver.id;
    } else {
      driverPurchaseTxtController.clear();
      driverPurchaseId = null;
    }
    notifyListeners();
  }

  /// Clear Vehicle
  void clearVehicle() {
    selectedVehicle = null;
    selectedVehicleId = null;
    vehicleTxtController.clear();
    driverPurchaseTxtController.clear();
    driverPurchaseId = null;
    notifyListeners();
  }

  bool get canSave {
    return selectedVehicleId != null;
  }

  /// Vehicle Validation
  bool validateVehicle(BuildContext context) {
    if (selectedVehicleId == null) {
      CustomSnackbar.showError(context, 'Please select a valid vehicle');
      return false;
    }
    return true;
  }

  void _onVendorTextChanged() {
    if (vendorTxtController.text.trim().isEmpty) {
      selectedDriver = null;
      selectedPartnerId = null;
      notifyListeners();
    }
  }

  /// Search Partner
  Future<List<Record>> searchPartners(String query) async {
    _isVendorLoading = true;
    try {
      final result = await FetchedFleetDrivers.fetchDrivers(
        query: query.trim().isEmpty ? null : query.trim(),
        limit: 20,
      );
      return result.records;
    } finally {
      _isVendorLoading = false;
      notifyListeners();
    }
  }

  /// Select Partner
  void selectPartner(Record driver) {
    selectedDriver = driver;
    selectedPartnerId = driver.id;
    vendorTxtController.text = driver.completeName ?? '';
    notifyListeners();
  }

  // Search Service Types
  Future<List<ServiceTypeItem>> searchServiceTypes(String query) async {
    _isServiceTypeLoading = true;

    try {
      final result = await FetchFleetServicesTypes.fetchServiceTypes(
        query: query,
        category: contract,
      );
      return result.records;
    } finally {
      _isServiceTypeLoading = false;
      notifyListeners();
    }
  }

  /// Select Service type
  void selectServiceType(ServiceTypeItem item) {
    selectedServiceType = item;
    selectedServiceTypeId = item.id;
    includedServiceTypeTxtController.text = item.name;
    notifyListeners();
  }

  void onServiceTypeTextChanged() {
    if (includedServiceTypeTxtController.text.trim().isEmpty) {
      selectedServiceType = null;
      selectedServiceTypeId = null;
      notifyListeners();
    }
  }

  /// Default set today's Date
  void setTodayDateIfEmpty(TextEditingController controller) {
    if (controller.text.isEmpty) {
      final today = DateTime.now();
      _selectedDates[controller] = today;
      controller.text = _formatDate(today);
      notifyListeners();
    }
  }

  /// Function to create Contract Log
  Future<bool> createContractLog() async {
    if (isSaveLoading) return false;

    if (selectedVehicleId == null) {
      return false;
    }
    isSaveLoading = true;
    notifyListeners();

    final Map<String, dynamic> payload = {
      'vehicle_id': selectedVehicleId,
      'start_date': formatOdooDate(contractStartDateTxtController),
    };

    if (referenceTxtController.text.trim().isNotEmpty) {
      payload['ins_ref'] = referenceTxtController.text.trim();
    }

    if (selectedServiceTypeId != null) {
      payload['cost_subtype_id'] = selectedServiceTypeId;
      payload['service_ids'] = [
        [
          6,
          0,
          [selectedServiceTypeId],
        ],
      ];
    }

    if (selectedPartnerId != null) {
      payload['insurer_id'] = selectedPartnerId;
    }

    if (driverPurchaseId != null) {
      payload['purchaser_id'] = driverPurchaseId;
    }

    final expDate = formatOdooDate(contractExpirationTxtController);
    if (expDate.isNotEmpty) {
      payload['expiration_date'] = expDate;
    }

    final costDateStr = formatOdooDate(costDateTxtController);
    if (costDateStr.isNotEmpty) {
      payload['date'] = costDateStr;
    }

    payload['amount'] =
        double.tryParse(activationCostTxtController.text) ?? 0.0;

    payload['cost_generated'] =
        double.tryParse(recurringCostTxtController.text) ?? 0.0;

    if (termsConditionsTxtController.text.trim().isNotEmpty) {
      payload['notes'] = termsConditionsTxtController.text.trim();
    }

    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;
      await odooClient({
        'model': 'fleet.vehicle.log.contract',
        'method': 'create',
        'args': [payload],
        'kwargs': {},
      });
      resetData();
      return true;
    } catch (e) {
      return false;
    } finally {
      isSaveLoading = false;
      notifyListeners();
    }
  }

  ///Format Odoo Date
  String formatOdooDate(TextEditingController controller) {
    final d = _selectedDates[controller];
    if (d == null) return '';
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  void resetData() {
    referenceTxtController.clear();
    contractStartDateTxtController.clear();
    contractExpirationTxtController.clear();
    includedServiceTypeTxtController.clear();
    vendorTxtController.clear();
    activationCostTxtController.clear();
    recurringCostTxtController.clear();
    costDateTxtController.clear();
    termsConditionsTxtController.clear();
    vehicleTxtController.clear();
    driverPurchaseTxtController.clear();
    selectedVehicle = null;
    selectedVehicleId = null;
    selectedServiceType = null;
    selectedServiceTypeId = null;
    selectedDriver = null;
    selectedPartnerId = null;
    driverPurchaseId = null;
    _selectedDates.clear();
    selectedActivityIndex = 0;
    notifyListeners();
  }

  /// Date Picker
  Future<void> chooseDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final today = DateTime.now();
    final initialDate = _selectedDates[controller] ?? today;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(today) ? today : initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _selectedDates[controller] = pickedDate;
      controller.text = _formatDate(pickedDate);
      notifyListeners();
    }
  }

  void setSelectedActivityLog(int index) {
    selectedActivityIndex = index;
    notifyListeners();
  }

  /// dispose
  @override
  void dispose() {
    referenceTxtController.dispose();
    contractStartDateTxtController.dispose();
    includedServiceTypeTxtController.dispose();
    vendorTxtController.dispose();
    contractExpirationTxtController.dispose();
    termsConditionsTxtController.dispose();
    activationCostTxtController.dispose();
    recurringCostTxtController.dispose();
    costDateTxtController.dispose();
    vehicleTxtController.dispose();
    driverPurchaseTxtController.dispose();
    super.dispose();
  }

  /// Clear on Logout
  void clearOnLogout() {
    resetData();
    isSaveLoading = false;
    _isVehicleLoading = false;
    _isVendorLoading = false;
    _isServiceTypeLoading = false;
    notifyListeners();
  }
}

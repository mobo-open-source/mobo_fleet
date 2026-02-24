import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobo_projects/core/designs/widget_snackbar.dart';
import 'package:mobo_projects/models/model_service_type_list.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/models/model_vendors_list.dart';
import 'package:mobo_projects/models/model_add_log_drivers_list.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';

class AddServiceFuelLogProvider extends ChangeNotifier {
  String _driverSearch = "";
  String _vehicleSearch = "";
  String _serviceTypeSearch = "";
  String _vendorSearch = "";

  bool isVehicleLoading = false;
  bool isServiceLoading = false;
  bool isVendorLoading = false;

  bool showVehicleList = false;
  bool showServiceList = false;
  bool showVendorsList = false;
  bool showDriversList = false;

  bool vehicleError = false;
  bool serviceError = false;

  bool isSaveLoading = false;
  bool isDriverLoading = false;

  VehicleItem? selectedVehicle;
  ModelVehicleList? modelVehicleList;

  VendorItem? selectedVendor;
  ModelVendorsList? modelVendorsList;

  ServiceTypeItem? selectedServiceType;
  ModelServiceTypeList? modelServiceTypeList;

  int? purchaserEmployeeId;

  DriverItem? selectedDriver;
  ModelAddLogDriversList? modelDriversList;

  final TextEditingController driverController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController serviceTypeController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  DateTime initialDate = DateTime.now();

  bool get canSave => selectedVehicle != null && selectedServiceType != null;

  ///Filters search
  List<VehicleItem> get filteredVehicles {
    if (modelVehicleList == null) return [];

    if (_vehicleSearch.isEmpty) {
      return modelVehicleList!.records;
    }

    final query = _vehicleSearch.toLowerCase();

    return modelVehicleList!.records.where((v) {
      return v.model.name.toLowerCase().contains(query) ||
          v.licensePlate.toLowerCase().contains(query) ||
          v.driver.name.toLowerCase().contains(query);
    }).toList();
  }

  List<ServiceTypeItem> get filteredServiceTypes {
    if (modelServiceTypeList == null) return [];
    if (_serviceTypeSearch.isEmpty) {
      return modelServiceTypeList!.records;
    }
    final query = _serviceTypeSearch.toLowerCase();
    return modelServiceTypeList!.records.where((v) {
      return v.name.toLowerCase().contains(query);
    }).toList();
  }

  List<VendorItem> get filteredVendors {
    if (modelVendorsList == null) return [];
    if (_vendorSearch.isEmpty) {
      return modelVendorsList!.records;
    }
    final query = _vendorSearch.toLowerCase();
    return modelVendorsList!.records.where((v) {
      return v.name.toLowerCase().contains(query);
    }).toList();
  }

  List<DriverItem> get filteredDrivers {
    if (modelDriversList == null) return [];

    if (_driverSearch.isEmpty) {
      return modelDriversList!.records;
    }

    final query = _driverSearch.toLowerCase();
    return modelDriversList!.records.where((d) {
      return d.name.toLowerCase().contains(query) ||
          d.phone.toLowerCase().contains(query);
    }).toList();
  }

  ///Toggle List
  Future<void> toggleVehicleList(BuildContext context) async {
    if (!showVehicleList &&
        (modelVehicleList == null || modelVehicleList!.records.isEmpty)) {
      await fetchVehiclesList();
    }

    ///  validate when closing dropdown
    if (showVehicleList) {
      validateTypedVehicle(context);
    }

    showVehicleList = !showVehicleList;
    notifyListeners();
  }

  Future<void> toggleServiceList(BuildContext context) async {
    if (!showServiceList &&
        (modelServiceTypeList == null ||
            modelServiceTypeList!.records.isEmpty)) {
      await fetchServiceList();
    }

    ///  validate when closing dropdown
    if (showServiceList) {
      validateTypedService(context);
    }

    showServiceList = !showServiceList;
    notifyListeners();
  }

  Future<void> toggleVendorsList() async {
    if (!showVendorsList &&
        (modelVendorsList == null || modelVendorsList!.records.isEmpty)) {
      await fetchVendorsList();
    }
    showVendorsList = !showVendorsList;
    notifyListeners();
  }

  Future<void> toggleDriversList() async {
    if (!showDriversList &&
        (modelDriversList == null || modelDriversList!.records.isEmpty)) {
      await fetchDriversList();
    }

    showDriversList = !showDriversList;
    notifyListeners();
  }

  /// Update Search
  void updateVehicleSearch(String value) {
    _vehicleSearch = value;
    notifyListeners();
  }

  void updateServiceTypeSearch(String value) {
    _serviceTypeSearch = value;
    notifyListeners();
  }

  void updateVendorsSearch(String value) {
    _vendorSearch = value;
    notifyListeners();
  }

  void updateDriverSearch(String value) {
    _driverSearch = value;
    notifyListeners();
  }

  ///Select Vehicle from dropdown
  void selectVehicle(VehicleItem vehicle) {
    selectedVehicle = vehicle;
    vehicleController.text = "${vehicle.model.name} / ${vehicle.licensePlate}";
    purchaserEmployeeId = vehicle.driverEmployee.id;
    _vehicleSearch = "";
    showVehicleList = false;
    vehicleError = false;
    autoSelectDriverFromVehicle(vehicle);
    notifyListeners();
  }

  /// Select Vendor
  void selectVendor(VendorItem vendor) {
    selectedVendor = vendor;
    vendorController.text = "${vendor.name}";
    _vendorSearch = "";
    showVendorsList = false;
    notifyListeners();
  }

  /// Select Service Type
  void selectServiceType(ServiceTypeItem serviceType) {
    selectedServiceType = serviceType;
    serviceTypeController.text = serviceType.name;
    _serviceTypeSearch = "";
    showServiceList = false;
    serviceError = false;
    notifyListeners();
  }

  /// Select Driver
  void selectDriver(DriverItem driver) {
    selectedDriver = driver;
    driverController.text = driver.name;
    _driverSearch = "";
    showDriversList = false;
    notifyListeners();
  }

  /// Required Fields validation
  bool validateRequiredFields() {
    vehicleError = selectedVehicle == null;
    serviceError = selectedServiceType == null;
    notifyListeners();
    return !(vehicleError || serviceError);
  }

  /// Fetch Vehicles List
  Future<void> fetchVehiclesList() async {
    if (isVehicleLoading) return;

    try {
      isVehicleLoading = true;
      notifyListeners();

      final odooClient = await OdooSessionManager.callKwWithCompany;

      final List<dynamic> response = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'id',
            'active',
            'license_plate',
            'model_id',
            'category_id',
            'manager_id',
            'driver_id',
            'driver_employee_id',
            'future_driver_id',
            'future_driver_employee_id',
            'log_drivers',
            'vin_sn',
            'co2',
            'acquisition_date',
            'tag_ids',
            'state_id',
            'contract_renewal_due_soon',
            'contract_renewal_overdue',
            'contract_state',
            'company_id',
          ],
        },
      });

      modelVehicleList = ModelVehicleList.fromJson(response);
    } catch (e) {
    } finally {
      isVehicleLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Service List
  Future<void> fetchServiceList() async {
    if (isServiceLoading) return;
    try {
      isServiceLoading = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final List<dynamic> response = await odooClient({
        'model': 'fleet.service.type',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'name', 'category'],
        },
      });
      modelServiceTypeList = ModelServiceTypeList.fromJson(response);
    } catch (e) {
    } finally {
      isServiceLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Vendors List
  Future<void> fetchVendorsList() async {
    if (isVendorLoading) return;
    try {
      isVendorLoading = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final List<dynamic> response = await odooClient({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'id',
            'avatar_128',
            'write_date',
            'complete_name',
            'vat',
            'email',
            'phone',
            'user_id',
          ],
        },
      });
      modelVendorsList = ModelVendorsList.fromJson(response);
    } catch (e) {
    } finally {
      isVendorLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Drivers List
  Future<void> fetchDriversList() async {
    if (isDriverLoading) return;
    try {
      isDriverLoading = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final List<dynamic> response = await odooClient({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': ['id', 'name', 'phone', 'email', 'avatar_128'],
        },
      });
      modelDriversList = ModelAddLogDriversList.fromJson(response);
    } catch (e) {
    } finally {
      isDriverLoading = false;
      notifyListeners();
    }
  }

  /// Date Picker
  Future<void> chooseDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime safeInitialDate = initialDate.isBefore(today)
        ? today
        : initialDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: today,
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
      initialDate = pickedDate;
      dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      notifyListeners();
    }
  }

  /// Create Service Log
  Future<bool> createServiceLog() async {
    if (isSaveLoading) return false;
    if (!validateRequiredFields()) {
      return false;
    }
    isSaveLoading = true;
    notifyListeners();
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final Map<String, dynamic> values = {
        'date': dateController.text.isNotEmpty
            ? dateController.text
            : DateTime.now().toIso8601String().split('T').first,
        'description': descriptionController.text.isEmpty
            ? false
            : descriptionController.text,
        'service_type_id': selectedServiceType?.id,
        'vehicle_id': selectedVehicle?.id,
        'odometer': double.tryParse(odometerController.text) ?? 0.0,
        'purchaser_id': selectedDriver?.id ?? false,
        'purchaser_employee_id': purchaserEmployeeId ?? false,
        'vendor_id': selectedVendor?.id ?? false,
        'notes': notesController.text.isEmpty ? false : notesController.text,
        'amount': double.tryParse(costController.text) ?? 0.0,
        'state': 'new',
      };
      await odooClient({
        'model': 'fleet.vehicle.log.services',
        'method': 'create',
        'args': [values],
        'kwargs': {},
      });
      resetFieldForm();
      return true;
    } catch (e) {
      resetFieldForm();
      return false;
    } finally {
      isSaveLoading = false;
      notifyListeners();
    }
  }

  /// Auto select Driver when Vehicle selected
  void autoSelectDriverFromVehicle(VehicleItem vehicle) {
    if (modelDriversList == null) return;
    if (vehicle.driver.id == null) return;
    try {
      final matchedDriver = modelDriversList!.records.firstWhere(
        (driver) => driver.id == vehicle.driver.id,
      );
      selectedDriver = matchedDriver;
      driverController.text = matchedDriver.name;
      _driverSearch = "";
      showDriversList = false;
    } catch (e) {
      selectedDriver = null;
      driverController.clear();
    }
  }

  /// Validate Vehicle
  void validateTypedVehicle(BuildContext context) {
    final typedText = vehicleController.text.trim().toLowerCase();
    if (typedText.isEmpty) return;
    final VehicleItem? matchedVehicle = modelVehicleList?.records
        .where(
          (v) =>
              "${v.model.name} / ${v.licensePlate}".toLowerCase() == typedText,
        )
        .cast<VehicleItem?>()
        .firstOrNull;
    if (matchedVehicle == null) {
      selectedVehicle = null;
      vehicleController.clear();
      vehicleError = true;
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      CustomSnackbar.showError(rootContext, "Selected vehicle is not present");
      notifyListeners();
      return;
    }
    selectedVehicle = matchedVehicle;
    purchaserEmployeeId = matchedVehicle.driverEmployee.id;
    vehicleError = false;
  }

  /// Validate Service
  void validateTypedService(BuildContext context) {
    final typedText = serviceTypeController.text.trim().toLowerCase();
    if (typedText.isEmpty) return;
    final ServiceTypeItem? matchedService = modelServiceTypeList?.records
        .where((s) => s.name.toLowerCase() == typedText)
        .cast<ServiceTypeItem?>()
        .firstOrNull;
    if (matchedService == null) {
      selectedServiceType = null;
      serviceTypeController.clear();
      serviceError = true;
      final rootContext = Navigator.of(context, rootNavigator: true).context;
      CustomSnackbar.showError(
        rootContext,
        "Selected service type is not present",
      );
      notifyListeners();
      return;
    }
    selectedServiceType = matchedService;
    serviceError = false;
  }

  /// Reset FormField
  void resetFieldForm() {
    descriptionController.clear();
    vehicleController.clear();
    driverController.clear();
    serviceTypeController.clear();
    dateController.clear();
    odometerController.clear();
    costController.clear();
    vendorController.clear();
    notesController.clear();
    selectedVehicle = null;
    selectedDriver = null;
    selectedVendor = null;
    selectedServiceType = null;
    purchaserEmployeeId = null;
    vehicleError = false;
    serviceError = false;
    showVehicleList = false;
    showServiceList = false;
    showVendorsList = false;
    showDriversList = false;
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    vehicleController.dispose();
    driverController.dispose();
    serviceTypeController.dispose();
    vendorController.dispose();
    dateController.dispose();
    odometerController.dispose();
    notesController.dispose();
    costController.dispose();
    super.dispose();
  }

  /// Clear on Logout
  void clearOnLogout() {
    resetFieldForm();
    modelVehicleList = null;
    modelVendorsList = null;
    modelServiceTypeList = null;
    modelDriversList = null;
    isVehicleLoading = false;
    isServiceLoading = false;
    isVendorLoading = false;
    isDriverLoading = false;
    isSaveLoading = false;
    _vehicleSearch = "";
    _serviceTypeSearch = "";
    _vendorSearch = "";
    _driverSearch = "";
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';

import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';
import 'package:mobo_projects/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart'
    as Drivers;
import 'package:provider/provider.dart';

class AddOdometerLogProvider extends ChangeNotifier {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController driverEmployeeController =
      TextEditingController();

  double? odometerValue;

  DateTime _selectedDate = DateTime.now();

  VehicleItem? selectedVehicle;
  Drivers.Record? selectedDriver;

  int? selectedVehicleId;
  int? selectedDriverId;
  int? selectedDriverEmployeeId;

  bool _isVehicleLoading = false;
  bool _isDriverLoading = false;
  bool isSaveLoading = false;

  bool get isVehicleLoading => _isVehicleLoading;
  bool get isDriverLoading => _isDriverLoading;

  bool get canSave {
    return selectedVehicleId != null && dateController.text.isNotEmpty;
  }

  bool validateRequiredFields() {
    return selectedVehicleId != null && dateController.text.isNotEmpty;
  }

  void setOdometerValue(String value) {
    odometerValue = double.tryParse(value);
    notifyListeners();
  }

  AddOdometerLogProvider() {
    vehicleController.addListener(_onVehicleTextChanged);
  }

  void _onVehicleTextChanged() {
    // If user clears the vehicle field manually
    if (vehicleController.text.trim().isEmpty) {
      selectedVehicle = null;
      selectedVehicleId = null;

      //  REMOVE EMPLOYEE DRIVER IMMEDIATELY
      driverEmployeeController.clear();

      notifyListeners();
    }
  }

  Future<List<VehicleItem>> searchVehicles(String query) async {
    _isVehicleLoading = true;
    notifyListeners();
    try {
      final result = await FetchFleetManager.fetchVehicles(query: query.trim());
      return result.records;
    } finally {
      _isVehicleLoading = false;
      notifyListeners();
    }
  }

  Future<List<Drivers.Record>> searchDrivers(String query) async {
    _isDriverLoading = true;
    notifyListeners();
    try {
      final result = await Drivers.FetchedFleetDrivers.fetchDrivers(
        query: query.trim(),
      );
      return result.records;
    } finally {
      _isDriverLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOdometerLog() async {
    if (isSaveLoading) return false;
    if (!validateRequiredFields()) {
      return false;
    }
    isSaveLoading = true;
    notifyListeners();
    try {
      final payload = {
        "vehicle_id": selectedVehicleId,
        "date": dateController.text,
        "value": odometerValue,
        "driver_id": selectedDriverId,
        "driver_employee_id": selectedDriverEmployeeId,
      };
      final odooClient = await OdooSessionManager.callKwWithCompany;
      await odooClient({
        'model': 'fleet.vehicle.odometer',
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

  void selectVehicle(VehicleItem vehicle) {
    selectedVehicle = vehicle;
    selectedVehicleId = vehicle.id;

    vehicleController.text = vehicle.model.name;
    if (vehicle.driverEmployee.id != null) {
      driverEmployeeController.text = vehicle.driverEmployee.name;
      selectedDriverEmployeeId = vehicle.driverEmployee.id;
    } else {
      driverEmployeeController.text = "";
    }

    notifyListeners();
  }

  void selectDriver(Drivers.Record driver) {
    selectedDriver = driver;
    selectedDriverId = driver.id;
    driverController.text = driver.completeName ?? "";
    notifyListeners();
  }

  void resetData() {
    clearVehicle();
    clearDriver();

    odometerController.clear();
    dateController.clear();

    odometerValue = null;
    _selectedDate = DateTime.now();

    notifyListeners();
  }

  void clearOnLogout() {
    dateController.clear();
    vehicleController.clear();
    driverController.clear();
    odometerController.clear();
    driverEmployeeController.clear();
    selectedVehicle = null;
    selectedVehicleId = null;
    selectedDriver = null;
    selectedDriverId = null;
    selectedDriverEmployeeId = null;
    odometerValue = null;
    _selectedDate = DateTime.now();
    _isVehicleLoading = false;
    _isDriverLoading = false;
    isSaveLoading = false;

    notifyListeners();
  }

  void clearVehicle() {
    selectedVehicle = null;
    selectedVehicleId = null;
    vehicleController.clear();
    driverEmployeeController.clear();
    notifyListeners();
  }

  void clearDriver() {
    selectedDriver = null;
    selectedDriverId = null;
    driverController.clear();
    notifyListeners();
  }

  bool validateVehicle(BuildContext context) {
    if (selectedVehicleId == null) {
      CustomSnackbar.showError(context, 'Please select a valid vehicle');
      return false;
    }
    return true;
  }

  void setTodayDateIfEmpty() {
    if (dateController.text.isEmpty) {
      final today = DateTime.now();
      _selectedDate = today;
      dateController.text =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      notifyListeners();
    }
  }

  Future<void> chooseDate(BuildContext context) async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
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
      _selectedDate = pickedDate;
      dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    vehicleController.removeListener(_onVehicleTextChanged);
    dateController.dispose();
    vehicleController.dispose();
    driverController.dispose();
    odometerController.dispose();
    driverEmployeeController.dispose();
    super.dispose();
  }
}

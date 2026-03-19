import 'package:flutter/material.dart';
import 'package:mobo_projects/core/designs/widget_snackbar.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';

import 'package:mobo_projects/features/add_contracts/fetched_fleet_drivers.dart';


import 'package:mobo_projects/models/model_vehicles_list.dart' as vehiclesList;
import 'package:mobo_projects/models/model_fetch_fleet_manager.dart';
import 'package:mobo_projects/models/model_fetch_vehicle_category.dart';
import 'package:mobo_projects/models/model_fetched_fleet_fuel_type_selections.dart';
import 'package:mobo_projects/models/model_fleet_vehicle_details.dart';
import 'package:intl/intl.dart';
import 'package:mobo_projects/models/model_fleet_vehicle_tags.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';

class VehiclesDetailsProvider extends ChangeNotifier {
  int selectedVehicleDetailsIndex = 0;
  int? vehicleId;
  int? driverId;
  int? futureDriverId;
  int? fleetManagerId;

  String? selectedFuelTypeKey;
  String? selectedTransmissionTypeKey;
  String? selectedBikeFrameTypeKey;

  ModelFleetVehicleDetails? modelFleetVehicleDetails;
  ModelFleetVehicleTags? modelFleetVehicleTags;
  vehiclesList.ModelVehicleList? _vehicleList;
  vehiclesList.VehicleItem? selectedVehicle;
  ModelFetchVehicleCategory? modelVehicleCategory;
  VehicleCategoryItem? vehicleCategoryItem;
  ModelSeparateDriverList? modelSeparateDriverList;
  Record? selectedDriver;
  Record? selectedFutureDriver;
  ModelFetchFleetManager? modelFetchFleetManager;
  UserRecord? selectedFleetManager;

  DateTime initialDate = DateTime.now();

  /// showDropsDowns
  bool showYearDropdown = false;
  bool showTransmissionDropDown = false;
  bool showFuelTypeDropdown = false;
  bool showBikeFrameTypeDropdown = false;

  /// Searches
  String _search = "";
  String _tagsSearch = "";
  String _vehicleCategorySearch = "";
  String _driverSearch = "";
  String _futureDriverSearch = "";
  String _fleetManagerSearch = "";

  TextEditingController vehicleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final TextEditingController fleetManagerController = TextEditingController();
  TextEditingController futureDriverController = TextEditingController();
  TextEditingController driverController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();
  TextEditingController chassisNumberController = TextEditingController();
  TextEditingController lastOdometerController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController assignedDateController = TextEditingController();
  TextEditingController orderDateController = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();
  TextEditingController cancellationDateController = TextEditingController();
  TextEditingController horsePowerTaxationController = TextEditingController();
  TextEditingController firstContractDateController = TextEditingController();
  TextEditingController catalogValueController = TextEditingController();
  TextEditingController purchaseValueController = TextEditingController();
  TextEditingController residualValueController = TextEditingController();
  TextEditingController modelYearController = TextEditingController();
  TextEditingController modelSeatingCapacityController =
      TextEditingController();
  TextEditingController modelNoOfDoorsController = TextEditingController();
  TextEditingController modelColorController = TextEditingController();
  TextEditingController engineFuelTypeController = TextEditingController();
  TextEditingController engineTransmissionController = TextEditingController();
  TextEditingController enginePowerController = TextEditingController();
  TextEditingController engineRangeController = TextEditingController();
  TextEditingController engineC02EmissionController = TextEditingController();
  TextEditingController engineEmissionStandardController =
      TextEditingController();
  TextEditingController vehicleDetailsNotes = TextEditingController();

  /// Bike specific
  TextEditingController bikeFrameTypeController = TextEditingController();
  TextEditingController bikeFrameSizeController = TextEditingController();

  List<BikeFrameTypeItem> bikeFrameTypes = [];
  List<BikeFrameTypeItem> filteredBikeFrameTypes = [];
  List<TagItem> vehicleTags = [];
  List<FleetTagItem> selectedTags = [];
  List<int> filteredYears = [];
  List<FuelTypeSelectionItem> fuelTypes = [];
  List<FuelTypeSelectionItem> filteredFuelTypes = [];
  List<TransmissionTypeSelectionItem> transmissionTypes = [];
  List<TransmissionTypeSelectionItem> filteredTransmissionTypes = [];

  /// Details Loading
  bool isVehicleDetailsLoading = false;
  bool isVehicleLoading = false;
  bool isTagsLoading = false;
  bool isDriverLoading = false;
  bool isFutureDriverLoading = false;
  bool isFleetManagerLoading = false;
  bool isFuelTypeLoading = false;
  bool isTransmissionTypeLoading = false;
  bool isBikeFrameTypeLoading = false;
  bool isVehicleCategoryLoading = false;

  bool vehicleError = false;
  bool tagsError = false;
  bool driverError = false;
  bool futureDriverError = false;
  bool fleetManagerError = false;
  bool vehicleCategoryError = false;

  /// List showing
  bool showVehicleList = false;
  bool showTagsList = false;
  bool showDriverList = false;
  bool showFutureDriverList = false;
  bool showFleetManagerList = false;
  bool showVehicleCategoryList = false;

  bool isTaxInfoEdit = false;
  bool isModelInfoEdit = false;
  bool isNotesInfoEdit = false;

  /// Updating
  bool isVehiclesDetailsUpdating = false;

  /// Vehicle type (Car / Bike)
  String? selectedVehicleType;
  bool get isCar => selectedVehicleType == 'car';
  bool get isBike => selectedVehicleType == 'bike';

  bool _planToChangeCar = false;
  bool _planToChangeBike = false;
  bool get planToChangeCar => _planToChangeCar;
  bool get planToChangeBike => _planToChangeBike;

  void setPlanToChangeCar(bool? value) {
    _planToChangeCar = value ?? false;
    notifyListeners();
  }

  void setPlanToChangeBike(bool? value) {
    _planToChangeBike = value ?? false;
    notifyListeners();
  }

  /// Selected Vehicle Bike Features
  bool _hasElectricAssistance = false;
  bool get hasElectricAssistance => _hasElectricAssistance;

  void toggleElectricAssistance(bool? value) {
    _hasElectricAssistance = value ?? false;
    notifyListeners();
  }

  void editClearFunction() {
    isTaxInfoEdit = false;
    isModelInfoEdit = false;
    isNotesInfoEdit = false;
  }

  Future<void> loadBikeFrameTypes() async {
    if (isBikeFrameTypeLoading || bikeFrameTypes.isNotEmpty) return;

    try {
      isBikeFrameTypeLoading = true;
      notifyListeners();

      final rawList =
          await FetchFleetManager.fetchBikeFrameTypesRaw();

      bikeFrameTypes = rawList
          .map((e) => BikeFrameTypeItem.fromRaw(e))
          .toList();

      filteredBikeFrameTypes = bikeFrameTypes;
    } catch (e) {
    } finally {
      isBikeFrameTypeLoading = false;
      notifyListeners();
    }
  }

  void toggleBikeFrameTypeDropdown() async {
    if (!showBikeFrameTypeDropdown && bikeFrameTypes.isEmpty) {
      await loadBikeFrameTypes();
    }
    showBikeFrameTypeDropdown = !showBikeFrameTypeDropdown;
    notifyListeners();
  }

  void filterBikeFrameTypes(String value) {
    filteredBikeFrameTypes = bikeFrameTypes
        .where((e) => e.label.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void selectBikeFrameType(BikeFrameTypeItem item) {
    bikeFrameTypeController.text = item.label;
    selectedBikeFrameTypeKey = item.key;
    showBikeFrameTypeDropdown = false;
    notifyListeners();
  }

  /// Selected Vehicle Car Features

  bool _isCarAvailable = false;
  bool get isCarAvailable => _isCarAvailable;

  void setVehicleAvailable(bool? value) {
    _isCarAvailable = value ?? true;
    notifyListeners();
  }

  void vehicleAvailabilityToggle(bool? value) {
    if (value == null) return;
    _isCarAvailable = value;
    notifyListeners();
  }

  void editIconFalse() {
    isTaxInfoEdit = false;
    isModelInfoEdit = false;
    isNotesInfoEdit = false;
  }

  String stripHtmlTags(String html) {
    final RegExp exp = RegExp(
      r'<[^>]*>',
      multiLine: true,
      caseSensitive: false,
    );
    return html.replaceAll(exp, '').trim();
  }

  void initializeAddVehicle() {
    isTaxInfoEdit = false;
    isModelInfoEdit = false;
    isNotesInfoEdit = false;
    clearAllControllers();
    selectedTags.clear();
    tagsController.clear();
    _tagsSearch = "";
    showTagsList = false;
    selectedVehicle = null;
    selectedDriver = null;
    selectedFutureDriver = null;
    selectedFleetManager = null;
    selectedFuelTypeKey = null;
    selectedVehicleType = null;
    selectedTransmissionTypeKey = null;
    _isChecked = false;
    _isCarAvailable = true;
    _planToChangeCar = false;
    _planToChangeBike = false;
    notifyListeners();
  }

  bool validateVehicleModel() {
    if (vehicleController.text.trim().isEmpty) {
      return false;
    }
    if (vehicleId == null && selectedVehicle == null) {
      return false;
    }
    return true;
  }

  void clearAllControllers() {
    categoryController.clear();
    vehicleController.clear();
    fleetManagerController.clear();
    futureDriverController.clear();
    driverController.clear();
    licensePlateController.clear();
    chassisNumberController.clear();
    lastOdometerController.clear();
    locationController.clear();
    tagsController.clear();
    assignedDateController.clear();
    orderDateController.clear();
    registrationDateController.clear();
    cancellationDateController.clear();
    horsePowerTaxationController.clear();
    firstContractDateController.clear();
    catalogValueController.clear();
    purchaseValueController.clear();
    residualValueController.clear();
    modelYearController.clear();
    modelSeatingCapacityController.clear();
    modelNoOfDoorsController.clear();
    modelColorController.clear();
    engineFuelTypeController.clear();
    engineTransmissionController.clear();
    enginePowerController.clear();
    engineRangeController.clear();
    engineC02EmissionController.clear();
    bikeFrameTypeController.clear();
    bikeFrameSizeController.clear();
    _hasElectricAssistance = false;
    engineEmissionStandardController.clear();
    vehicleDetailsNotes.clear();
  }

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void setModelDataInto(bool? trailerHook) {
    _isChecked = trailerHook ?? false;
    notifyListeners();
  }

  void trailerHitchedToggle(bool? value) {
    if (value == null) return;
    _isChecked = value;
    notifyListeners();
  }

  /// Vehicles Fetching for Dropdown

  List<vehiclesList.VehicleItem> get filteredVehicles {
    if (_vehicleList == null) return [];
    if (_search.isEmpty) {
      return _vehicleList!.records;
    }
    final q = _search.toLowerCase();
    return _vehicleList!.records.where((v) {
      return v.model.name.toLowerCase().contains(q) ||
          v.licensePlate.toLowerCase().contains(q);
    }).toList();
  }

  void validateTypedVehicle(BuildContext context) {
    final typedText = vehicleController.text.trim().toLowerCase();

    if (typedText.isEmpty) return;

    final exists =
        _vehicleList?.records.any(
          (v) => v.model.name.toLowerCase() == typedText,
        ) ??
        false;

    if (!exists) {
      selectedVehicle = null;

      final rootContext = Navigator.of(context, rootNavigator: true).context;
      CustomSnackbar.showError(rootContext, "Selected vehicle is not present");
    }
  }

  void selectVehicle(vehiclesList.VehicleItem vehicle) {
    selectedVehicle = vehicle;
    vehicleController.text = vehicle.model.name;
    _search = "";
    showVehicleList = false;
    notifyListeners();
  }

  Future<void> toggleVehicleList(BuildContext context) async {
    if (!showVehicleList && _vehicleList == null) {
      await fetchVehiclesList();
    }

    showVehicleList = !showVehicleList;
    notifyListeners();
  }

  void updateVehicleSearch(String value) {
    _search = value;
    fetchVehiclesList(query: value);
    notifyListeners();
  }

  Future<void> fetchVehiclesList({String query = ""}) async {
    if (isVehicleLoading) return;
    try {
      isVehicleLoading = true;
      notifyListeners();
      _vehicleList = await FetchFleetManager.fetchVehicles(query: query);
    } catch (e) {
    } finally {
      isVehicleLoading = false;
      notifyListeners();
    }
  }

  /// Vehicles Category for Dropdown

  List<VehicleCategoryItem> get filteredCategory {
    if (_vehicleCategorySearch.isEmpty) return vehicleCategories;

    final query = _vehicleCategorySearch.toLowerCase();
    return vehicleCategories
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
  }

  void selectVehicleCategory(VehicleCategoryItem category) {
    vehicleCategoryItem = category;
    categoryController.text = category.name;

    _vehicleCategorySearch = "";
    showVehicleCategoryList = false;
    vehicleCategoryError = false;

    notifyListeners();
  }

  Future<void> toggleVehicleCategoryList() async {
    if (!showVehicleCategoryList &&
        (modelVehicleCategory == null ||
            modelVehicleCategory!.records.isEmpty)) {
      await fetchVehicleCategories();
    }

    showVehicleCategoryList = !showVehicleCategoryList;
    notifyListeners();
  }

  void updateVehicleCategorySearch(String value) {
    _vehicleCategorySearch = value;
    notifyListeners();
  }

  List<VehicleCategoryItem> vehicleCategories = [];

  Future<void> fetchVehicleCategories() async {
    if (isVehicleCategoryLoading) return;

    try {
      isVehicleCategoryLoading = true;
      notifyListeners();
      modelVehicleCategory =
          await FetchFleetManager.fetchVehicleCategories();
      vehicleCategories = modelVehicleCategory!.records;
    } catch (e) {
    } finally {
      isVehicleCategoryLoading = false;
      notifyListeners();
    }
  }

  /// Tags fetching for Dropdown

  Future<void> fetchVehiclesTags() async {
    if (isTagsLoading) return;

    try {
      isTagsLoading = true;
      tagsError = false;
      notifyListeners();

      modelFleetVehicleTags = await FetchFleetManager.fetchTags();
    } catch (e) {
      tagsError = true;
    } finally {
      isTagsLoading = false;
      notifyListeners();
    }
  }

  List<FleetTagItem> get filteredTags {
    if (modelFleetVehicleTags == null) return [];

    if (_tagsSearch.isEmpty) {
      return modelFleetVehicleTags!.records;
    }

    final query = _tagsSearch.toLowerCase();

    return modelFleetVehicleTags!.records.where((tags) {
      return tags.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> toggleTagsList() async {
    if (!showTagsList &&
        (modelFleetVehicleTags == null ||
            modelFleetVehicleTags!.records.isEmpty)) {
      await fetchVehiclesTags();
    }

    showTagsList = !showTagsList;
    notifyListeners();
  }

  void updateTagsSearch(String value) {
    _tagsSearch = value;
    notifyListeners();
  }

  void toggleTagSelection(FleetTagItem tag) {
    final exists = selectedTags.any((t) => t.id == tag.id);

    if (exists) {
      selectedTags.removeWhere((t) => t.id == tag.id);
    } else {
      selectedTags.add(tag);
    }

    tagsController.text = selectedTags.map((e) => e.name).join(", ");

    tagsError = false;
    notifyListeners();
  }

  List<Record> get filteredDrivers {
    if (modelSeparateDriverList == null) return [];

    if (_driverSearch.isEmpty) {
      return modelSeparateDriverList!.records;
    }

    final query = _driverSearch.toLowerCase();

    return modelSeparateDriverList!.records.where((d) {
      return (d.completeName ?? "").toLowerCase().contains(query) ||
          (d.email ?? "").toLowerCase().contains(query) ||
          (d.phone ?? "").toLowerCase().contains(query);
    }).toList();
  }

  void selectDriver(Record driver) {
    selectedDriver = driver;
    driverId = driver.id;
    driverController.text = driver.completeName ?? "";
    _driverSearch = "";
    showDriverList = false;
    driverError = false;
    notifyListeners();
  }

  Future<void> toggleDriverList() async {
    if (!showDriverList &&
        (modelSeparateDriverList == null ||
            modelSeparateDriverList!.records.isEmpty)) {
      await fetchDriversList();
    }

    showDriverList = !showDriverList;
    notifyListeners();
  }

  void updateDriverSearch(String value) {
    _driverSearch = value;
    notifyListeners();
  }

  Future<void> fetchDriversList() async {
    if (isDriverLoading) return;

    try {
      isDriverLoading = true;
      notifyListeners();

      modelSeparateDriverList = await FetchedFleetDrivers.fetchDrivers();
    } catch (e) {
      driverError = true;
    } finally {
      isDriverLoading = false;
      notifyListeners();
    }
  }

  /// Future Driving Fetching

  List<Record> get filteredFutureDrivers {
    if (modelSeparateDriverList == null) return [];

    if (_futureDriverSearch.isEmpty) {
      return modelSeparateDriverList!.records;
    }
    final query = _futureDriverSearch.toLowerCase();
    return modelSeparateDriverList!.records.where((d) {
      return (d.completeName ?? "").toLowerCase().contains(query) ||
          (d.email ?? "").toLowerCase().contains(query) ||
          (d.phone ?? "").toLowerCase().contains(query);
    }).toList();
  }

  void selectFutureDriver(Record futureDriver) {
    selectedFutureDriver = futureDriver;
    futureDriverId = futureDriver.id;
    futureDriverController.text = futureDriver.completeName ?? "";
    _futureDriverSearch = "";
    showFutureDriverList = false;
    futureDriverError = false;
    notifyListeners();
  }

  Future<void> toggleFutureDriverList() async {
    if (!showFutureDriverList &&
        (modelSeparateDriverList == null ||
            modelSeparateDriverList!.records.isEmpty)) {
      await fetchDriversList();
    }

    showFutureDriverList = !showFutureDriverList;
    notifyListeners();
  }

  void updateFutureDriverSearch(String value) {
    _futureDriverSearch = value;
    notifyListeners();
  }

  Future<void> fetchFutureDriversList() async {
    if (isFutureDriverLoading) return;

    try {
      isFutureDriverLoading = true;
      notifyListeners();

      modelSeparateDriverList = await FetchedFleetDrivers.fetchDrivers();
    } catch (e) {
      futureDriverError = true;
    } finally {
      isFutureDriverLoading = false;
      notifyListeners();
    }
  }

  /// Fleet Manager Fetching

  List<UserRecord> get filteredFleetManagers {
    if (modelFetchFleetManager == null) return [];

    if (_fleetManagerSearch.isEmpty) {
      return modelFetchFleetManager!.records;
    }

    final query = _fleetManagerSearch.toLowerCase();

    return modelFetchFleetManager!.records.where((user) {
      return user.name.toLowerCase().contains(query);
    }).toList();
  }

  void selectFleetManager(UserRecord fleetManager) {
    selectedFleetManager = fleetManager;
    fleetManagerId = fleetManager.id;

    fleetManagerController.text = fleetManager.name;

    _fleetManagerSearch = "";
    showFleetManagerList = false;
    fleetManagerError = false;

    notifyListeners();
  }

  Future<void> toggleFleetManagerList() async {
    if (!showFleetManagerList &&
        (modelFetchFleetManager == null ||
            modelFetchFleetManager!.records.isEmpty)) {
      await fetchFleetManager();
    }

    showFleetManagerList = !showFleetManagerList;
    notifyListeners();
  }

  void updateFleetManagerSearch(String value) {
    if (!showFleetManagerList) return;
    _fleetManagerSearch = value;
    notifyListeners();
  }

  Future<void> fetchFleetManager() async {
    if (isFleetManagerLoading) return;

    try {
      isFleetManagerLoading = true;
      fleetManagerError = false;
      notifyListeners();

      modelFetchFleetManager = await FetchFleetManager.fetchUsers();

    } catch (e) {
      fleetManagerError = true;
    } finally {
      isFleetManagerLoading = false;
      notifyListeners();
    }
  }

  void _assignedVehicleToController(VehicleItem v) {
    assignedDateController.text = formattedDate(
      v.nextAssignationDate.toString(),
    );
    orderDateController.text = formattedDate(v.orderDate.toString());
    registrationDateController.text = formattedDate(
      v.acquisitionDate.toString(),
    );
    if (v.driver != null) {
      driverId = v.driver!.id;
      driverController.text = v.driver?.name ?? "";
    }
    if (v.futureDriver != null) {
      futureDriverId = v.futureDriver?.id ?? 0;
      futureDriverController.text = v.futureDriver?.name ?? "";
    }
    if (v.manager != null) {
      fleetManagerId = v.manager?.id ?? 0;
      fleetManagerController.text = v.manager?.name ?? "";
    }

    cancellationDateController.text = formattedDate(v.writeOffDate.toString());
    locationController.text = v?.location.toString() ?? "";
    chassisNumberController.text = v?.vinSn.toString() ?? "";
    vehicleController.text = v?.model?.name.toString() ?? "";
    categoryController.text = v?.category?.name.toString() ?? "";
    lastOdometerController.text = v?.odometer.toString() ?? "";
    licensePlateController.text = v?.licensePlate?.toString() ?? "";
    horsePowerTaxationController.text = v?.horsepowerTax?.toString() ?? "";
    firstContractDateController.text = formatDate(
      v.contractDateStart.toString(),
    );
    catalogValueController.text = v?.carValue.toString() ?? "";
    purchaseValueController.text = v?.netCarValue.toString() ?? "";
    residualValueController.text = v?.residualValue.toString() ?? "";
    setModelDataInto(v.trailerHook);
    if (selectedVehicleType == 'car') {
      _planToChangeCar = v.planToChangeCar;
    } else if (selectedVehicleType == 'bike') {
      _planToChangeBike = v.planToChangeBike;

      final frameKey = v.frameType.trim().toLowerCase();

      final matches = bikeFrameTypes
          .where((e) => e.key.toLowerCase() == frameKey)
          .toList();

      if (matches.isNotEmpty) {
        final matched = matches.first;
        selectedBikeFrameTypeKey = matched.key;
        bikeFrameTypeController.text = matched.label;
      } else {
        selectedBikeFrameTypeKey = null;
        bikeFrameTypeController.clear();
      }

      if (v.frameSize != null && v.frameSize > 0) {
        bikeFrameSizeController.text = v.frameSize.toStringAsFixed(0);
      } else {
        bikeFrameSizeController.clear();
      }

      _hasElectricAssistance = v.electricAssistance ?? false;
    }

    if (v.modelYear.isNotEmpty && v.modelYear != "false") {
      modelYearController.text = v.modelYear;
    } else {
      modelYearController.clear();
    }
    modelSeatingCapacityController.text = v?.seats.toString() ?? "";
    modelNoOfDoorsController.text = v?.doors.toString() ?? "";
    modelColorController.text = v?.color.toString() ?? "";
    engineFuelTypeController.text = v?.fuelType.toString() ?? "";
    engineTransmissionController.text = v?.transmission.toString() ?? "";
    enginePowerController.text = v?.power.toString() ?? "";
    engineRangeController.text = v?.vehicleRange.toString() ?? "";
    engineC02EmissionController.text = v?.co2.toString() ?? "";
    engineEmissionStandardController.text = v?.co2Standard.toString() ?? "";
    vehicleDetailsNotes.text = v?.description.toString() ?? "";
  }

  void toggleTaxInfoEditMode() {
    isTaxInfoEdit = !isTaxInfoEdit;
    notifyListeners();
  }

  void toggleModelInfoEdit() {
    isModelInfoEdit = !isModelInfoEdit;
    notifyListeners();
  }

  void toggleNotesInfoEdit() {
    isNotesInfoEdit = !isNotesInfoEdit;
    notifyListeners();
  }

  String formatDate(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == false ||
        dateString == "null" ||
        dateString == "-") {
      return "";
    }

    try {
      final cleaned = dateString.replaceAll(RegExp(r':\d+$'), '');
      final iso = cleaned.replaceFirst(' ', 'T');
      final dateTime = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  String formattedDate(String? dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString == "null" ||
        dateString == "-") {
      return "";
    }

    try {
      final cleaned = dateString.replaceAll(RegExp(r':\d+$'), '');
      final iso = cleaned.replaceFirst(' ', 'T');
      final dateTime = DateTime.parse(iso);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return "";
    }
  }

  Future<void> fetchVehicleDetails(int id) async {
    isVehicleDetailsLoading = true;
    notifyListeners();
    try {
      vehicleId = id;
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final client = await OdooSessionManager.getClient();
      final String serverVersionString = client!.sessionId!.serverVersion;
      final int majorVersion = int.parse(serverVersionString.split('.').first);

      final List<String> fields = [
        'id',
        'display_name',
        'state_id',
        'model_id',
        'license_plate',
        'vehicle_type',
        'driver_id',
        'future_driver_id',
        'manager_id',
        'category_id',
        'next_assignation_date',
        'frame_type',
        'frame_size',
        'electric_assistance',
        'order_date',
        'acquisition_date',
        'write_off_date',
        'vin_sn',
        'odometer',
        'odometer_unit',
        'location',
        'plan_to_change_car',
        'plan_to_change_bike',
        'horsepower_tax',
        'car_value',
        'net_car_value',
        'residual_value',
        'model_year',
        'seats',
        'doors',
        'color',
        'trailer_hook',
        'fuel_type',
        'transmission',
        'power',
        'vehicle_range',
        'co2',
        'co2_standard',
        'description',
        'tag_ids',
      ];

      if (majorVersion > 18) {
        fields.add('contract_date_start');
      } else {
        fields.add('first_contract_date');
      }

      final List<dynamic> response = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', '=', id],
          ],
          'fields': fields,
        },
      });

      if (response.isEmpty) {
        modelFleetVehicleDetails = ModelFleetVehicleDetails(
          length: 0,
          records: [],
        );

        isVehicleDetailsLoading = false;
        notifyListeners();
        return;
      }

      modelFleetVehicleDetails = ModelFleetVehicleDetails.fromJson(response);
      final vehicle = modelFleetVehicleDetails!.records.first;
      selectedVehicleType = normalizeVehicleType(vehicle.vehicleType);
      if (selectedVehicleType == 'bike') {
        await loadBikeFrameTypes();
      }

      _assignedVehicleToController(vehicle);

      final List<dynamic> tagResponse = await odooClient({
        'model': 'fleet.vehicle.tag',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'name', 'color'],
        },
      });

      final Map<int, TagItem> tagMap = {
        for (final e in tagResponse)
          e['id']: TagItem(
            id: e['id'],
            name: e['name'],
            color: e['color'] ?? 0,
          ),
      };

      vehicleTags = vehicle.tagIds
          .where((id) => tagMap.containsKey(id))
          .map((id) => tagMap[id]!)
          .toList();
      selectedTags = vehicleTags
          .map((t) => FleetTagItem(id: t.id, name: t.name, color: t.color))
          .toList();
      tagsController.text = selectedTags.map((e) => e.name).join(", ");
      await fetchVehiclesList();

      try {
        selectedVehicle = _vehicleList!.records.firstWhere(
          (v) => v.model.id == vehicle.model.id,
        );
      } catch (_) {
        selectedVehicle = null;
      }
      notifyListeners();
    } catch (e) {
      modelFleetVehicleDetails = null;
      vehicleTags = [];
    } finally {
      isVehicleDetailsLoading = false;
      notifyListeners();
    }
  }

  String normalizeVehicleType(String? type) {
    if (type == null) return '';
    final t = type.toLowerCase().trim();
    if (t.contains('bike') || t.contains('motor')) return 'bike';
    if (t.contains('car')) return 'car';
    return '';
  }

  void setSelectedVehicleDetailsLog(int index) {
    isTaxInfoEdit = false;
    isModelInfoEdit = false;
    isNotesInfoEdit = false;
    selectedVehicleDetailsIndex = index;
    reassignFromModel();
    notifyListeners();
  }

  void reassignFromModel() {
    if (modelFleetVehicleDetails == null ||
        modelFleetVehicleDetails!.records.isEmpty)
      return;

    _assignedVehicleToController(modelFleetVehicleDetails!.records.first);
  }

  void clearControllers() {
    horsePowerTaxationController.clear();
    firstContractDateController.clear();
    catalogValueController.clear();
    purchaseValueController.clear();
    residualValueController.clear();

    modelYearController.clear();
    modelSeatingCapacityController.clear();
    modelNoOfDoorsController.clear();
    modelColorController.clear();

    engineFuelTypeController.clear();
    engineTransmissionController.clear();
    enginePowerController.clear();
    engineRangeController.clear();
    engineC02EmissionController.clear();
    engineEmissionStandardController.clear();
  }

  Future<void> chooseDate(
    BuildContext context,
    TextEditingController textController,
  ) async {
    final DateTime today = DateTime.now();

    final DateTime safeInitialDate = initialDate.isBefore(today)
        ? today
        : initialDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
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
      initialDate = pickedDate;
      textController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      notifyListeners();
    }
  }

  Future<bool> addNewVehicleDetails() async {
    if (isVehiclesDetailsUpdating) return false;
    if (!validateVehicleModel()) return false;
    try {
      isVehiclesDetailsUpdating = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final client = await OdooSessionManager.getClient();
      final int majorVersion = int.parse(
        client!.sessionId!.serverVersion.split('.').first,
      );

      final Map<String, dynamic> values = {
        if (selectedVehicle?.model.id != null)
          'model_id': selectedVehicle!.model.id,
        if (vehicleCategoryItem != null) 'category_id': vehicleCategoryItem!.id,

        'license_plate': licensePlateController.text.trim().isEmpty
            ? false
            : licensePlateController.text.trim(),
        'tag_ids': selectedTags.isEmpty
            ? [
                [5, 0, 0],
              ]
            : [
                [6, 0, selectedTags.map((e) => e.id).toList()],
              ],
        'next_assignation_date': assignedDateController.text.trim().isEmpty
            ? false
            : assignedDateController.text.trim(),
        'order_date': orderDateController.text.trim().isEmpty
            ? false
            : orderDateController.text.trim(),
        'acquisition_date': registrationDateController.text.trim().isEmpty
            ? false
            : registrationDateController.text.trim(),
        'write_off_date': cancellationDateController.text.trim().isEmpty
            ? false
            : cancellationDateController.text.trim(),
        'vin_sn': chassisNumberController.text.trim().isEmpty
            ? false
            : chassisNumberController.text.trim(),
        'odometer': lastOdometerController.text.trim().isEmpty
            ? false
            : double.tryParse(lastOdometerController.text.trim()),
        'location': locationController.text.trim().isEmpty
            ? false
            : locationController.text.trim(),
        'horsepower_tax': horsePowerTaxationController.text.trim().isEmpty
            ? false
            : double.tryParse(horsePowerTaxationController.text.trim()),

        'car_value': catalogValueController.text.trim().isEmpty
            ? false
            : double.tryParse(catalogValueController.text.trim()),
        'net_car_value': purchaseValueController.text.trim().isEmpty
            ? false
            : double.tryParse(purchaseValueController.text.trim()),
        'residual_value': residualValueController.text.trim().isEmpty
            ? false
            : double.tryParse(residualValueController.text.trim()),
        'description': vehicleDetailsNotes.text.trim().isEmpty
            ? false
            : vehicleDetailsNotes.text.trim(),
        'seats': modelSeatingCapacityController.text.trim().isEmpty
            ? false
            : int.tryParse(modelSeatingCapacityController.text.trim()),

        'doors': modelNoOfDoorsController.text.trim().isEmpty
            ? false
            : int.tryParse(modelNoOfDoorsController.text.trim()),

        'color': modelColorController.text.trim().isEmpty
            ? false
            : modelColorController.text.trim(),
        'plan_to_change_car': selectedVehicleType == 'car'
            ? _planToChangeCar
            : false,
        'plan_to_change_bike': selectedVehicleType == 'bike'
            ? _planToChangeBike
            : false,
        'trailer_hook': _isChecked,
        'power': enginePowerController.text.trim().isEmpty
            ? false
            : double.tryParse(enginePowerController.text.trim()),
        'model_year': modelYearController.text.trim().isEmpty
            ? false
            : modelYearController.text.trim(),
        'fuel_type': selectedFuelTypeKey ?? false,
        'transmission': selectedTransmissionTypeKey ?? false,

        'vehicle_range': engineRangeController.text.trim().isEmpty
            ? false
            : int.tryParse(engineRangeController.text.trim()),
        'co2': engineC02EmissionController.text.trim().isEmpty
            ? false
            : double.tryParse(engineC02EmissionController.text.trim()),

        'co2_standard': engineEmissionStandardController.text.trim().isEmpty
            ? false
            : engineEmissionStandardController.text.trim(),
        'driver_id': driverId ?? false,
        'future_driver_id': futureDriverId ?? false,
        'manager_id': fleetManagerId ?? false,
      };

      final int newVehicleId = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'create',
        'args': [values],
        'kwargs': {},
      });
      if (newVehicleId <= 0) return false;

      if (firstContractDateController.text.trim().isNotEmpty) {
        if (majorVersion > 18) {
          await odooClient({
            'model': 'fleet.vehicle',
            'method': 'write',
            'args': [
              [newVehicleId],
              {'contract_date_start': firstContractDateController.text.trim()},
            ],
          });
        } else {
          await odooClient({
            'model': 'fleet.vehicle.log.contract',
            'method': 'create',
            'args': [
              {
                'vehicle_id': newVehicleId,
                'start_date': firstContractDateController.text.trim(),
              },
            ],
          });
        }
      }

      return true;
    } catch (e) {
      return false;
    } finally {

    }
  }

  void clearLoading(){
    isVehiclesDetailsUpdating = false;
    notifyListeners();
  }

  String displayValue(String? value) {
    if (value == null) return "-";
    if (value.trim().isEmpty) return "-";
    if (value.toLowerCase() == 'null') return "-";
    return value;
  }

  Future<bool> updateVehicleDetails() async {
    if (isVehiclesDetailsUpdating) return false;
    if (!validateVehicleModel()) return false;

    try {
      isVehiclesDetailsUpdating = true;
      notifyListeners();

      final odooClient = await OdooSessionManager.callKwWithCompany;
      final client = await OdooSessionManager.getClient();
      final String serverVersionString = client!.sessionId!.serverVersion;
      final int majorVersion = int.parse(serverVersionString.split('.').first);
      final String contractDateField = majorVersion > 18
          ? 'contract_date_start'
          : 'first_contract_date';
      final Map<String, dynamic> values = {
        if (selectedVehicle?.model.id != null)
          'model_id': selectedVehicle!.model.id,

        if (vehicleCategoryItem != null) 'category_id': vehicleCategoryItem!.id,

        'license_plate': licensePlateController.text.trim().isEmpty
            ? false
            : licensePlateController.text.trim(),

        'tag_ids': selectedTags.isEmpty
            ? [
                [5, 0, 0],
              ]
            : [
                [6, 0, selectedTags.map((e) => e.id).toList()],
              ],

        'next_assignation_date': assignedDateController.text.trim().isEmpty
            ? false
            : assignedDateController.text.trim(),

        'order_date': orderDateController.text.trim().isEmpty
            ? false
            : orderDateController.text.trim(),
        contractDateField: firstContractDateController.text.trim().isEmpty
            ? false
            : firstContractDateController.text.trim(),

        'acquisition_date': registrationDateController.text.trim().isEmpty
            ? false
            : registrationDateController.text.trim(),

        'write_off_date': cancellationDateController.text.trim().isEmpty
            ? false
            : cancellationDateController.text.trim(),

        'vin_sn': chassisNumberController.text.trim().isEmpty
            ? false
            : chassisNumberController.text.trim(),

        'odometer': lastOdometerController.text.trim().isEmpty
            ? false
            : double.tryParse(lastOdometerController.text.trim()),

        'location': locationController.text.trim().isEmpty
            ? false
            : locationController.text.trim(),

        'horsepower_tax': horsePowerTaxationController.text.trim().isEmpty
            ? false
            : double.tryParse(horsePowerTaxationController.text.trim()),

        'car_value': catalogValueController.text.trim().isEmpty
            ? false
            : double.tryParse(catalogValueController.text.trim()),

        'net_car_value': purchaseValueController.text.trim().isEmpty
            ? false
            : double.tryParse(purchaseValueController.text.trim()),

        'residual_value': residualValueController.text.trim().isEmpty
            ? false
            : double.tryParse(residualValueController.text.trim()),

        'description': vehicleDetailsNotes.text.trim().isEmpty
            ? false
            : vehicleDetailsNotes.text.trim(),

        'seats': modelSeatingCapacityController.text.trim().isEmpty
            ? false
            : int.tryParse(modelSeatingCapacityController.text.trim()),

        'doors': modelNoOfDoorsController.text.trim().isEmpty
            ? false
            : int.tryParse(modelNoOfDoorsController.text.trim()),

        'color': modelColorController.text.trim().isEmpty
            ? false
            : modelColorController.text.trim(),

        'plan_to_change_car': selectedVehicleType == 'car'
            ? _planToChangeCar
            : false,

        'plan_to_change_bike': selectedVehicleType == 'bike'
            ? _planToChangeBike
            : false,

        'trailer_hook': _isChecked,

        'fuel_type': selectedFuelTypeKey ?? false,
        'transmission': selectedTransmissionTypeKey ?? false,

        'power': enginePowerController.text.trim().isEmpty
            ? false
            : double.tryParse(enginePowerController.text.trim()),

        'vehicle_range': engineRangeController.text.trim().isEmpty
            ? false
            : int.tryParse(engineRangeController.text.trim()),

        'co2': engineC02EmissionController.text.trim().isEmpty
            ? false
            : double.tryParse(engineC02EmissionController.text.trim()),

        'co2_standard': engineEmissionStandardController.text.trim().isEmpty
            ? false
            : engineEmissionStandardController.text.trim(),

        'driver_id': driverId ?? false,
        'future_driver_id': futureDriverId ?? false,
        'manager_id': fleetManagerId ?? false,

        if (selectedVehicleType == 'bike') ...{
          'frame_type': selectedBikeFrameTypeKey ?? false,
          'frame_size': bikeFrameSizeController.text.trim().isEmpty
              ? false
              : int.tryParse(bikeFrameSizeController.text.trim()),
          'electric_assistance': _hasElectricAssistance,
        },
      };

      final bool updated = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'write',
        'args': [
          [vehicleId],
          values,
        ],
        'kwargs': {},
      });

      if (!updated) return false;

      return true;
      isVehiclesDetailsUpdating = false;
      notifyListeners();
    } catch (e) {
      return false;
    } finally {
      isVehiclesDetailsUpdating = false;
      notifyListeners();
    }
  }

  final List<int> yearsList = List.generate(
    DateTime.now().year - 1950,
    (index) => 1951 + index,
  ).reversed.toList();

  vehicleDetailsProvider() {
    filteredYears = yearsList;
  }

  void toggleYearDropdown() {
    showYearDropdown = !showYearDropdown;
    notifyListeners();
  }

  void filterYears(String query) {
    if (query.isEmpty) {
      filteredYears = yearsList;
    } else {
      filteredYears = yearsList
          .where((year) => year.toString().contains(query.trim()))
          .toList();
    }
    notifyListeners();
  }

  void selectYear(int year) {
    modelYearController.text = year.toString();
    showYearDropdown = false;
    notifyListeners();
  }

  /// Fuel Type Selection

  Future<void> loadFuelTypes() async {
    if (isFuelTypeLoading) return;

    try {
      isFuelTypeLoading = true;
      notifyListeners();

      final rawList = await FetchFleetManager.fetchFuelTypesRaw();

      fuelTypes = rawList
          .map(
            (e) => FuelTypeSelectionItem(
              key: e[0].toString(),
              label: e[1].toString(),
            ),
          )
          .toList();

      filteredFuelTypes = fuelTypes;
    } catch (e) {
    } finally {
      isFuelTypeLoading = false;
      notifyListeners();
    }
  }

  void filterFuelTypes(String value) {
    filteredFuelTypes = fuelTypes
        .where((e) => e.label.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void toggleFuelTypeDropdown() {
    showFuelTypeDropdown = !showFuelTypeDropdown;
    notifyListeners();
  }

  void selectFuelType(FuelTypeSelectionItem item) {
    engineFuelTypeController.text = item.label;
    selectedFuelTypeKey = item.key;
    showFuelTypeDropdown = false;
    notifyListeners();
  }

  /// Transmission Type Selection

  Future<void> loadTransmissionTypes() async {
    if (isTransmissionTypeLoading || transmissionTypes.isNotEmpty) return;

    try {
      isTransmissionTypeLoading = true;
      notifyListeners();

      final rawList =
          await FetchFleetManager.fetchTransmissionTypeRaw();

      transmissionTypes = rawList
          .map(
            (e) => TransmissionTypeSelectionItem(
              key: e[0].toString(),
              label: e[1].toString(),
            ),
          )
          .toList();

      filteredTransmissionTypes = transmissionTypes;
    } catch (e) {
    } finally {
      isTransmissionTypeLoading = false;
      notifyListeners();
    }
  }

  void filterTransmissionTypes(String value) {
    filteredTransmissionTypes = transmissionTypes
        .where((e) => e.label.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> toggleTransmissionTypeDropDown() async {
    if (!showTransmissionDropDown && transmissionTypes.isEmpty) {
      await loadTransmissionTypes();
    }
    showTransmissionDropDown = !showTransmissionDropDown;
    notifyListeners();
  }

  void selectTransmissionType(TransmissionTypeSelectionItem item) {
    engineTransmissionController.text = item.label;
    selectedTransmissionTypeKey = item.key;
    showTransmissionDropDown = false;
    notifyListeners();
  }

  String formatTextDate(String? date) {
    if (date == null || date.isEmpty || date == "false") {
      return "";
    }
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd yyyy').format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  /// Close All dropdowns
  void closeAllDropdowns() {
    showVehicleList = false;
    showDriverList = false;
    showFutureDriverList = false;
    showVehicleCategoryList = false;
    showFleetManagerList = false;
    showYearDropdown = false;
    showFuelTypeDropdown = false;
    showTransmissionDropDown = false;
    showTagsList = false;
    showBikeFrameTypeDropdown = false;
    notifyListeners();
  }

  bool isAssignmentDateEdit = false;

  void toggleAssignmentDateEdit() {
    isAssignmentDateEdit = !isAssignmentDateEdit;
    notifyListeners();
  }

  bool isOrderDateEdit = false;

  void toggleOrderDateEdit() {
    isOrderDateEdit = !isOrderDateEdit;
    notifyListeners();
  }

  void clearOnLogout() {
    selectedVehicleDetailsIndex = 0;

    isTaxInfoEdit = false;
    isModelInfoEdit = false;
    isNotesInfoEdit = false;
    isAssignmentDateEdit = false;
    isOrderDateEdit = false;

    closeAllDropdowns();

    ///  Business selections
    vehicleId = null;
    driverId = null;
    futureDriverId = null;
    fleetManagerId = null;

    selectedVehicle = null;
    selectedDriver = null;
    selectedFutureDriver = null;
    selectedFleetManager = null;
    vehicleCategoryItem = null;

    selectedFuelTypeKey = null;
    selectedTransmissionTypeKey = null;
    selectedBikeFrameTypeKey = null;

    selectedVehicleType = null;
    _isCarAvailable = true;
    _planToChangeCar = false;
    _planToChangeBike = false;
    _hasElectricAssistance = false;
    _isChecked = false;

    ///  Cached API data
    modelFleetVehicleDetails = null;
    modelFleetVehicleTags = null;
    _vehicleList = null;
    _search = '';
    modelVehicleCategory = null;
    modelSeparateDriverList = null;
    modelFetchFleetManager = null;

    vehicleTags.clear();
    selectedTags.clear();
    bikeFrameTypes.clear();
    filteredBikeFrameTypes.clear();
    fuelTypes.clear();
    filteredFuelTypes.clear();
    transmissionTypes.clear();
    filteredTransmissionTypes.clear();
    filteredYears.clear();

    ///  Controllers
    clearAllControllers();

    ///  Loading flags
    isVehicleDetailsLoading = false;
    isVehicleLoading = false;
    isTagsLoading = false;
    isDriverLoading = false;
    isFutureDriverLoading = false;
    isFleetManagerLoading = false;
    isFuelTypeLoading = false;
    isTransmissionTypeLoading = false;
    isBikeFrameTypeLoading = false;
    isVehiclesDetailsUpdating = false;
    initialDate = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    vehicleController.dispose();
    categoryController.dispose();
    fleetManagerController.dispose();
    futureDriverController.dispose();
    driverController.dispose();
    licensePlateController.dispose();
    chassisNumberController.dispose();
    lastOdometerController.dispose();
    locationController.dispose();
    tagsController.dispose();
    assignedDateController.dispose();
    orderDateController.dispose();
    registrationDateController.dispose();
    cancellationDateController.dispose();
    horsePowerTaxationController.dispose();
    firstContractDateController.dispose();
    catalogValueController.dispose();
    purchaseValueController.dispose();
    residualValueController.dispose();
    modelYearController.dispose();
    modelSeatingCapacityController.dispose();
    modelNoOfDoorsController.dispose();
    modelColorController.dispose();
    engineFuelTypeController.dispose();
    engineTransmissionController.dispose();
    enginePowerController.dispose();
    engineRangeController.dispose();
    engineC02EmissionController.dispose();
    engineEmissionStandardController.dispose();
    bikeFrameTypeController.dispose();
    bikeFrameSizeController.dispose();
    vehicleDetailsNotes.dispose();
    super.dispose();
  }
}

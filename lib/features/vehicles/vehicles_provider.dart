import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_vehicle_data.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/model_driver_model_list.dart' as drivers;
import '../../models/model_vehicle_model_list.dart' as vehicles;

class VehiclesProvider extends ChangeNotifier {
  bool isLoading = true;
  bool isVehiclesPageDataLoading = false;
  bool _isClearingField = false;
  bool isClearingAllFields = false;
  bool isFilterApplying = false;
  bool hasLoadedOnce = false;

  bool _showVehicleDropDown = false;
  bool get showVehicleDropDown => _showVehicleDropDown;

  bool _showDriverDropDown = false;
  bool get showDriverDropDown => _showDriverDropDown;

  bool _showVehicleTextFormField = false;
  bool get showVehicleTextFormField => _showVehicleTextFormField;

  String? _selectedFilterContainerToggle;
  String? get selectedFilterContainerToggle => _selectedFilterContainerToggle;

  String? selectedDriverName;
  String userName = "";

  Uint8List? userImageBytes;

  ModelFleetDashboardVehicleData? modelFleetDashboardVehicleData;
  vehicles.ModelVehicleModelList? modelVehicleModelList;
  drivers.ModelDriverModelList? modelDriverModelList;

  final Set<String> selectedFilters = {};

  List<dynamic> _currentDomain = [];
  List<FleetVehicle> filteredVehicles = [];

  TextEditingController searchFilterController = TextEditingController();
  TextEditingController searchFilterBrandTextController =
      TextEditingController();
  TextEditingController searchFilterDriverTextController =
      TextEditingController();

  void _setDomain(List<dynamic> domain) {
    _currentDomain = domain;
  }

  int get activeFiltersCount => selectedFilters.length;

  /// PAGINATION
  int _totalCount = 0;
  int get totalCount => _totalCount;

  static const int _pageSize = 40;
  int get pageSize => _pageSize;

  int _currentPage = 0;
  int get currentPage => _currentPage;
  int get startIndex => (_currentPage * _pageSize) + 1;

  int get endIndex {
    final end = (_currentPage + 1) * _pageSize;
    return end > _totalCount ? _totalCount : end;
  }

  bool get canGoPrevious => _currentPage > 0;
  bool get canGoNext => (_currentPage + 1) * _pageSize < _totalCount;

  /// Functions vehicles count
  Future<void> fetchVehicleCount({List<dynamic> domain = const []}) async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final response = await odooClient({
      'model': 'fleet.vehicle',
      'method': 'search_count',
      'args': [domain],
      'kwargs': {},
    });

    _totalCount = response as int;
    notifyListeners();
  }

  void showVehicleModelDropdownFunction(bool value) {
    _showVehicleDropDown = value;
    notifyListeners();
  }

  void showDriverModelDropdownFunction(bool value) {
    _showDriverDropDown = value;
    notifyListeners();
  }

  void selectDriver(String? driverName) {
    selectedDriverName = driverName ?? "";
    searchFilterDriverTextController.text = selectedDriverName.toString();
    showDriverModelDropdownFunction(false);
    notifyListeners();
  }

  Future<void> fetchVehiclesWithLoading({
    List<dynamic> domain = const [],
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await fetchVehicles(domain: domain);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void showVehicleTextFormFieldFunction(bool value) {
    _showVehicleTextFormField = value;
    notifyListeners();
  }

  /// Provider Calling
  VehiclesProvider() {
    searchFilterController.addListener(onSearchChanged);
    searchFilterBrandTextController.addListener(onFilterVehicleModel);
    fetchUserDetails();
    filterVehicleModel();
    filterDriverModel();
  }

  String? selectedBrandName;

  void selectBrand(String? brandName) {
    selectedBrandName = brandName ?? "";
    searchFilterBrandTextController.text = selectedBrandName.toString();
    showVehicleModelDropdownFunction(false);
    notifyListeners();
  }

  Future<void> applyFilterAll(BuildContext context) async {
    Navigator.pop(context);
    await applyVehicleTypeFilter();
  }

  /// Filter Toggle Setting
  bool isFilterSelected(String filterName) {
    return selectedFilters.contains(filterName);
  }

  void toggleFilter(String filterName) {
    if (selectedFilters.contains(filterName)) {
      selectedFilters.remove(filterName);
    } else {
      selectedFilters.add(filterName);
    }
    notifyListeners();
  }

  void clearSelectedFilters() {
    selectedFilters.clear();
    notifyListeners();
  }

  /// Apply Vehicle Type Filter (Car/Bike)
  Future<void> applyVehicleTypeFilter() async {
    isFilterApplying = true;
    notifyListeners();
    List<dynamic> domain = [];

    /// Filter conditions

    Map<String, List<dynamic>> filterDomains = {
      "Car": [
        ['vehicle_type', '=', 'car'],
      ],

      "Bike": [
        ['vehicle_type', '=', 'bike'],
      ],

      "Available": [
        "&",
        ["future_driver_id", "=", false],
        "|",
        ["driver_id", "=", false],
        "|",
        "&",
        ["plan_to_change_car", "=", true],
        ["vehicle_type", "=", "car"],
        "&",
        ["plan_to_change_bike", "=", true],
        ["vehicle_type", "=", "bike"],
      ],

      "Trailer Hook": [
        ["trailer_hook", "=", true],
      ],
      "Planned for Change": [
        "|",
        "&",
        ["vehicle_type", "=", "bike"],
        ["plan_to_change_bike", "=", true],
        "&",
        ["vehicle_type", "=", "car"],
        ["plan_to_change_car", "=", true],
      ],
    };

    List<dynamic> needActionDomain = [
      "|",
      ["contract_renewal_due_soon", "=", true],
      ["contract_renewal_overdue", "=", true],
    ];

    List<dynamic> archivedDomain = [
      ["active", "=", false],
    ];

    List<String> selected = selectedFilters.toList();

    List<String> vehicleFilters = selected
        .where((f) => filterDomains.containsKey(f))
        .toList();

    if (vehicleFilters.isEmpty) {
      domain = [];
    } else if (vehicleFilters.length == 1) {
      domain = filterDomains[vehicleFilters[0]]!;
    } else {
      domain = [];
      int count = vehicleFilters.length;

      for (int i = 0; i < count - 1; i++) {
        domain.add('|');
      }

      for (var filter in vehicleFilters) {
        domain.addAll(filterDomains[filter]!);
      }
    }

    /// Second Condition Check
    if (selected.contains("Need Action")) {
      if (domain.isEmpty) {
        domain = needActionDomain;
      } else {
        domain = ["&", ...domain, ...needActionDomain];
      }
    }

    /// Third Condition Check
    if (selected.contains("Archived")) {
      if (domain.isEmpty) {
        domain = archivedDomain;
      } else {
        domain = ["&", ...domain, ...archivedDomain];
      }
    }

    await fetchVehicles(domain: domain, resetPage: true, fetchCount: true);
    isFilterApplying = false;
    notifyListeners();
  }

  /// Search
  void onSearchChanged() {
    if (_isClearingField || isClearingAllFields) return;
    searchFilteredVehicles(searchFilterController.text.trim());
  }

  void onFilterVehicleModel() {
    if (isClearingAllFields) return;
    final brandName = searchFilterBrandTextController.text.trim();
    filterByBrandName(brandName);
  }

  Future<void> nextPage() async {
    if (!canGoNext) return;
    _currentPage++;
    await fetchVehicles(domain: _currentDomain);
  }

  Future<void> previousPage() async {
    if (!canGoPrevious) return;
    _currentPage--;
    await fetchVehicles(domain: _currentDomain);
  }

  /// User Details
  Future<void> fetchUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dbName = prefs.getString('database');
      final String? serverUrl = prefs.getString('serverUrl');
      final String? email = prefs.getString('email');
      final String? password = prefs.getString('password');
      int? id = prefs.getInt('sessionUserId');

      if ([dbName, serverUrl, email, password].contains(null)) return;

      final odooClient = await OdooSessionManager.callKwWithCompany;

      if (id != null) {
        final List<dynamic> users = await odooClient({
          'model': 'res.users',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', id],
            ],
            'fields': ['name', 'image_1920'],
          },
        });

        if (users.isNotEmpty) {
          final user = users.first;
          userName = user['name'] ?? "-";
          final String? imageBase64 = user['image_1920'];
          if (imageBase64 != null && imageBase64.isNotEmpty) {
            try {
              userImageBytes = base64Decode(imageBase64);
            } catch (e) {
              userImageBytes = null;
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {}
  }

  Future<void> fetchVehicles({
    List<dynamic> domain = const [],
    bool resetPage = false,
    bool fetchCount = false,
  }) async {
    try {
      if (resetPage) _currentPage = 0;
      _setDomain(domain);

      final odooClient = await OdooSessionManager.callKwWithCompany;
      final offset = _currentPage * _pageSize;

      if (fetchCount) {
        final count = await odooClient({
          'model': 'fleet.vehicle',
          'method': 'search_count',
          'args': [domain],
          'kwargs': {},
        });

        _totalCount = count as int;
      }

      ///  fetch page data
      final List<dynamic> vehicleList = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'limit': _pageSize,
          'offset': offset,
          'fields': [
            'image_128',
            'license_plate',
            'model_id',
            'category_id',
            'driver_id',
            'future_driver_id',
            'tag_ids',
            'vehicle_type',
            'active',
          ],
        },
      });

      filteredVehicles = vehicleList
          .map((e) => FleetVehicle.fromJson(e))
          .toList();

      notifyListeners();
    } catch (e) {}
  }

  Future<void> refreshVehicles() async {
    isLoading = true;
    notifyListeners();
    await fetchVehicles(domain: [], resetPage: true, fetchCount: true);
    isLoading = false;
    notifyListeners();
  }

  /// Fetch Vehicle Details
  Future<void> fetchVehiclesPageData() async {
    if (hasLoadedOnce) return;
    isLoading = true;
    notifyListeners();

    await fetchVehicles(
      domain: [],
      resetPage: false,
      fetchCount: _totalCount == 0,
    );

    isLoading = false;
    hasLoadedOnce = true;
    notifyListeners();
  }

  /// Fetch Vehicle Model data
  Future<void> filterVehicleModel() async {
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;

      final List<dynamic> vehicleModelList = await odooClient({
        'model': 'fleet.vehicle.model',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'id',
            'brand_id',
            'name',
            'vehicle_count',
            'vehicle_type',
            'default_co2',
          ],
        },
      });

      final records = vehicleModelList.map((e) {
        Map<String, dynamic> recordJson = Map<String, dynamic>.from(e);
        if (recordJson["brand_id"] != null && recordJson["brand_id"] is List) {
          recordJson["brand"] = {
            "id": recordJson["brand_id"][0],
            "name": recordJson["brand_id"][1],
          };
        }
        return vehicles.Record.fromJson(recordJson);
      }).toList();
      modelVehicleModelList = vehicles.ModelVehicleModelList(
        length: records.length,
        records: records,
      );

      notifyListeners();
    } catch (e) {}
  }

  /// Fetch Driver Model data
  Future<void> filterDriverModel() async {
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;

      final List<dynamic> driverModelList = await odooClient({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'complete_name'],
        },
      });
      final records = driverModelList.map((e) {
        Map<String, dynamic> recordJson = Map<String, dynamic>.from(e);

        return drivers.Record.fromJson(recordJson);
      }).toList();
      modelDriverModelList = drivers.ModelDriverModelList(
        length: records.length,
        records: records,
      );
      notifyListeners();
    } catch (e) {}
  }

  void showKeyboardAfterBuild(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  /// Search filter VehicleData
  Future<void> searchFilteredVehicles(String query) async {
    await fetchVehicles(
      resetPage: true,
      fetchCount: true,
      domain: [
        '|',
        '|',
        '|',
        '|',
        ['license_plate', 'ilike', query],
        ['model_id', 'ilike', query],
        ['driver_id', 'ilike', query],
        ['category_id', 'ilike', query],
        ['tag_ids', 'ilike', query],
      ],
    );
  }

  /// Clear Search Field
  Future<void> clearList() async {
    _isClearingField = true;
    searchFilterController.clear();
    await fetchVehicles(domain: [], resetPage: true, fetchCount: true);
    notifyListeners();
    _isClearingField = false;
  }

  Future<void> clearAllFilter() async {
    isClearingAllFields = true;
    searchFilterController.clear();
    searchFilterBrandTextController.clear();
    searchFilterDriverTextController.clear();

    selectedBrandName = null;
    selectedDriverName = null;
    selectedFilters.clear();
    _currentPage = 0;
    _currentDomain = [];
    notifyListeners();
    await fetchVehicles(domain: [], resetPage: true, fetchCount: true);

    isClearingAllFields = false;
  }

  Future<void> filterByBrandName(String brandName) async {
    if (brandName.isEmpty) {
      notifyListeners();
      return;
    }

    await fetchVehicles(
      domain: [
        ['model_id', 'ilike', brandName],
      ],
    );
  }

  void setSelectedFilterContainerToggle(String value) {
    if (_selectedFilterContainerToggle == value) {
      _selectedFilterContainerToggle = "";
    } else {
      _selectedFilterContainerToggle = value;
    }
    notifyListeners();
  }

  void clearOnLogout() {
    ///  User info
    userName = "-";
    userImageBytes = null;

    ///  Vehicle & dashboard data
    modelFleetDashboardVehicleData = null;
    filteredVehicles.clear();
    _totalCount = 0;
    _currentPage = 0;
    _currentDomain = [];
    hasLoadedOnce = false;

    ///  Filters & selections
    selectedFilters.clear();
    selectedBrandName = null;
    selectedDriverName = null;
    _selectedFilterContainerToggle = null;

    ///  UI flags
    isVehiclesPageDataLoading = false;
    isLoading = false;
    isFilterApplying = false;
    _showVehicleDropDown = false;
    _showDriverDropDown = false;
    _showVehicleTextFormField = false;

    ///  Clear controllers safely
    _isClearingField = true;
    isClearingAllFields = true;

    searchFilterController.clear();
    searchFilterBrandTextController.clear();
    searchFilterDriverTextController.clear();

    _isClearingField = false;
    isClearingAllFields = false;

    notifyListeners();
  }

  /// for Test case
  @visibleForTesting
  void setTotalCountForTest(int count) {
    _totalCount = count;
  }
}

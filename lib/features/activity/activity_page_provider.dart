import 'package:flutter/cupertino.dart';
import 'package:mobo_projects/models/model_activity_contract_log.dart';
import 'package:mobo_projects/models/model_activity_service_log.dart';
import 'package:mobo_projects/models/model_activity_fuel_log.dart';
import 'package:mobo_projects/models/model_activity_odometer_log.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPageProvider extends ChangeNotifier {
  TextEditingController searchActivityText = TextEditingController();

  final Set<String> selectedServiceFilters = {};
  final Set<String> selectedContractFilters = {};

  String _searchQuery = "";
  String userName = "";

  int selectedActivityIndex = 0;

  Uint8List? uint8list;
  ModelActivityFuelLog? modelActivityFuelLog;
  ModelActivityOdometerLog? modelActivityOdometerLog;
  ModelActivityServiceLog? modelActivityServiceLog;
  ModelActivityContractLog? modelActivityContractLog;

  bool isServiceInitialLoad = true;
  bool isContractInitialLoad = true;
  bool isFuelDataLoading = true;
  bool isOdometerDataLoading = false;
  bool isServiceDataLoading = false;
  bool isContractDataLoading = false;
  bool isOdometerInitialLoad = true;

  ///Pagination length
  static const int _fuelPageSize = 40;
  static const int _odometerPageSize = 40;
  static const int _servicePageSize = 40;
  static const int _contractPageSize = 40;

  bool _hasInitialized = false;
  bool get hasInitialized => _hasInitialized;

  int? _vehicleId;
  int? get vehicleId => _vehicleId;

  ///Total Count Initialize
  int _fuelTotalCount = 0;
  int get fuelTotalCount => _fuelTotalCount;

  int _odometerTotalCount = 0;
  int get odometerTotalCount => _odometerTotalCount;

  int _serviceTotalCount = 0;
  int get serviceTotalCount => _serviceTotalCount;

  int _contractTotalCount = 0;
  int get contractTotalCount => _contractTotalCount;

  ///Pagination current indexing -  Fuel Page

  int _fuelCurrentPage = 0;
  int get fuelStartIndex => (_fuelCurrentPage * _fuelPageSize) + 1;
  int get fuelEndIndex {
    final end = (_fuelCurrentPage + 1) * _fuelPageSize;
    return end > _fuelTotalCount ? _fuelTotalCount : end;
  }

  bool get canFuelNext =>
      (_fuelCurrentPage + 1) * _fuelPageSize < _fuelTotalCount;
  bool get canFuelPrevious => _fuelCurrentPage > 0;

  ///Pagination current indexing -  Odometer Page

  int _odometerCurrentPage = 0;
  int get odometerStartIndex => (_odometerCurrentPage * _odometerPageSize) + 1;
  int get odometerEndIndex {
    final end = (_odometerCurrentPage + 1) * _odometerPageSize;
    return end > _odometerTotalCount ? _odometerTotalCount : end;
  }

  bool get canOdometerNext =>
      (_odometerCurrentPage + 1) * _odometerPageSize < _odometerTotalCount;
  bool get canOdometerPrevious => _odometerCurrentPage > 0;

  ///Pagination current indexing -  Service Page

  int _serviceCurrentPage = 0;
  int get serviceStartIndex => (_serviceCurrentPage * _servicePageSize) + 1;
  int get serviceEndIndex {
    final end = (_serviceCurrentPage + 1) * _servicePageSize;
    return end > _serviceTotalCount ? _serviceTotalCount : end;
  }

  bool get canServiceNext =>
      (_serviceCurrentPage + 1) * _servicePageSize < _serviceTotalCount;
  bool get canServicePrevious => _serviceCurrentPage > 0;

  ///Pagination current indexing -  Contract Page

  int _contractCurrentPage = 0;
  int get contractStartIndex => (_contractCurrentPage * _contractPageSize) + 1;
  int get contractEndIndex {
    final end = (_contractCurrentPage + 1) * _contractPageSize;
    return end > _contractTotalCount ? _contractTotalCount : end;
  }

  bool get canContractNext =>
      (_contractCurrentPage + 1) * _contractPageSize < _contractTotalCount;
  bool get canContractPrevious => _contractCurrentPage > 0;

  /// Filter Length
  int get activeServiceFilterCount => selectedServiceFilters.length;
  bool isServiceFilterSelected(String filter) =>
      selectedServiceFilters.contains(filter);

  int get activeContractFilterCount => selectedContractFilters.length;
  bool isContractFilterSelected(String filter) =>
      selectedContractFilters.contains(filter);

  /// Update Search
  void updateSearch(String value) {
    final query = value.trim();
    _searchQuery = query;
    searchActivityText.text = _searchQuery;
    _resetPages();
    notifyListeners();
    onRefresh();
  }

  ///Reset Pages
  void _resetPages() {
    _fuelCurrentPage = 0;
    _odometerCurrentPage = 0;
    _serviceCurrentPage = 0;
    _contractCurrentPage = 0;
  }

  void markInitialized() {
    _hasInitialized = true;
  }

  void setVehicleId(int? id) {
    _vehicleId = id;
  }

  List<List<dynamic>> _vehicleDomain() {
    if (_vehicleId == null) return [];
    return [
      ['vehicle_id', '=', _vehicleId],
    ];
  }

  Map<String, List<dynamic>> serviceFilterDomains = {
    "Archived": [
      ["active", "=", false],
    ],
  };

  final Map<String, List<dynamic>> contractFilterDomains = {
    "In progress": [
      ["state", "=", "open"],
    ],
    "Expired": [
      ["state", "=", "expired"],
    ],
  };

  final Map<String, List<dynamic>> contractFilterDomains1 = {
    "Archived": [
      ["active", "=", false],
    ],
  };

  List<dynamic> _buildDomains(List<List<dynamic>> conditions) {
    if (conditions.isEmpty) return [];
    if (conditions.length == 1) {
      return [conditions.first];
    }
    final List<dynamic> domain = [];
    for (int i = 0; i < conditions.length - 1; i++) {
      domain.add('|');
    }
    for (final condition in conditions) {
      domain.add(condition);
    }
    return domain;
  }

  /// Contracts Filter Domain
  List<dynamic> _contractFilterDomain() {
    final List<List<dynamic>> orConditions = [];
    final List<List<dynamic>> andConditions = [];
    for (final filter in selectedContractFilters) {
      if (contractFilterDomains.containsKey(filter)) {
        orConditions.addAll(
          contractFilterDomains[filter]!.map((e) => List<dynamic>.from(e)),
        );
      } else if (contractFilterDomains1.containsKey(filter)) {
        andConditions.addAll(
          contractFilterDomains1[filter]!.map((e) => List<dynamic>.from(e)),
        );
      }
    }
    return [...andConditions, ..._buildDomains(orConditions)];
  }

  /// Service Filter Domain
  List<dynamic> _serviceFilterDomain() {
    final List<List<dynamic>> conditions = [];

    for (final filter in selectedServiceFilters) {
      final filterDomain = serviceFilterDomains[filter];
      if (filterDomain != null) {
        conditions.addAll(filterDomain.map((e) => List<dynamic>.from(e)));
      }
    }
    return _buildDomains(conditions);
  }

  /// Toggle filter Service
  void toggleServiceFilter(String filter) {
    selectedServiceFilters.contains(filter)
        ? selectedServiceFilters.remove(filter)
        : selectedServiceFilters.add(filter);
    notifyListeners();
  }

  /// Toggle filter Contract
  void toggleContractFilter(String filter) {
    selectedContractFilters.contains(filter)
        ? selectedContractFilters.remove(filter)
        : selectedContractFilters.add(filter);
    notifyListeners();
  }

  Future<void> fetchUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dbName = prefs.getString('database');
      final String? serverUrl = prefs.getString('serverUrl');
      final String? email = prefs.getString('email');
      final String? password = prefs.getString('password');
      final int? id = prefs.getInt('sessionUserId');
      if ([dbName, serverUrl, email, password, id].contains(null)) return;

      final odooClient = await OdooSessionManager.callKwWithCompany;

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
            uint8list = base64Decode(imageBase64);
          } catch (_) {
            uint8list = null;
          }
        } else {
          uint8list = null;
        }

        notifyListeners();
      }
    } catch (e) {}
  }

  void setSelectedActivityLog(int index) {
    if (selectedActivityIndex == index) return;
    selectedActivityIndex = index;
    searchActivityText.clear();
    _odometerCurrentPage = 0;
    notifyListeners();
    onRefresh();
  }

  /// Clear Filters
  void clearServiceFilters() {
    selectedServiceFilters.clear();
    notifyListeners();
  }

  void clearContractFilters() {
    selectedContractFilters.clear();
    notifyListeners();
  }

  /// Search Domains (Fuel)
  List<dynamic> _fuelSearchDomain() {
    if (_searchQuery.isEmpty) return [];
    return [
      '|',
      '|',
      '|',
      ['purchaser_id.name', 'ilike', _searchQuery],
      ['vehicle_id.name', 'ilike', _searchQuery],
      ['description', 'ilike', _searchQuery],
      ['service_type_id.name', 'ilike', _searchQuery],
    ];
  }

  /// Search Domains (Odometer)
  List<dynamic> _odometerSearchDomain() {
    if (_searchQuery.isEmpty) return [];
    return [
      '|',
      ['driver_id.name', 'ilike', _searchQuery],
      ['vehicle_id.name', 'ilike', _searchQuery],
    ];
  }

  /// Search Domains (Service)
  List<dynamic> _serviceSearchDomain() {
    if (_searchQuery.isEmpty) return [];
    return [
      '|',
      '|',
      '|',
      ['purchaser_id.name', 'ilike', _searchQuery],
      ['vehicle_id.name', 'ilike', _searchQuery],
      ['description', 'ilike', _searchQuery],
      ['service_type_id.name', 'ilike', _searchQuery],
    ];
  }

  /// Search Domains (Contract)
  List<dynamic> _contractSearchDomain() {
    if (_searchQuery.isEmpty) return [];
    return [
      '|',
      '|',
      ['purchaser_id.name', 'ilike', _searchQuery],
      ['vehicle_id.name', 'ilike', _searchQuery],
      ['insurer_id.name', 'ilike', _searchQuery],
    ];
  }

  /// Pagination reset (Service)
  void resetServicePagination() {
    _serviceCurrentPage = 0;
    _serviceTotalCount = 0;
  }

  /// Pagination reset (Contract)
  void resetContractPagination() {
    _contractCurrentPage = 0;
    _contractTotalCount = 0;
  }

  /// Clear and Reload (Service)
  Future<void> clearServiceFiltersAndReload() async {
    selectedServiceFilters.clear();
    _serviceCurrentPage = 0;
    _serviceTotalCount = 0;
    await fetchServiceActivityDetails(resetPage: true);
    notifyListeners();
  }

  /// Clear and Reload (Contract)
  Future<void> clearContractFiltersAndReload() async {
    selectedContractFilters.clear();
    _contractCurrentPage = 0;
    _contractTotalCount = 0;
    await fetchContractActivityDetails(resetPage: true);
    notifyListeners();
  }

  /// Fetch Fuel Activity Details
  Future<void> fetchFuelLogActivity({bool resetPage = false}) async {
    if (resetPage) _fuelCurrentPage = 0;
    try {
      isFuelDataLoading = true;
      notifyListeners();

      final odooClient = await OdooSessionManager.callKwWithCompany;

      final count = await odooClient({
        'model': 'fleet.vehicle.log.services',
        'method': 'search_count',
        'args': [
          [
            ..._vehicleDomain(),
            ..._fuelSearchDomain(),
            ['service_type_id.name', 'ilike', 'fuel'],
          ],
        ],
      });

      _fuelTotalCount = count as int;

      final offset = _fuelCurrentPage * _fuelPageSize;

      final response = await odooClient({
        'model': 'fleet.vehicle.log.services',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ..._vehicleDomain(),
            ..._fuelSearchDomain(),
            ['service_type_id.name', 'ilike', 'fuel'],
          ],

          'limit': _fuelPageSize,
          'offset': offset,
          'fields': [
            'id',
            'date',
            'description',
            'service_type_id',
            'vehicle_id',
            'purchaser_id',
            'purchaser_employee_id',
            'vendor_id',
            'inv_ref',
            'notes',
            'amount',
            'currency_id',
            'state',
          ],
        },
      });

      modelActivityFuelLog = ModelActivityFuelLog.fromList(response);
    } catch (e) {
    } finally {
      isFuelDataLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Odometer Activity Details
  Future<void> fetchOdometerActivityDetails({bool resetPage = false}) async {
    if (isOdometerDataLoading) return;
    if (resetPage) _odometerCurrentPage = 0;

    try {
      isOdometerDataLoading = true;
      notifyListeners();

      final odooClient = await OdooSessionManager.callKwWithCompany;

      final count = await odooClient({
        'model': 'fleet.vehicle.odometer',
        'method': 'search_count',
        'args': [
          [..._vehicleDomain(), ..._odometerSearchDomain()],
        ],
        'kwargs': {},
      });

      _odometerTotalCount = count as int;

      final offset = _odometerCurrentPage * _odometerPageSize;

      final response = await odooClient({
        'model': 'fleet.vehicle.odometer',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [..._vehicleDomain(), ..._odometerSearchDomain()],
          'limit': _odometerPageSize,
          'offset': offset,
          'fields': [
            'id',
            'date',
            'vehicle_id',
            'driver_id',
            'driver_employee_id',
            'value',
            'unit',
          ],
        },
      });

      modelActivityOdometerLog = ModelActivityOdometerLog.fromJson(response);
    } finally {
      isOdometerInitialLoad = false;
      isOdometerDataLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Service Activity Details
  Future<void> fetchServiceActivityDetails({bool resetPage = false}) async {
    if (isServiceDataLoading) return;
    if (resetPage) _serviceCurrentPage = 0;
    try {
      if (isServiceInitialLoad) {
        isServiceDataLoading = true;
        notifyListeners();
      }
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final count = await odooClient({
        'model': 'fleet.vehicle.log.services',
        'method': 'search_count',
        'args': [
          [
            ..._vehicleDomain(),
            ..._serviceSearchDomain(),
            ..._serviceFilterDomain(),
          ],
        ],
        'kwargs': {},
      });
      _serviceTotalCount = count as int;
      final offset = _serviceCurrentPage * _servicePageSize;
      final response = await odooClient({
        'model': 'fleet.vehicle.log.services',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ..._vehicleDomain(),
            ..._serviceSearchDomain(),
            ..._serviceFilterDomain(),
          ],
          'limit': _servicePageSize,
          'offset': offset,
          'fields': [
            'id',
            'date',
            'description',
            'service_type_id',
            'vehicle_id',
            'purchaser_id',
            'vendor_id',
            'amount',
            'currency_id',
            'state',
          ],
        },
      });

      modelActivityServiceLog = ModelActivityServiceLog.fromJson(response);
    } finally {
      isServiceInitialLoad = false;
      isServiceDataLoading = false;
      notifyListeners();
    }
  }

  /// Fetch Contracts Activity Details
  Future<void> fetchContractActivityDetails({bool resetPage = false}) async {
    if (isContractDataLoading) return;
    if (resetPage) _contractCurrentPage = 0;
    try {
      if (isContractInitialLoad) {
        isContractDataLoading = true;
        notifyListeners();
      }
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final count = await odooClient({
        'model': 'fleet.vehicle.log.contract',
        'method': 'search_count',
        'args': [
          [
            ..._vehicleDomain(),
            ..._contractSearchDomain(),
            ..._contractFilterDomain(),
          ],
        ],
        'kwargs': {},
      });
      _contractTotalCount = count as int;
      final offset = _contractCurrentPage * _contractPageSize;
      final response = await odooClient({
        'model': 'fleet.vehicle.log.contract',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ..._vehicleDomain(),
            ..._contractSearchDomain(),
            ..._contractFilterDomain(),
          ],
          'limit': _contractPageSize,
          'offset': offset,
          'fields': [
            'id',
            'name',
            'start_date',
            'expiration_date',
            'vehicle_id',
            'insurer_id',
            'purchaser_id',
            'cost_generated',
            'currency_id',
            'state',
          ],
        },
      });
      modelActivityContractLog = ModelActivityContractLog.fromJson(response);
    } finally {
      isContractInitialLoad = false;
      isContractDataLoading = false;
      notifyListeners();
    }
  }

  /// Next & previous of pagination (Fuel)
  Future<void> nextFuelPage() async {
    if (!canFuelNext) return;
    _fuelCurrentPage++;
    await fetchFuelLogActivity();
  }

  Future<void> previousFuelPage() async {
    if (!canFuelPrevious) return;
    _fuelCurrentPage--;
    await fetchFuelLogActivity();
  }

  /// Next & previous of pagination (Odometer)
  Future<void> nextOdometerPage() async {
    if (!canOdometerNext) return;
    _odometerCurrentPage++;
    await fetchOdometerActivityDetails();
  }

  Future<void> previousOdometerPage() async {
    if (!canOdometerPrevious) return;
    _odometerCurrentPage--;
    await fetchOdometerActivityDetails();
  }

  /// Next & previous of pagination (Services)
  Future<void> nextServicePage() async {
    if (!canServiceNext) return;
    _serviceCurrentPage++;
    await fetchServiceActivityDetails();
  }

  Future<void> previousServicePage() async {
    if (!canServicePrevious) return;
    _serviceCurrentPage--;
    await fetchServiceActivityDetails();
  }

  /// Next & previous of pagination (Contracts)
  Future<void> nextContractPage() async {
    if (!canContractNext) return;
    _contractCurrentPage++;
    await fetchContractActivityDetails();
  }

  Future<void> previousContractPage() async {
    if (!canContractPrevious) return;
    _contractCurrentPage--;
    await fetchContractActivityDetails();
  }

  /// Refresh setting according to index
  Future<void> onRefresh() async {
    switch (selectedActivityIndex) {
      case 0:
        await fetchFuelLogActivity();
        break;
      case 1:
        await fetchOdometerActivityDetails();
        break;
      case 2:
        await fetchServiceActivityDetails();
        break;
      case 3:
        await fetchContractActivityDetails();
        break;
    }
  }

  /// Hint text in Search
  String get searchHintText {
    switch (selectedActivityIndex) {
      case 0:
        return "Search Fuel Logs";
      case 1:
        return "Search Odometer Logs";
      case 2:
        return "Search Service Logs";
      case 3:
        return "Search Contract Logs";
      default:
        return "Search";
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = "";
    searchActivityText.clear();
    _resetPages();
    notifyListeners();
    onRefresh();
  }

  /// Clear while Logout
  void clearOnLogout() {
    userName = "-";
    uint8list = null;
    _vehicleId = null;

    _searchQuery = "";
    searchActivityText.clear();

    selectedServiceFilters.clear();
    selectedContractFilters.clear();

    selectedActivityIndex = 0;
    _hasInitialized = false;
    isOdometerInitialLoad = true;

    _fuelCurrentPage = 0;
    _fuelTotalCount = 0;

    _odometerCurrentPage = 0;
    _odometerTotalCount = 0;

    resetServicePagination();
    resetContractPagination();

    modelActivityFuelLog = null;
    modelActivityOdometerLog = null;
    modelActivityServiceLog = null;
    modelActivityContractLog = null;

    isFuelDataLoading = false;
    isOdometerDataLoading = false;
    isServiceDataLoading = false;
    isContractDataLoading = false;

    notifyListeners();
  }

  @override
  void dispose() {
    searchActivityText.dispose();
    super.dispose();
  }

  /// For Test Case
  @protected
  void setFuelTotalCountForTest(int value) {
    _fuelTotalCount = value;
  }

  @protected
  void setOdometerTotalCountForTest(int value) {
    _odometerTotalCount = value;
  }

  @protected
  void setServiceTotalCountForTest(int value) {
    _serviceTotalCount = value;
  }

  @protected
  void setContractTotalCountForTest(int value) {
    _contractTotalCount = value;
  }
}

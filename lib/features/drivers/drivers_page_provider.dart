import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobo_projects/models/model_driver_lists.dart' as drivers;
import 'package:mobo_projects/models/model_driving_history.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_vehicle_data.dart';
import 'package:mobo_projects/models/model_driving_history_vehicles.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:mobo_projects/features/vehicles_details/fetch_fleet_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriversPageProvider extends ChangeNotifier {
  TextEditingController driverSearchFilterController = TextEditingController();

  String userName = "";
  String? selectedVehicle;

  String _searchQuery = "";
  bool get isSearching => _searchQuery.isNotEmpty;

  bool isPageChanging = false;
  bool isLoading = false;
  bool isInitialLoad = true;
  bool isDrivingHistoryLoading = false;

  Map<String, dynamic> driversList = {};
  Map<int, bool> vehicleDropdownStatus = {};

  List<ModelDrivingHistoryVehicles> drivingHistory = [];

  Uint8List? uint8list;
  Timer? timer;
  drivers.ModelDriverLists? modelDriverLists;
  ModelFleetDashboardVehicleData? modelFleetDashboardVehicleData;
  ModelDrivingHistory? modelDrivingHistory;

  /// Total count
  int _totalCount = 0;
  int get totalCount => _totalCount;

  /// pagination current page
  int _currentPage = 0;
  int get currentPage => _currentPage;

  /// Pagination length
  static const int _pageSize = 40;
  int get pageSize => _pageSize;

  int get startIndex => (_currentPage * _pageSize) + 1;

  int get endIndex {
    final end = (_currentPage + 1) * _pageSize;
    return end > _totalCount ? _totalCount : end;
  }

  bool get canGoPrevious => _currentPage > 0;
  bool get canGoNext => (_currentPage + 1) * _pageSize < _totalCount;

  Future<void> nextPage() async {
    if (!canGoNext || isPageChanging) return;
    _currentPage++;
    isPageChanging = true;
    notifyListeners();
    await _fetchPageDataOnly();
    isPageChanging = false;
    notifyListeners();
  }

  Future<void> previousPage() async {
    if (!canGoPrevious || isPageChanging) return;
    _currentPage--;
    isPageChanging = true;
    notifyListeners();
    await _fetchPageDataOnly();
    isPageChanging = false;
    notifyListeners();
  }

  Future<void> _fetchPageDataOnly() async {
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final domain = _buildSearchDomain();
      final offset = _currentPage * _pageSize;
      final response = await odooClient({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': domain,
          'limit': _pageSize,
          'offset': offset,
          'fields': [
            'id',
            'avatar_128',
            'complete_name',
            'phone',
            'email',
            'city',
          ],
        },
      });

      modelDriverLists = drivers.ModelDriverLists.fromJson({
        'length': response.length,
        'records': response,
      });
    } catch (e) {}
  }

  void resetPagination() {
    _currentPage = 0;
  }

  void setSelectedVehicle(String? vehicle) {
    selectedVehicle = vehicle;
    notifyListeners();
  }

  void toggleVehicleDropdown(int vehicleId) {
    vehicleDropdownStatus[vehicleId] =
        !(vehicleDropdownStatus[vehicleId] ?? false);
    notifyListeners();
  }

  /// build Search Domains
  List<dynamic> _buildSearchDomain() {
    if (_searchQuery.isEmpty) return [];
    return [
      '|',
      '|',
      ['complete_name', 'ilike', _searchQuery],
      ['phone', 'ilike', _searchQuery],
      ['email', 'ilike', _searchQuery],
    ];
  }

  /// Fetch user details
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

  /// Decode Image
  Uint8List? decodeBase64Image(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      final bytes = base64Decode(base64Str);
      if (bytes.length < 200) return null;
      return bytes;
    } catch (e) {
      return null;
    }
  }

  /// Fetch Vehicles
  Future<void> fetchVehicles({bool force = false}) async {
    if (!force && modelFleetDashboardVehicleData != null) return;
    try {
      isLoading = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final List<dynamic> vehicleResponse = await odooClient({
        'model': 'fleet.vehicle',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [],
          'fields': [
            'license_plate',
            'model_id',
            'category_id',
            'manager_id',
            'driver_id',
            'driver_employee_id',
            'future_driver_id',
            'future_driver_employee_id',
            'vin_sn',
            'co2',
            'acquisition_date',
            'tag_ids',
            'state_id',
            'contract_renewal_due_soon',
            'contract_renewal_overdue',
            'contract_state',
            'vehicle_type',
          ],
        },
      });
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        vehicleResponse,
      );
      final allTagIds = list
          .expand((v) => (v['tag_ids'] as List))
          .cast<int>()
          .toSet()
          .toList();
      Map<int, Map<String, dynamic>> tagMap = {};
      if (allTagIds.isNotEmpty) {
        final List<dynamic> tagsData = await odooClient({
          'model': 'fleet.vehicle.tag',
          'method': 'read',
          'args': [allTagIds],
          'kwargs': {
            'fields': ['name', 'color'],
          },
        });
        for (var tag in tagsData) {
          tagMap[tag['id']] = {'name': tag['name'], 'color': tag['color']};
        }
        for (var vehicle in list) {
          final tagIds = (vehicle['tag_ids'] as List?)?.cast<int>() ?? [];
          vehicle['tags'] = tagIds.isNotEmpty
              ? tagIds.map((id) => tagMap[id]).where((t) => t != null).toList()
              : [];
        }
      }
      modelFleetDashboardVehicleData = ModelFleetDashboardVehicleData.fromJson(
        list,
      );
      notifyListeners();
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  ImageProvider? safeMemoryImage(Uint8List? bytes) {
    if (bytes == null) return null;
    if (bytes.length < 500) return null;
    try {
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Fetch Drivers
  Future<void> fetchDrivers({bool resetPage = false}) async {
    try {
      if (resetPage) _currentPage = 0;
      isLoading = true;
      notifyListeners();
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final domain = _buildSearchDomain();
      final count = await odooClient({
        'model': 'res.partner',
        'method': 'search_count',
        'args': [domain],
        'kwargs': {},
      });
      _totalCount = count as int;
      await _fetchPageDataOnly();
    } finally {
      isLoading = false;
      isInitialLoad = false;
      notifyListeners();
    }
  }

  /// Fetch Driving History
  Future<void> fetchDrivingHistory({bool force = false}) async {
    if (!force && modelDrivingHistory != null) return;
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final response = await odooClient({
        'model': 'fleet.vehicle.assignation.log',
        'method': 'search_read',
        'args': [[]],
        'kwargs': {
          'fields': [
            'id',
            'vehicle_id',
            'driver_id',
            'driver_employee_id',
            'date_start',
            'date_end',
            'attachment_number',
          ],
        },
      });
      final Map<String, dynamic> data = {
        "length": response.length,
        "records": response,
      };
      modelDrivingHistory = ModelDrivingHistory.fromJson(data);
    } catch (e) {}
  }

  /// Fetching Driving History Count
  Future<void> fetchDrivingHistoryCount() async {
    try {
      final odooClient = await OdooSessionManager.callKwWithCompany;
      final response = await odooClient({
        'model': 'fleet.vehicle.assignation.log',
        'method': 'search_count',
        'args': [[]],
        'kwargs': {},
      });
      final List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        response,
      );
    } catch (e) {}
  }

  /// Update Driver search
  void updateDriverSearch(String query) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 300), () async {
      _searchQuery = query.trim();
      await fetchDrivers(resetPage: true);
    });
  }

  /// driving History
  Future<void> fetchVehicleDrivingHistory({int? vehicleId}) async {
    isDrivingHistoryLoading = true;
    notifyListeners();
    try {
      drivingHistory = await FetchFleetManager.fetchDrivingHistory(
        vehicleId: vehicleId,
      );
    } catch (e) {
      drivingHistory = [];
    }
    isDrivingHistoryLoading = false;
    notifyListeners();
  }

  void clearOnLogout() {
    ///  Cancel debounce timer
    timer?.cancel();
    timer = null;

    ///  Reset user/session info
    userName = "-";
    uint8list = null;

    ///  Reset pagination
    _totalCount = 0;
    _currentPage = 0;
    isPageChanging = false;

    ///  Reset search
    _searchQuery = "";
    driverSearchFilterController.clear();

    ///  Clear models / cached data
    modelDriverLists = null;
    modelFleetDashboardVehicleData = null;
    modelDrivingHistory = null;
    drivingHistory = [];

    ///  Reset UI state
    isLoading = false;
    isInitialLoad = true;
    selectedVehicle = null;
    vehicleDropdownStatus.clear();
    isDrivingHistoryLoading = false;

    notifyListeners();
  }

  /// for test case
  @visibleForTesting
  void setTotalCountForTest(int count) {
    _totalCount = count;
  }
}

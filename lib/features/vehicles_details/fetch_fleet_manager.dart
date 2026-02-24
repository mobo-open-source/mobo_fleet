import 'package:mobo_projects/models/model_driving_history_vehicles.dart';
import 'package:mobo_projects/models/model_fetch_fleet_manager.dart';
import 'package:mobo_projects/models/model_fetch_vehicle_category.dart';
import 'package:mobo_projects/models/model_fleet_vehicle_tags.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';


/// Fetch Fleet Manager - Users
class FetchFleetManager {
  static Future<ModelFetchFleetManager> fetchUsers() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final Map<String, dynamic> response = await odooClient({
      'model': 'res.users',
      'method': 'web_search_read',
      'args': [
        [
          ['state', '=', 'active'],
        ],
        {'id': {}, 'name': {}, 'login': {}, 'state': {}},
        0,
        50,
      ],

      'kwargs': {},
    });

    return ModelFetchFleetManager.fromJson(response);
  }

   static Future<ModelFetchVehicleCategory> fetchVehicleCategories() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final List<dynamic> response = await odooClient({
      'model': 'fleet.vehicle.model.category',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': ['id', 'sequence', 'name'],
      },
    });

    return ModelFetchVehicleCategory.fromJson({
      'length': response.length,
      'records': response,
    });
  }

   static Future<List<List<dynamic>>> fetchFuelTypesRaw() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final response = await odooClient({
      'model': 'fleet.vehicle',
      'method': 'fields_get',
      'args': [],
      'kwargs': {
        'attributes': ['selection'],
      },
    });

    return List<List<dynamic>>.from(response['fuel_type']['selection']);
  }

  static Future<List<List<dynamic>>> fetchTransmissionTypeRaw() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final response = await odooClient({
      'model': 'fleet.vehicle',
      'method': 'fields_get',
      'args': [],
      'kwargs': {
        'attributes': ['selection'],
      },
    });

    return List<List<dynamic>>.from(response['transmission']['selection']);
  }
    static Future<ModelFleetVehicleTags> fetchTags() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final List<dynamic> response = await odooClient({
      'model': 'fleet.vehicle.tag',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'fields': ['id', 'name', 'color'],
      },
    });

    return ModelFleetVehicleTags.fromJson(response);
  }

    static Future<ModelVehicleList> fetchVehicles({
    String? query,
    int limit = 20,
  }) async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final domain = query!.isEmpty
        ? []
        : [
            '|',
            ['license_plate', 'ilike', query],
            ['model_id', 'ilike', query],
          ];

    final List<dynamic> response = await odooClient({
      'model': 'fleet.vehicle',
      'method': 'search_read',
      'args': [domain],
      'kwargs': {
        'limit': limit,
        'fields': [
          'id',
          'active',
          'license_plate',
          'model_id',
          'category_id',
          'manager_id',
          'driver_id',
          'driver_employee_id',
          'vehicle_type',
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

    return ModelVehicleList.fromJson(response);
  }


   static Future<List<ModelDrivingHistoryVehicles>> fetchDrivingHistory({
    int? vehicleId,
  }) async {
    final odooClient = await OdooSessionManager.callKwWithCompany;
    final List<dynamic> response = await odooClient({
      'model': 'fleet.vehicle.assignation.log',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': vehicleId != null
            ? [
                ['vehicle_id', '=', vehicleId],
              ]
            : [],
        'fields': [
          'id',
          'vehicle_id',
          'driver_id',
          'driver_employee_id',
          'date_start',
          'date_end',
          'attachment_number',
        ],
        'order': 'date_start desc',
      },
    });

    return response
        .map(
          (e) =>
              ModelDrivingHistoryVehicles.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  static Future<List<List<dynamic>>> fetchBikeFrameTypesRaw() async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final response = await odooClient({
      'model': 'fleet.vehicle',
      'method': 'fields_get',
      'args': [],
      'kwargs': {
        'attributes': ['selection'],
      },
    });

    /// SAFETY CHECK
    if (response == null ||
        response['frame_type'] == null ||
        response['frame_type']['selection'] == null) {
      return [];
    }

    return List<List<dynamic>>.from(response['frame_type']['selection']);
  }
}

class BikeFrameTypeItem {
  final String key;
  final String label;

  const BikeFrameTypeItem({required this.key, required this.label});

  factory BikeFrameTypeItem.fromRaw(List<dynamic> raw) {
    return BikeFrameTypeItem(key: raw[0].toString(), label: raw[1].toString());
  }

  static Future<List<ModelDrivingHistoryVehicles>> fetchDrivingHistory({
    int? vehicleId,
  }) async {
    final odooClient = await OdooSessionManager.callKwWithCompany;
    final List<dynamic> response = await odooClient({
      'model': 'fleet.vehicle.assignation.log',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': vehicleId != null
            ? [
                ['vehicle_id', '=', vehicleId],
              ]
            : [],
        'fields': [
          'id',
          'vehicle_id',
          'driver_id',
          'driver_employee_id',
          'date_start',
          'date_end',
          'attachment_number',
        ],
        'order': 'date_start desc',
      },
    });

    return response
        .map(
          (e) =>
              ModelDrivingHistoryVehicles.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }
}


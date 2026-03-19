import 'package:mobo_projects/models/model_service_type_list.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';

/// Fetch Fleet Service Types
class FetchFleetServicesTypes {
  static Future<ModelServiceTypeList> fetchServiceTypes({
    String? query,
    String? category,
  }) async {
    final odooClient = await OdooSessionManager.callKwWithCompany;

    final List<dynamic> response = await odooClient({
      'model': 'fleet.service.type',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          if (category != null && category.isNotEmpty)
            ['category', '=', category],

          if (query != null && query.trim().isNotEmpty)
            ['name', 'ilike', query],
        ],
        'fields': ['id', 'name', 'category'],
        'limit': 20,
      },
    });

    return ModelServiceTypeList.fromJson(response);
  }
}

import 'package:flutter/material.dart';
import 'package:mobo_projects/features/admin_permissioncheck/widget_admin_permission.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:provider/provider.dart';

class FleetPermissionView extends StatelessWidget {
  final Widget child;
  final String pageName;
  const FleetPermissionView({
    super.key,
    required this.child,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FleetPermissionProvider>(
      builder: (context, perm, _) {
        if (!perm.hasChecked || perm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!perm.canAccessFleet) {
          return WidgetAdminPermission(pageName: pageName);
        }

        return child;
      },
    );
  }
}

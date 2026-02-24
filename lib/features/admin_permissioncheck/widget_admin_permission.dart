import 'package:flutter/material.dart';
import 'package:mobo_projects/core/designs/custom_designs.dart';

class WidgetAdminPermission extends StatelessWidget {
  final String pageName;
  const WidgetAdminPermission({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: isDarkTheme ? AllDesigns.white : Colors.white,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lock_outline, color: Colors.red, size: 26),
                    SizedBox(width: 10),
                    Text(
                      "Access Denied",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'You do not have access to the Fleet $pageName page. '
                  'Please contact your administrator for permission.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

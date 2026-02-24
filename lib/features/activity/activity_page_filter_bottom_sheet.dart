import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:provider/provider.dart';
import '../../core/designs/custom_designs.dart';

class ActivityPageFilterBottomSheet extends StatelessWidget {
  final bool isDarkTheme;
  final int activityIndex;

  const ActivityPageFilterBottomSheet({
    super.key,
    required this.isDarkTheme,
    required this.activityIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityPageProvider>();

    final bool isService = activityIndex == 2;
    final bool isContract = activityIndex == 3;

    final serviceFilters = provider.serviceFilterDomains;
    final contractFilters = provider.contractFilterDomains;
    final contractExtraFilters = provider.contractFilterDomains1;

    final activeFilters = isService
        ? provider.selectedServiceFilters
        : provider.selectedContractFilters;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _title("Filter", isDarkTheme),
                InkWell(
                  onTap: () async {
                    if (isService) {
                      provider.clearServiceFilters();
                      provider.resetServicePagination();
                      await provider.fetchServiceActivityDetails(
                        resetPage: true,
                      );
                      Navigator.pop(context);
                    } else {
                      provider.clearContractFilters();
                      provider.resetContractPagination();
                      await provider.fetchContractActivityDetails(
                        resetPage: true,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 26,
                    color: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.greyShade700Color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle("Active filters", isDarkTheme),
            const SizedBox(height: 10),

            activeFilters.isEmpty
                ? Text(
                    "No active filters",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkTheme
                          ? AllDesigns.greyShade400Color
                          : AllDesigns.greyShade600Color,
                    ),
                  )
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: activeFilters.map((filter) {
                      return Chip(
                        label: Text(filter),
                        backgroundColor: AllDesigns.red50,
                        labelStyle: const TextStyle(
                          color: AllDesigns.appColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 10),

            _sectionTitle("Filters", isDarkTheme),
            const SizedBox(height: 12),

            if (isService)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: serviceFilters.keys.map((filter) {
                    final selected = provider.isServiceFilterSelected(filter);
                    return GestureDetector(
                      onTap: () => provider.toggleServiceFilter(filter),
                      child: _FilterCard(
                        label: filter,
                        selected: selected,
                        isDarkTheme: isDarkTheme,
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (isContract) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: contractFilters.keys.map((filter) {
                    final selected = provider.isContractFilterSelected(filter);
                    return GestureDetector(
                      onTap: () => provider.toggleContractFilter(filter),
                      child: _FilterCard(
                        label: filter,
                        selected: selected,
                        isDarkTheme: isDarkTheme,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: contractExtraFilters.keys.map((filter) {
                    final selected = provider.isContractFilterSelected(filter);
                    return GestureDetector(
                      onTap: () => provider.toggleContractFilter(filter),
                      child: _FilterCard(
                        label: filter,
                        selected: selected,
                        isDarkTheme: isDarkTheme,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    text: "Clear All",
                    color: isDarkTheme
                        ? Colors.grey.shade900
                        : AllDesigns.whiteColor,
                    textColor: isDarkTheme
                        ? AllDesigns.whiteColor
                        : AllDesigns.blackColor,
                    borderColor: AllDesigns.whiteColor,
                    onTap: () async {
                      if (isService) {
                        provider.clearServiceFilters();
                        provider.resetServicePagination();
                        await provider.fetchServiceActivityDetails(
                          resetPage: true,
                        );
                      } else {
                        provider.clearContractFilters();
                        provider.resetContractPagination();
                        await provider.fetchContractActivityDetails(
                          resetPage: true,
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _actionButton(
                    text: "Apply",
                    color: AllDesigns.appColor,
                    textColor: Colors.white,
                    borderColor: AllDesigns.appColor,
                    onTap: () async {
                      if (isService) {
                        provider.resetServicePagination();
                        await provider.fetchServiceActivityDetails(
                          resetPage: true,
                        );
                      } else {
                        provider.resetContractPagination();
                        await provider.fetchContractActivityDetails(
                          resetPage: true,
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

Widget _title(String text, bool isDarkTheme) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.blackColor,
    ),
  );
}

Widget _sectionTitle(String text, bool isDarkTheme) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: isDarkTheme ? AllDesigns.whiteColor : AllDesigns.appColor,
    ),
  );
}

Widget _actionButton({
  required String text,
  required Color color,
  required Color textColor,
  required Color borderColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

class _FilterCard extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDarkTheme;

  const _FilterCard({
    required this.label,
    required this.selected,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected
            ? AllDesigns.appColor
            : AllDesigns.appColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            HugeIcon(
              icon: HugeIcons.strokeRoundedTick02,
              size: 18,
              color: Colors.white,
            ),
          if (selected) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AllDesigns.greyShade700Color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

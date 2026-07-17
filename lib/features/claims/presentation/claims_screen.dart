import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/widgets/empty_state.dart';
import 'package:reimburse_mate/features/claims/application/filter_notifier.dart';
import 'package:reimburse_mate/features/claims/presentation/claim_detail_screen.dart';
import 'widgets/claim_list_tile.dart';
import 'widgets/filter_bar.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  List<Reimbursement> _applyFilters(List<Reimbursement> claims, FilterState filters) {
    var list = claims;

    // Search query
    if (filters.searchQuery.isNotEmpty) {
      final q = filters.searchQuery.toLowerCase();
      list = list.where((c) =>
          c.projectCode.toLowerCase().contains(q) ||
          c.particulars.toLowerCase().contains(q) ||
          c.note.toLowerCase().contains(q)).toList();
    }

    // Status filter
    if (filters.statusFilter != null) {
      list = list.where((c) => c.status == filters.statusFilter!.dbKey).toList();
    }

    // Category filter
    if (filters.categoryFilter != null) {
      list = list.where((c) => c.category == filters.categoryFilter!.name).toList();
    }

    // Sorting
    switch (filters.sortBy) {
      case SortOption.dateNewest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighest:
        list.sort((a, b) => (b.amount ?? 0.0).compareTo(a.amount ?? 0.0));
        break;
      case SortOption.amountLowest:
        list.sort((a, b) => (a.amount ?? 0.0).compareTo(b.amount ?? 0.0));
        break;
      case SortOption.project:
        list.sort((a, b) => a.projectCode.compareTo(b.projectCode));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsNotifierProvider);
    final filters = ref.watch(filterProvider);
    final selectState = ref.watch(multiSelectProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Claims',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (option) => ref.read(filterProvider.notifier).setSortOption(option),
            itemBuilder: (context) => [
              const PopupMenuItem(value: SortOption.dateNewest, child: Text('Newest Date')),
              const PopupMenuItem(value: SortOption.dateOldest, child: Text('Oldest Date')),
              const PopupMenuItem(value: SortOption.amountHighest, child: Text('Highest Amount')),
              const PopupMenuItem(value: SortOption.amountLowest, child: Text('Lowest Amount')),
              const PopupMenuItem(value: SortOption.project, child: Text('Project Name')),
            ],
          ),
          TextButton(
            onPressed: () {
              if (selectState.isMultiSelectMode) {
                ref.read(multiSelectProvider.notifier).clearSelection();
              } else {
                ref.read(multiSelectProvider.notifier).enterSelectMode();
              }
            },
            child: Text(selectState.isMultiSelectMode ? 'Cancel' : 'Select'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          FilterBar(
            selectedStatus: filters.statusFilter,
            onStatusChanged: (status) => ref.read(filterProvider.notifier).setStatus(status),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search claims...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
              ),
              onChanged: (val) => ref.read(filterProvider.notifier).setSearchQuery(val),
            ),
          ),

          // List body
          Expanded(
            child: claimsAsync.when(
              data: (claims) {
                final filtered = _applyFilters(claims, filters);
                if (filtered.isEmpty) {
                  return const EmptyState(
                    title: 'No claims match your filters',
                    subtitle: 'Reset filters or adjust search criteria.',
                    icon: Icons.search_off_rounded,
                  );
                }

                // The multi-select action bar (count, delete, File Claims)
                // lives in HomeScreen's bottom nav bar now — it morphs into
                // the selection toolbar instead of floating a second bar
                // above it. See HomeScreen's bottomNavigationBar.
                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected = selectState.selectedIds.contains(item.id);

                    return ClaimListTile(
                      item: item,
                      isSelected: isSelected,
                      isMultiSelectActive: selectState.isMultiSelectMode,
                      onLongPress: () {
                        ref.read(multiSelectProvider.notifier).toggle(item.id);
                      },
                      onTap: () {
                        if (selectState.isMultiSelectMode) {
                          ref.read(multiSelectProvider.notifier).toggle(item.id);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClaimDetailScreen(claim: item),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

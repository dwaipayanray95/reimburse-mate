import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/database/app_database.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/core/widgets/empty_state.dart';
import 'package:reimburse_mate/features/claims/application/filter_notifier.dart';
import 'package:reimburse_mate/features/claims/presentation/claim_detail_screen.dart';
import 'package:reimburse_mate/features/filing/presentation/file_claims_screen.dart';
import 'widgets/claim_list_tile.dart';
import 'widgets/filter_bar.dart';
import 'widgets/multi_select_action_bar.dart';

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

                return Stack(
                  children: [
                    ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.only(bottom: 80),
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
                    ),

                    // Slide up action bar
                    if (selectState.selectedIds.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: MultiSelectActionBar(
                          count: selectState.selectedIds.length,
                          onClear: () => ref.read(multiSelectProvider.notifier).clearSelection(),
                          onBatchDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete entries?'),
                                content: Text('Do you want to permanently remove ${selectState.selectedIds.length} items?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(claimsNotifierProvider.notifier).batchDelete(selectState.selectedIds.toList());
                              ref.read(multiSelectProvider.notifier).clearSelection();
                            }
                          },
                          onFileClaims: () {
                            final selectedClaims = claims
                                .where((c) => selectState.selectedIds.contains(c.id))
                                .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileClaimsScreen(claims: selectedClaims),
                              ),
                            ).then((_) {
                              ref.read(multiSelectProvider.notifier).clearSelection();
                            });
                          },
                        ),
                      ),
                  ],
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

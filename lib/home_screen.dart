import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reimburse_mate/core/providers.dart';
import 'package:reimburse_mate/features/dashboard/presentation/dashboard_screen.dart';
import 'package:reimburse_mate/features/claims/presentation/claims_screen.dart';
import 'package:reimburse_mate/features/filing/presentation/file_claims_screen.dart';
import 'package:reimburse_mate/features/new_entry/presentation/new_entry_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardScreen(),
    const ClaimsScreen(),
  ];

  Future<void> _confirmBatchDelete(BuildContext context, Set<String> selectedIds) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entries?'),
        content: Text('Do you want to permanently remove ${selectedIds.length} items?'),
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
      await ref.read(claimsNotifierProvider.notifier).batchDelete(selectedIds.toList());
      ref.read(multiSelectProvider.notifier).clearSelection();
    }
  }

  void _fileSelectedClaims(BuildContext context, Set<String> selectedIds) {
    final claims = ref.read(claimsNotifierProvider).valueOrNull ?? [];
    final selectedClaims = claims.where((c) => selectedIds.contains(c.id)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FileClaimsScreen(claims: selectedClaims)),
    ).then((_) {
      ref.read(multiSelectProvider.notifier).clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The nav bar morphs into the selection toolbar while claims are
    // selected, rather than floating a second bar above it — no gap, one
    // panel. Also hides the FAB, which would otherwise sit on top of it.
    final selectState = ref.watch(multiSelectProvider);
    final isMultiSelecting = selectState.isMultiSelectMode;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            // Bold, seed-derived tone straight from the M3 color engine
            // (ColorScheme.fromSeed) instead of a flat hand-picked neutral.
            color: theme.colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.08 : 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              SizedBox(
                height: 72,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isMultiSelecting
                      ? _SelectionToolbar(
                          key: const ValueKey('selection'),
                          count: selectState.selectedIds.length,
                          onClear: () => ref.read(multiSelectProvider.notifier).clearSelection(),
                          onBatchDelete: () => _confirmBatchDelete(context, selectState.selectedIds),
                          onFileClaims: () => _fileSelectedClaims(context, selectState.selectedIds),
                        )
                      : Row(
                          key: const ValueKey('nav'),
                          children: [
                            _NavItem(
                              icon: Icons.dashboard_outlined,
                              selectedIcon: Icons.dashboard_rounded,
                              isSelected: _currentIndex == 0,
                              onTap: () => setState(() => _currentIndex = 0),
                            ),
                            _NavItem(
                              icon: Icons.receipt_long_outlined,
                              selectedIcon: Icons.receipt_long_rounded,
                              isSelected: _currentIndex == 1,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
      floatingActionButton: isMultiSelecting
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewEntryScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 6,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onBatchDelete;
  final VoidCallback onFileClaims;

  const _SelectionToolbar({
    super.key,
    required this.count,
    required this.onClear,
    required this.onBatchDelete,
    required this.onFileClaims,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: theme.colorScheme.onPrimaryContainer),
            onPressed: onClear,
            tooltip: 'Cancel',
          ),
          Text(
            '$count Selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: onBatchDelete,
            tooltip: 'Delete selected',
          ),
          const SizedBox(width: 4),
          Material(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onFileClaims,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send_rounded, size: 16, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 6),
                    Text(
                      'File Claims',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 28,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

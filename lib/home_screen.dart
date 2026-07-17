import 'package:flutter/material.dart';
import 'package:reimburse_mate/features/dashboard/presentation/dashboard_screen.dart';
import 'package:reimburse_mate/features/claims/presentation/claims_screen.dart';
import 'package:reimburse_mate/features/new_entry/presentation/new_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardScreen(),
    const ClaimsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            color: theme.brightness == Brightness.light
                ? const Color(0xFFF2F3FA)
                : const Color(0xFF1A1B1F),
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
              NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 96,
                  backgroundColor: Colors.transparent,
                  indicatorColor: theme.brightness == Brightness.light
                      ? const Color(0xFFDCE2FF)
                      : const Color(0xFF293042),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    return IconThemeData(
                      size: 26,
                      color: states.contains(WidgetState.selected)
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.55),
                    );
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    return TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: states.contains(WidgetState.selected)
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.55),
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 96,
                  backgroundColor: Colors.transparent,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded),
                      label: 'Claims',
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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

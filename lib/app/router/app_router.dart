import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/router/route_guard.dart';
import 'package:smart_crops/app/router/onboarding_controller.dart';
import 'package:smart_crops/features/home/screens/home_screen.dart';
import 'package:smart_crops/features/crops/screens/crops_screen.dart';
import 'package:smart_crops/features/crops/screens/crop_detail_screen.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';
import 'package:smart_crops/features/calendar/screens/field_calendar_screen.dart';
import 'package:smart_crops/features/profile/screens/profile_screen.dart';
import 'package:smart_crops/features/profile/screens/profile_setup_screen.dart';
import 'package:smart_crops/features/onboarding/screens/onboarding_screen.dart';
import 'package:smart_crops/features/advisories/screens/advisories_screen.dart';
import 'package:smart_crops/features/care_plan/screens/care_plan_screen.dart';
import 'package:smart_crops/features/health_log/screens/health_log_screen.dart';
import 'package:smart_crops/features/auth/screens/auth_screen.dart';

GoRouter buildAppRouter({
  String initialLocation = '/home',
  bool isOnboardingComplete = true,
  bool isProfileComplete = true,
  bool enforceGuard = true,
  OnboardingController? onboarding,
  bool Function()? isAuthenticated,
}) {
  final controller = onboarding ??
      OnboardingController(
        onboardingComplete: isOnboardingComplete,
        profileComplete: isProfileComplete,
      );

  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: controller,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/setup/profile',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/advisories',
        builder: (context, state) => const AdvisoriesScreen(),
      ),
      GoRoute(
        path: '/care-plan',
        builder: (context, state) => const CarePlanScreen(),
      ),
      GoRoute(
        path: '/health-log',
        builder: (context, state) => const HealthLogScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/crops',
                builder: (context, state) => const CropsScreen(),
                routes: [
                  GoRoute(
                    path: ':cropId',
                    builder: (context, state) {
                      final cropId = state.pathParameters['cropId']!;
                      final crops =
                          context.read<SmartCropsService>().userSelectedCrops;
                      for (final crop in crops) {
                        if (crop.id == cropId) {
                          return CropDetailScreen(crop: crop);
                        }
                      }
                      return const CropsScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scan',
                builder: (context, state) => const ScanCaptureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const FieldCalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (!enforceGuard) return null;

      final authenticated =
          isAuthenticated != null ? isAuthenticated() : _currentSession() != null;
      final decision = resolveRoute(
        RouteContext(
          isAuthenticated: authenticated,
          onboardingComplete: controller.onboardingComplete,
          profileComplete: controller.profileComplete,
          requestedLocation: state.uri.path,
          requestedAccess: _accessFor(state.uri.path),
        ),
      );

      if (decision.location == state.uri.path) {
        return null;
      }
      return decision.location;
    },
  );
}

Session? _currentSession() {
  try {
    return Supabase.instance.client.auth.currentSession;
  } catch (_) {
    return null;
  }
}

RouteAccess _accessFor(String path) {
  if (path.startsWith('/cooperative/members') ||
      path.startsWith('/cooperative/broadcast')) {
    return RouteAccess.cooperativeStaff;
  }
  if (path.startsWith('/cooperative')) {
    return RouteAccess.cooperativeMember;
  }
  if (path == '/onboarding' || path.startsWith('/auth')) {
    return RouteAccess.public;
  }
  return RouteAccess.authenticated;
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _ResponsiveBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ScanCaptureScreen(),
            ));
          } else {
            navigationShell.goBranch(index);
          }
        },
      ),
    );
  }
}

class _ResponsiveBottomNavigation extends StatelessWidget {
  const _ResponsiveBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            extended: constraints.maxWidth >= 1024,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grass_outlined),
                selectedIcon: Icon(Icons.grass),
                label: Text('Crops'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: Text('Scan'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Calendar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          );
        }

        return NavigationBar(
          key: const Key('bottom_nav_bar'),
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grass_outlined),
              selectedIcon: Icon(Icons.grass),
              label: 'Crops',
              tooltip: 'My Crops',
            ),
            NavigationDestination(
              key: Key('nav_scan'),
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon: Icon(Icons.camera_alt),
              label: 'Scan',
              tooltip: 'Scan Crop',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
              tooltip: 'Field Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
              tooltip: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
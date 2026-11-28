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
import 'package:smart_crops/features/scan/domain/diagnosis_presenter.dart';
import 'package:smart_crops/features/scan/screens/scan_capture_screen.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_bottom_bar.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/features/scan/screens/scan_result_screen.dart';
import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';
import 'package:smart_crops/features/calendar/screens/field_calendar_screen.dart';
import 'package:smart_crops/features/calendar/screens/task_detail_screen.dart';
import 'package:smart_crops/features/profile/screens/profile_screen.dart';
import 'package:smart_crops/features/profile/screens/profile_setup_screen.dart';
import 'package:smart_crops/features/profile/screens/manage_crops_screen.dart';
import 'package:smart_crops/features/onboarding/screens/onboarding_screen.dart';
import 'package:smart_crops/features/advisories/screens/advisories_screen.dart';
import 'package:smart_crops/features/care_plan/screens/care_plan_screen.dart';
import 'package:smart_crops/features/health_log/screens/health_log_screen.dart';
import 'package:smart_crops/features/auth/screens/auth_screen.dart';
import 'package:smart_crops/features/pro/screens/agri_pro_manage_screen.dart';
import 'package:smart_crops/features/pro/screens/agri_pro_paywall_screen.dart';
import 'package:smart_crops/features/shop/screens/shop_screen.dart';
import 'package:smart_crops/features/shop/screens/product_detail_screen.dart';
import 'package:smart_crops/features/shop/domain/merchant_product.dart';

GoRouter buildAppRouter({
  String initialLocation = '/home',
  bool isOnboardingComplete = true,
  bool isProfileComplete = true,
  bool enforceGuard = true,
  OnboardingController? onboarding,
  bool Function()? isAuthenticated,
  List<NavigatorObserver>? observers,
}) {
  final controller = onboarding ??
      OnboardingController(
        onboardingComplete: isOnboardingComplete,
        profileComplete: isProfileComplete,
      );

  GoRouter? routerRef;
  final router = GoRouter(
    initialLocation: initialLocation,
    refreshListenable: controller,
    observers: observers,
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
        path: '/manage-crops',
        builder: (context, state) => const ManageCropsScreen(),
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
        path: '/pro',
        builder: (context, state) =>
            AgriProPaywallScreen(fromQuota: state.extra == 'quota'),
      ),
      GoRoute(
        path: '/pro/manage',
        builder: (context, state) => const AgriProManageScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => ShopScreen(
          initialQuery: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: '/shop/products/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final extra = state.extra;
          return ProductDetailScreen(
            productId: productId,
            product: extra as MerchantProduct?,
          );
        },
      ),
      GoRoute(
        path: '/health-log',
        builder: (context, state) => const HealthLogScreen(),
      ),
      // Review and result sit above the shell as full-screen steps. Their
      // photo and diagnosis only exist in memory, so a reload starts over.
      GoRoute(
        path: '/scan/review',
        redirect: (context, state) =>
            state.extra is ScanReviewRequest ? null : '/scan',
        builder: (context, state) {
          final request = state.extra! as ScanReviewRequest;
          return ScanReviewScreen(
            imageFile: request.image,
            cropName: request.cropName,
          );
        },
      ),
      GoRoute(
        path: '/scan/result',
        redirect: (context, state) =>
            state.extra is DiagnosisInput ? null : '/scan',
        builder: (context, state) =>
            ScanResultScreen(input: state.extra! as DiagnosisInput),
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
                routes: [
                  GoRoute(
                    path: 'events/:eventId',
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      final events = context.read<SmartCropsService>().calendarEvents;
                      for (final event in events) {
                        if (event.id == eventId) {
                          return TaskDetailScreen(event: event);
                        }
                      }
                      return const FieldCalendarScreen();
                    },
                  ),
                ],
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
        // The guard passes this location through. Only do that when the
        // route tree actually serves it: a reload at a stale or unknown URL
        // would otherwise land on go_router's default "Page Not Found"
        // error screen, so send those to the hub instead.
        return _canServe(routerRef, state.uri) ? null : _fallbackLocation;
      }
      return decision.location;
    },
  );
  routerRef = router;
  return router;
}

/// Where the guard sends users whose requested URL has no matching route:
/// the app's Cooperative Hub, the same surface cooperative destinations
/// point to (see advisory_link_resolver).
const _fallbackLocation = '/profile';

bool _canServe(GoRouter? router, Uri uri) =>
    router != null && !router.configuration.findMatch(uri).isError;

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
      // Same colour as the screens, so nothing shows behind the floating bar.
      backgroundColor: AppColors.paper,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: navigationShell,
        ),
      ),
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
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            extended: constraints.maxWidth >= 1024,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(l10n.navHome),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.grass_outlined),
                selectedIcon: const Icon(Icons.grass),
                label: Text(l10n.navCrops),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.camera_alt_outlined),
                selectedIcon: const Icon(Icons.camera_alt),
                label: Text(l10n.navScan),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: Text(l10n.navCalendar),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: Text(l10n.navProfile),
              ),
            ],
          );
        }

        return AppBottomBar(
          currentIndex: currentIndex,
          onSelected: onDestinationSelected,
        );
      },
    );
  }
}
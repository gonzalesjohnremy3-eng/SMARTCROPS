import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crops/app/router/route_guard.dart';

void main() {
  test('signed-out first run goes to onboarding and keeps the deep link', () {
    const context = RouteContext(
      isAuthenticated: false,
      onboardingComplete: false,
      profileComplete: false,
      requestedLocation: '/scan/result/42',
      requestedAccess: RouteAccess.authenticated,
    );

    final action = resolveRoute(context);

    expect(action.location, '/onboarding');
    expect(action.pendingLocation, '/scan/result/42');
    expect(action.reason, RouteReason.needsOnboarding);
  });

  test('signed-out user can open public routes without being bounced to onboarding', () {
    const context = RouteContext(
      isAuthenticated: false,
      onboardingComplete: false,
      profileComplete: false,
      requestedLocation: '/auth',
      requestedAccess: RouteAccess.public,
    );

    final action = resolveRoute(context);

    expect(action.location, '/auth');
    expect(action.reason, RouteReason.requested);
  });

  test('signed-out returning farmer goes to auth and keeps the deep link', () {
    const context = RouteContext(
      isAuthenticated: false,
      onboardingComplete: true,
      profileComplete: false,
      requestedLocation: '/calendar/events/7',
      requestedAccess: RouteAccess.authenticated,
    );

    final action = resolveRoute(context);

    expect(action.location, '/auth');
    expect(action.pendingLocation, '/calendar/events/7');
    expect(action.reason, RouteReason.needsAuthentication);
  });

  test('signed-in farmer without a profile goes to profile setup', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: false,
      requestedLocation: '/crops/crop-1',
      requestedAccess: RouteAccess.authenticated,
    );

    final action = resolveRoute(context);

    expect(action.location, '/setup/profile');
    expect(action.pendingLocation, '/crops/crop-1');
    expect(action.reason, RouteReason.needsProfileSetup);
  });

  test('signed-in farmer with a profile opens the requested destination', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: true,
      requestedLocation: '/scan/result/42',
      requestedAccess: RouteAccess.authenticated,
    );

    final action = resolveRoute(context);

    expect(action.location, '/scan/result/42');
    expect(action.pendingLocation, isNull);
    expect(action.reason, RouteReason.requested);
  });

  test('signed-in farmer with a profile and no deep link lands on home', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: true,
    );

    final action = resolveRoute(context);

    expect(action.location, '/home');
    expect(action.pendingLocation, isNull);
    expect(action.reason, RouteReason.home);
  });

  test('a farmer cannot open a cooperative staff route', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: true,
      requestedLocation: '/cooperative/members',
      requestedAccess: RouteAccess.cooperativeStaff,
      role: AppRole.farmer,
    );

    final action = resolveRoute(context);

    expect(action.location, '/home');
    expect(action.pendingLocation, isNull);
    expect(action.reason, RouteReason.roleDenied);
  });

  test('an extension officer can open a cooperative staff route', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: true,
      requestedLocation: '/cooperative/broadcast/new',
      requestedAccess: RouteAccess.cooperativeStaff,
      role: AppRole.extensionOfficer,
    );

    final action = resolveRoute(context);

    expect(action.location, '/cooperative/broadcast/new');
    expect(action.reason, RouteReason.requested);
  });

  test('a cooperative member can open a member route', () {
    const context = RouteContext(
      isAuthenticated: true,
      onboardingComplete: true,
      profileComplete: true,
      requestedLocation: '/cooperative',
      requestedAccess: RouteAccess.cooperativeMember,
      role: AppRole.cooperativeMember,
    );

    final action = resolveRoute(context);

    expect(action.location, '/cooperative');
    expect(action.reason, RouteReason.requested);
  });
}

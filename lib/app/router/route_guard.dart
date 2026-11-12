enum RouteAccess {
  public,
  authenticated,
  cooperativeMember,
  cooperativeStaff,
}

enum RouteReason {
  needsOnboarding,
  needsAuthentication,
  needsProfileSetup,
  requested,
  home,
  roleDenied,
}

enum AppRole {
  farmer,
  cooperativeMember,
  extensionOfficer,
  cooperativeAdministrator,
}

class RouteContext {
  const RouteContext({
    required this.isAuthenticated,
    required this.onboardingComplete,
    required this.profileComplete,
    this.requestedLocation,
    this.requestedAccess = RouteAccess.authenticated,
    this.role = AppRole.farmer,
  });

  final bool isAuthenticated;
  final bool onboardingComplete;
  final bool profileComplete;
  final String? requestedLocation;
  final RouteAccess requestedAccess;
  final AppRole role;
}

class RouteAction {
  const RouteAction({
    required this.location,
    this.pendingLocation,
    required this.reason,
  });

  final String location;
  final String? pendingLocation;
  final RouteReason reason;
}

RouteAction resolveRoute(RouteContext context) {
  if (!context.isAuthenticated) {
    return RouteAction(
      location: context.onboardingComplete ? '/auth' : '/onboarding',
      pendingLocation: context.requestedLocation,
      reason: context.onboardingComplete
          ? RouteReason.needsAuthentication
          : RouteReason.needsOnboarding,
    );
  }

  if (!context.profileComplete) {
    return RouteAction(
      location: '/setup/profile',
      pendingLocation: context.requestedLocation,
      reason: RouteReason.needsProfileSetup,
    );
  }

  if (!_canAccess(context.requestedAccess, context.role)) {
    return const RouteAction(
      location: '/home',
      reason: RouteReason.roleDenied,
    );
  }

  if (context.requestedLocation != null) {
    return RouteAction(
      location: context.requestedLocation!,
      reason: RouteReason.requested,
    );
  }

  return const RouteAction(location: '/home', reason: RouteReason.home);
}

bool _canAccess(RouteAccess access, AppRole role) {
  return switch (access) {
    RouteAccess.public || RouteAccess.authenticated => true,
    RouteAccess.cooperativeMember => role != AppRole.farmer,
    RouteAccess.cooperativeStaff =>
      role == AppRole.extensionOfficer ||
          role == AppRole.cooperativeAdministrator,
  };
}

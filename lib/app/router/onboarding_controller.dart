import 'package:flutter/foundation.dart';

/// In-memory onboarding/profile completion state shared by the router and the
/// setup screens. Values are seeded from SharedPreferences at startup; screens
/// call [completeOnboarding]/[completeProfile] after persisting, so the router
/// re-evaluates its guards with the fresh state instead of the values captured
/// when it was built.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    bool onboardingComplete = false,
    bool profileComplete = false,
  })  : _onboardingComplete = onboardingComplete,
        _profileComplete = profileComplete;

  bool _onboardingComplete;
  bool _profileComplete;

  bool get onboardingComplete => _onboardingComplete;
  bool get profileComplete => _profileComplete;

  void completeOnboarding() {
    if (_onboardingComplete) return;
    _onboardingComplete = true;
    notifyListeners();
  }

  void completeProfile() {
    if (_profileComplete) return;
    _profileComplete = true;
    notifyListeners();
  }
}

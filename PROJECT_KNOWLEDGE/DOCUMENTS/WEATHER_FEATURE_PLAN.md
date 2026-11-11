# Smart Crops - Weather & Location Feature Architecture & Implementation Plan

## 1. Overview
The **Weather and Location Feature** provides farmers with real-time meteorological data directly on the Smart Crops Dashboard (Page 6). By fetching live weather conditions based on the user's registered farm location stored in Supabase, farmers can make informed daily decisions regarding crop care, irrigation, pest management, and harvesting.

---

## 2. Technical Stack & Data Flow
- **Data Provider:** Lightweight public weather API (e.g., OpenWeatherMap Free Tier or `wttr.in` JSON endpoint).
- **Location Context:** User profile location (`profiles.location` table in Supabase) with fallback options for manual entry or default regional coordinates (e.g., agricultural regions).
- **Client Handling:** Flutter HTTP client (`http` package) integrated into a dedicated `WeatherService`.
- **State & UI:** Reactive UI widget on the dashboard utilizing `FutureBuilder` or state management providers with pull-to-refresh capabilities.

---

## 3. Data Models (`WeatherCondition`)
```dart
class WeatherCondition {
  final String locationName;
  final double temperature; // Celsius
  final String condition;   // e.g., "Sunny", "Light Rain", "Humid"
  final int humidity;       // Percentage
  final String iconCode;    // Weather icon identifier

  WeatherCondition({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.iconCode,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    // Parsing logic for weather API response
  }
}
```

---

## 4. Implementation Steps
1. **Model Definition:** Implement `WeatherCondition` in `lib/models/app_models.dart`.
2. **Weather Service (`lib/services/weather_service.dart`):**
   - Implement `fetchWeather(String location)` method.
   - Add error handling, timeout protection, and graceful offline fallbacks.
3. **Dashboard Widget (`lib/screens/dashboard_screen.dart`):**
   - Replace placeholder weather widget with dynamic `WeatherCard` component.
   - Support loading skeletons, error states, and pull-to-refresh actions.
4. **Testing & Validation:**
   - Write unit tests in `test/weather_service_test.dart` to validate API parsing and error handling.
   - Run Flutter build & analysis (`flutter analyze`, `flutter test`).

---

## 5. Future Enhancements
- 7-day extended agricultural forecast.
- Automated weather-based pest outbreak warnings linked to the recommendations engine.
- Offline caching using local storage (Hive/Isar) for intermittent rural internet connectivity.

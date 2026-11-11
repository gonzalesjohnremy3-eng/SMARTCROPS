import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/smart_crops_service.dart';
import '../services/weather_service.dart';
import 'auth_screen.dart';
import 'scan_crop_screen.dart';
import 'my_crops_screen.dart';
import 'recommendations_screen.dart';
import 'history_screen.dart';
import 'personalized_crop_calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cropsService = Provider.of<SmartCropsService>(context, listen: false);
      cropsService.initializeUserData().then((_) {
        final location = cropsService.currentUserProfile?.location ?? 'Philippines';
        Provider.of<WeatherService>(context, listen: false).fetchWeatherForLocation(location);
      });
    });
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer<SmartCropsService>(
          builder: (context, service, child) {
            final notifs = service.notifications;
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Scan Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: notifs.isEmpty
                        ? const Center(child: Text('No notifications yet. Scan a crop to begin!'))
                        : ListView.builder(
                            itemCount: notifs.length,
                            itemBuilder: (context, index) {
                              final n = notifs[index];
                              return Card(
                                color: n.isRead ? Colors.white : const Color(0xFFE8F5E9),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.notifications_active, color: Color(0xFF2E7D32)),
                                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(n.message),
                                  trailing: n.isRead ? null : const Icon(Icons.fiber_manual_record, color: Colors.green, size: 12),
                                  onTap: () {
                                    service.markNotificationAsRead(n.id);
                                    Navigator.pop(context);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Smart Crops (Agri Lynk)'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          Consumer<SmartCropsService>(
            builder: (context, service, child) {
              final unreadCount = service.unreadNotificationCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => _showNotificationsModal(context),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<SmartCropsService>(context, listen: false).signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final profile = service.currentUserProfile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Banner
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: primaryGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${profile?.fullName ?? 'Farmer'}!',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.agriculture, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Farm: ${profile?.farmName ?? 'My Farm'} (${profile?.location ?? 'Region'})',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Weather Widget
                Consumer<WeatherService>(
                  builder: (context, weatherService, child) {
                    final weather = weatherService.currentWeather;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Local Farm Weather', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryGreen)),
                                      IconButton(
                                        icon: const Icon(Icons.refresh, size: 18, color: primaryGreen),
                                        onPressed: () {
                                          final profile = Provider.of<SmartCropsService>(context, listen: false).currentUserProfile;
                                          Provider.of<WeatherService>(context, listen: false).fetchWeatherForLocation(profile?.location ?? 'Philippines');
                                        },
                                        tooltip: 'Refresh Weather',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(weather?.locationName ?? profile?.location ?? 'Philippines', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  weatherService.isLoading
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                      : Text(
                                          '${weather?.temperature.toStringAsFixed(1) ?? '28.0'}°C • ${weather?.condition ?? 'Sunny'} (Humidity: ${weather?.humidity ?? 70}%)',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                  if (weatherService.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(weatherService.errorMessage!, style: const TextStyle(fontSize: 10, color: Colors.orange)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.wb_sunny, size: 48, color: Colors.amber),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Core Modules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
                const SizedBox(height: 12),
                // Core Grid Buttons
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _DashboardCard(
                      title: 'Scan Crop',
                      subtitle: 'AI Pest & Disease Detection',
                      icon: Icons.camera_alt,
                      color: const Color(0xFF1B5E20),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCropScreen())),
                    ),
                    _DashboardCard(
                      title: 'My Crops',
                      subtitle: 'Growth Stages & Guides',
                      icon: Icons.eco,
                      color: const Color(0xFF388E3C),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCropsScreen())),
                    ),
                    _DashboardCard(
                      title: 'Recommendations',
                      subtitle: 'Tailored Care Tips',
                      icon: Icons.lightbulb,
                      color: const Color(0xFF43A047),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendationsScreen())),
                    ),
                    _DashboardCard(
                      title: 'History',
                      subtitle: 'Past Scan Log & Reviews',
                      icon: Icons.history,
                      color: const Color(0xFF2E7D32),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                    ),
                    _DashboardCard(
                      title: 'Crop Calendar',
                      subtitle: 'Personalized Smart Schedule',
                      icon: Icons.calendar_month,
                      color: const Color(0xFF00897B),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalizedCropCalendarScreen())),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

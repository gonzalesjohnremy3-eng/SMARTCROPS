
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';
import 'package:smart_crops/features/scan/screens/scan_review_screen.dart';

class ScanCaptureScreen extends StatefulWidget {
  const ScanCaptureScreen({super.key});

  @override
  State<ScanCaptureScreen> createState() => _ScanCaptureScreenState();
}

class _ScanCaptureScreenState extends State<ScanCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedCropName;

  Future<void> _capture(String cropName, ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorPermission)),
        );
        return;
      }
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanReviewScreen(
          localImagePath: picked.path,
          cropName: cropName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final service = context.watch<SmartCropsService>();
    final crops = service.userSelectedCrops;
    final cropName = _selectedCropName ??
        (crops.isNotEmpty ? crops.first.cropName : 'Pechay');

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textInverse,
        title: Text(l10n.scanCaptureTitle),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(AppRadius.sheet),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.eco_outlined,
                        size: 96,
                        color: AppColors.textInverse.withValues(alpha: 0.35),
                      ),
                    ),
                    ..._reticleBrackets(),
                    const Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_outlined,
                          color: AppColors.textInverse.withValues(alpha: 0.8)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.scanCaptureGuidance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textInverse.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (crops.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: cropName,
                      dropdownColor: AppColors.surfaceSunken,
                      style: const TextStyle(color: AppColors.textInverse),
                      decoration: InputDecoration(
                        labelText: l10n.searchCrops,
                        labelStyle: TextStyle(
                          color: AppColors.textInverse.withValues(alpha: 0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.button),
                        ),
                      ),
                      items: crops
                          .map((crop) => DropdownMenuItem(
                                value: crop.cropName,
                                child: Text(crop.cropName),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCropName = value),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('capture_button'),
                    onPressed: () => _capture(cropName, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.scanCrop),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _capture(cropName, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.scanCrop),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _reticleBrackets() {
    const length = 48.0;
    const stroke = 4.0;
    return [
      const Positioned(
        top: 24,
        left: 24,
        child: _Bracket(top: true, left: true, length: length, stroke: stroke),
      ),
      const Positioned(
        top: 24,
        right: 24,
        child:
            _Bracket(top: true, left: false, length: length, stroke: stroke),
      ),
      const Positioned(
        bottom: 24,
        left: 24,
        child:
            _Bracket(top: false, left: true, length: length, stroke: stroke),
      ),
      const Positioned(
        bottom: 24,
        right: 24,
        child:
            _Bracket(top: false, left: false, length: length, stroke: stroke),
      ),
    ];
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket({
    required this.top,
    required this.left,
    required this.length,
    required this.stroke,
  });

  final bool top;
  final bool left;
  final double length;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(length, length),
      painter: _BracketPainter(
        top: top,
        left: left,
        stroke: stroke,
        color: AppColors.leaf,
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({
    required this.top,
    required this.left,
    required this.stroke,
    required this.color,
  });

  final bool top;
  final bool left;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final horizontal = top ? 0.0 : size.height;
    final vertical = left ? 0.0 : size.width;
    final startX = left ? 0.0 : size.width;
    final endX = left ? size.width : 0.0;

    canvas.drawLine(Offset(startX, horizontal), Offset(endX, horizontal), paint);
    canvas.drawLine(Offset(vertical, horizontal), Offset(vertical, top ? size.height : 0), paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) => false;
}

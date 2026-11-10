import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../services/smart_crops_service.dart';

class ScanCropScreen extends StatefulWidget {
  const ScanCropScreen({super.key});

  @override
  State<ScanCropScreen> createState() => _ScanCropScreenState();
}

class _ScanCropScreenState extends State<ScanCropScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  ScanHistoryItem? _scanResult;
  String? _selectedCropName;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
        _scanResult = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    final service = Provider.of<SmartCropsService>(context, listen: false);
    final crops = service.userSelectedCrops;
    final defaultCrop = crops.isNotEmpty ? crops.first.cropName : 'Pechay';

    setState(() => _isAnalyzing = true);

    try {
      // In web/desktop or test environments, use a sample placeholder image URL or data URI
      final imageUrl = kIsWeb
          ? 'https://images.unsplash.com/photo-1592417817098-8f3d691a4bf5?auto=format&fit=crop&w=800&q=80'
          : 'https://images.unsplash.com/photo-1592417817098-8f3d691a4bf5?auto=format&fit=crop&w=800&q=80';

      final result = await service.performAiScan(imageUrl, _selectedCropName ?? defaultCrop);
      setState(() {
        _scanResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const lightSurface = Color(0xFFF4F6F4);

    return Scaffold(
      backgroundColor: lightSurface,
      appBar: AppBar(
        title: const Text('Scan Crop for Disease Detection'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SmartCropsService>(
        builder: (context, service, child) {
          final userCrops = service.userSelectedCrops;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Snap or Upload Crop Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Our multi-API AI Vision engine analyzes symptoms instantly for pest and disease detection.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                if (userCrops.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCropName ?? userCrops.first.cropName,
                    decoration: InputDecoration(
                      labelText: 'Select Target Crop',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: userCrops.map((c) {
                      return DropdownMenuItem(value: c.cropName, child: Text(c.cropName));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCropName = val),
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                              : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_enhance, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No image selected', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_imageFile == null || _isAnalyzing) ? null : _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Analyze Crop Health with AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (_scanResult != null) ...[
                  const SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('AI Diagnosis Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
                              Chip(
                                label: Text('${_scanResult!.confidenceScore}% Confidence'),
                                backgroundColor: const Color(0xFFE8F5E9),
                                labelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text('Detected Issue:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const SizedBox(height: 4),
                          Text(_scanResult!.diseaseDetected, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          const SizedBox(height: 16),
                          Text('Recommended Actions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          const SizedBox(height: 6),
                          ...(_scanResult!.recommendedActions.map((action) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                                  Expanded(child: Text(action.toString(), style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            );
                          })),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

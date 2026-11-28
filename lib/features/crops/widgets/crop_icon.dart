import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

// Look-alike crops share a drawing. A crop with no entry here shows the leaf,
// so a crop added to the catalogue never breaks; draw it and add a line.
const _iconKeyByCrop = {
  'banana': 'banana',
  'coconut': 'coconut',
  'cacao': 'cacao',
  'coffee': 'coffee',
  'durian': 'durian',
  'pomelo': 'citrus',
  'calamansi': 'citrus',
  'pineapple': 'pineapple',
  'corn': 'corn',
  'rice': 'rice',
  'pechay': 'leaf',
  'mustard': 'leaf',
  'kangkong': 'leaf',
  'cabbage': 'leaf',
  'lettuce': 'leaf',
  'moringa': 'leaf',
  'carrot': 'root',
  'radish': 'root',
  'cassava': 'root',
  'camote': 'root',
  'gabi': 'root',
  'ube': 'root',
  'ginger': 'root',
  'ampalaya': 'gourd',
  'upo': 'gourd',
  'patola': 'gourd',
  'cucumber': 'gourd',
  'squash': 'gourd',
  'sitaw': 'gourd',
  'tomato': 'tomato',
  'eggplant': 'tomato',
  'chili pepper': 'tomato',
  'bell pepper': 'tomato',
  'onion': 'bulb',
  'garlic': 'bulb',
};

/// The drawings shipped in `assets/icons/crops/`.
final cropIconKeys = _iconKeyByCrop.values.toSet();

/// The drawing for [cropName], or null when that crop has none yet.
String? cropIconKey(String cropName) =>
    _iconKeyByCrop[cropName.trim().toLowerCase()];

/// A crop's own icon, tinted like any Material icon.
class CropIcon extends StatelessWidget {
  const CropIcon({
    super.key,
    required this.name,
    this.size = AppSpacing.s6,
    this.color = AppColors.canopy,
  });

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final key = cropIconKey(name);
    if (key == null) {
      return Icon(Icons.eco_outlined, size: size, color: color);
    }

    return SvgPicture.asset(
      'assets/icons/crops/$key.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // Decorative: the crop's name always sits beside it.
      excludeFromSemantics: true,
    );
  }
}

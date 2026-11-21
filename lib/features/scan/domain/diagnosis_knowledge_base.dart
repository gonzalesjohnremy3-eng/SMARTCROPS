class DiagnosisDetails {
  const DiagnosisDetails({
    required this.cause,
    required this.symptoms,
    required this.immediateActions,
    required this.prevention,
    required this.expertNote,
    this.isHealthy = false,
  });

  final String cause;
  final List<String> symptoms;
  final List<String> immediateActions;
  final List<String> prevention;
  final String expertNote;
  final bool isHealthy;
}

class _KnowledgeEntry {
  const _KnowledgeEntry({
    required this.label,
    required this.keywords,
    required this.crops,
    required this.details,
  });

  final String label;
  final List<String> keywords;
  final List<String> crops;
  final DiagnosisDetails details;
}

const _genericDetails = DiagnosisDetails(
  cause:
      'Usually a plant pathogen or environmental stress (humidity, injury, or poor drainage). The exact cause should be confirmed with your local agricultural technologist.',
  symptoms: [
    'Leaf, stem, or fruit changes that differ from a healthy sample',
    'Discoloration, spots, wilting, or rotting on affected parts',
    'Symptoms that spread to nearby plants when unaddressed',
  ],
  immediateActions: [
    'Isolate or mark the most affected plants',
    'Remove and dispose of diseased leaves far from the field',
    'Avoid overhead watering; water at the base in the morning',
    'Ask your barangay agricultural office about registered fungicides for this crop',
  ],
  prevention: [
    'Use clean seed or seedlings and crop-rotate annually',
    'Keep the field free of weeds and crop debris',
    'Space plants to allow airflow and avoid wetting foliage',
  ],
  expertNote:
      'If more than 20% of the field shows symptoms, or spread is fast, consult your municipal agricultural technologist before applying chemicals.',
);

const _healthyDetails = DiagnosisDetails(
  cause: 'No pathogen detected in the sample.',
  symptoms: ['Uniform green foliage with no lesions', 'Normal growth and vigor'],
  immediateActions: [
    'Keep the current watering, spacing, and fertilization schedule',
    'Scout twice a week anyway; early detection is the cheapest control',
  ],
  prevention: [
    'Rotate with non-host crops when possible',
    'Maintain soil organic matter and balanced nutrition',
    'Clean tools between fields to avoid carrying spores',
  ],
  expertNote:
      'Healthy now does not mean sealed: pests move in quickly. Keep monitoring and log any change you notice.',
  isHealthy: true,
);

const _entries = <_KnowledgeEntry>[
  _KnowledgeEntry(
    label: 'Rice Blast',
    keywords: ['blast'],
    crops: ['rice', 'palay'],
    details: DiagnosisDetails(
      cause:
          'Magnaporthe oryzae (rice blast fungus). Favored by high humidity, prolonged leaf wetness, and excess nitrogen.',
      symptoms: [
        'Diamond-shaped lesions on leaves, often with grey centres',
        'Lesions on collar, neck, or panicles (neck blast)',
        'Bleached, empty panicles in severe neck blast',
      ],
      immediateActions: [
        'Stop nitrogen top-dressing until the crop recovers',
        'Remove heavily diseased tillers when feasible',
        'Keep standing water shallow to reduce splash spread',
        'Apply a registered tricyclazole fungicide per label if lesions spread',
      ],
      prevention: [
        'Plant blast-resistant varieties suited to your area',
        'Seed treatment before planting',
        'Avoid dense stand and split nitrogen applications',
      ],
      expertNote:
          'Neck blast at flowering can wipe out yield fast, seek your municipal agriculturist immediately if panicles are affected.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Rice Brown Spot',
    keywords: ['brown spot'],
    crops: ['rice', 'palay'],
    details: DiagnosisDetails(
      cause:
          'Bipolaris oryzae (brown spot fungus), often a sign of weak or hungry plants and poor soil nitrogen.',
      symptoms: [
        'Round to oval brown spots with a yellow halo',
        'Spots on leaf sheaths and glumes, grain discoloration',
        'Stunted tillers when plants are under stress',
      ],
      immediateActions: [
        'Correct nitrogen and potassium deficiency per your soil test',
        'Drain and re-flood to change the microclimate',
        'Use clean, certified seed for the next crop',
      ],
      prevention: [
        'Balanced NPK plus adequate silicon and organic matter',
        'Burn or bury infected crop residue after harvest',
        'Avoid water stress during tillering and heading',
      ],
      expertNote:
          'Persistent brown spot usually means soil fertility problems, review your fertilization plan with your local soil clinic.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Bacterial Leaf Blight',
    keywords: ['bacterial leaf blight', 'bacterial blight', 'xylem'],
    crops: ['rice', 'palay'],
    details: DiagnosisDetails(
      cause:
          'Xanthomonas oryzae pv. oryzae. Spread by wind, rain splash, and flood water; enters through leaf edges and wounds.',
      symptoms: [
        'Water-soaked to yellow-white streaks from leaf tips and edges',
        'Wavy lesions with wavy margins that dry to straw color',
        'Kresek (sudden wilt of young plants) in severe cases',
      ],
      immediateActions: [
        'Drain standing water and avoid field-to-field water flow',
        'Remove infected leaves with clean tools',
        'Pause nitrogen top-dressing until spread stops',
        'Ask your technologist about a registered copper bactericide',
      ],
      prevention: [
        'Plant resistant varieties and clean, certified seed',
        'Moderate nitrogen in split doses',
        'Avoid crowded stands and weed hosts around the field',
      ],
      expertNote:
          'Bacterial diseases do not respond to fungicides; ask your agricultural technologist before spraying anything.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Rice Tungro',
    keywords: ['tungro'],
    crops: ['rice', 'palay'],
    details: DiagnosisDetails(
      cause:
          'Rice tungro virus, transmitted by leafhoppers (Nephotettix species).',
      symptoms: [
        'Yellow to orange discoloration of leaves (beginning at leaf tip)',
        'Stunted, fewer tillers, and poor panicle emergence',
        'Mottling and rust-colored flecks on older leaves',
      ],
      immediateActions: [
        'Rogue out and destroy stunted, orange-colored hills',
        'Monitor and manage leafhopper populations',
        'Do not transplant seedlings from symptomatic areas',
      ],
      prevention: [
        'Use tungro-resistant varieties',
        'Synchronous planting within a village to break leafhopper cycles',
        'Balanced fertilization to reduce leafhopper attractiveness',
      ],
      expertNote:
          'There is no cure for tungro: management is vector control and roguing. Coordinate with your local agriculture office on synchronous planting.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Northern Corn Leaf Blight',
    keywords: ['northern corn leaf blight', 'turcicum'],
    crops: ['corn', 'maize'],
    details: DiagnosisDetails(
      cause:
          'Exserohilum turcicum (fungus). Favored by leaf wetness above 18°C and dense canopy.',
      symptoms: [
        'Long, cigar-shaped gray-green lesions on leaves',
        'Lesions start on lower leaves and move upward',
        'Severe blighting reduces photosynthesis and ear fill',
      ],
      immediateActions: [
        'Remove dead leaves below ear zone when safe',
        'Harvest early if blight reached critical leaves before black layer',
        'Improve airflow by thinning overly dense rows',
      ],
      prevention: [
        'Plant resistant hybrids',
        'Crop rotation with non-grass crops',
        'Deep burial or removal of crop residue',
      ],
      expertNote:
          'Fungicide decisions depend on hybrid resistance and stage, consult your technologist before spraying.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Common Corn Smut',
    keywords: ['common smut', 'corn smut', 'cuitlacoche'],
    crops: ['corn', 'maize'],
    details: DiagnosisDetails(
      cause:
          'Ustilago maydis (fungus); enters through wounds and young tissue, often after hail or cultivation damage.',
      symptoms: [
        'Whitish to gray galls on ears, tassels, or stems',
        'Galls rupture, releasing black spore masses',
        'Distorted kernels and tassels',
      ],
      immediateActions: [
        'Pick and bag smutted ears before they burst; bury or burn',
        'Avoid cultivation that injures roots during tasseling',
        'Sort out and reject smutted grain at harvest',
      ],
      prevention: [
        'Plant moderately resistant hybrids',
        'Reduce plant stress and excessive nitrogen',
        'Avoid mechanical injury to young plants',
      ],
      expertNote:
          'Covered smut reduces market value. If more than 10% of ears are smutted, get a field assessment.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Tomato Early Blight',
    keywords: ['early blight'],
    crops: ['tomato'],
    details: DiagnosisDetails(
      cause:
          'Alternaria solani (fungus). Favored by alternating wet/dry cycles and older foliage getting wet.',
      symptoms: [
        'Concentric ring spots (target-board pattern) on older leaves',
        'Yellowing around lesions followed by drying',
        'Stem-end rot at the calyx in severe humidity',
      ],
      immediateActions: [
        'Remove infected lower leaves and dispose away from the bed',
        'Stake plants and prune for airflow',
        'Mulch soil; avoid splash from soil to leaves',
        'Water at the base only; early morning preferred',
      ],
      prevention: [
        'Rotate with non-solanaceous crops for 2-3 years',
        'Resistant varieties where available',
        'Balanced calcium and adequate potassium',
        'Seed treatment (hot water) for transplants',
      ],
      expertNote:
          'Target-board spots are diagnostic. Treat preventively with a registered multi-site fungicide when the first leaf shows spots.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Tomato Late Blight',
    keywords: ['late blight'],
    crops: ['tomato', 'potato'],
    details: DiagnosisDetails(
      cause:
          'Phytophthora infestans (water mold). Explosive under cool, wet, humid conditions.',
      symptoms: [
        'Water-soaked, gray-green lesions that turn brown quickly',
        'White fuzzy mold on leaf undersides in humid mornings',
        'Brown, cooked-looking areas on stems; fruit greasy lesions',
      ],
      immediateActions: [
        'Bag and remove symptomatic plants and fruit immediately',
        'Do not compost blighted material',
        'Apply a registered protectant fungicide (chlorothalonil or mancozeb) before it rains',
        'Stop overhead irrigation; water at the base',
      ],
      prevention: [
        'Certified disease-free seedlings',
        'Morning watering, wide spacing, staking',
        'Preventive fungicide sprays before wet periods',
        'Destroy volunteer potatoes and tomato culls',
      ],
      expertNote:
          'Late blight can destroy a crop in days. Report the outbreak to your barangay agricultural office.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Fusarium Wilt',
    keywords: ['fusarium', 'fusarium wilt'],
    crops: ['tomato', 'eggplant', 'banana'],
    details: DiagnosisDetails(
      cause:
          'Fusarium oxysporum (soil-borne fungus). Invades through roots and blocks water vessels.',
      symptoms: [
        'Wilting of one side or one shoot at a time, starting on older leaves',
        'Yellowing from bottom up; leaves wilt at midday and recover at night',
        'Brown streaks in cut stems (vascular browning)',
      ],
      immediateActions: [
        'Remove and bag whole wilted plants; do not compost',
        'Improve drainage; avoid waterlogging',
        'Solarize small beds with clear plastic for 4-6 weeks',
        'Do not replant susceptible crops in that spot this season',
      ],
      prevention: [
        'Resistant varieties and grafted seedlings',
        'Long rotations (3+ years) with non-solanaceous crops',
        'Correct soil pH (6.2-6.8) and organic matter',
        'Clean tools and footwear between blocks',
      ],
      expertNote:
          'Soil is now contaminated: note the exact bed location for future planting plans or ask about soil solarization.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Tomato Yellow Leaf Curl Virus',
    keywords: ['tobacco mosaic', 'cucumber mosaic', 'tomato mosaic', 'mosaic virus', 'yellow leaf curl'],
    crops: ['tomato', 'eggplant', 'pechay'],
    details: DiagnosisDetails(
      cause:
          'Plant virus (TMV/CMV/TYLCV or related). Spread by aphids, whiteflies, tools, and handling.',
      symptoms: [
        'Mottled light/dark green mosaic pattern on young leaves',
        'Leaf distortion, cuplike curling, blistering',
        'Stunted plants and uneven, poor fruit set',
      ],
      immediateActions: [
        'Rogue symptomatic plants immediately (bag, bury)',
        'Control aphid/whitefly vectors: yellow sticky traps, insecticidal soap',
        'Disinfect pruners with 10% bleach between plants',
        'No pesticide cures the virus itself',
      ],
      prevention: [
        'Resistant varieties where available',
        'Net houses or row covers in nurseries',
        'Manage vector weeds weekly',
        'Do not touch plants after smoking or handling tobacco',
      ],
      expertNote:
          'Once systemic mosaic appears the plant is lost, speed of roguing decides whether neighbors are infected.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Bacterial Wilt',
    keywords: ['bacterial wilt'],
    crops: ['eggplant', 'tomato', 'pechay'],
    details: DiagnosisDetails(
      cause:
          'Ralstonia solanacearum (soil bacteria). Enters through roots, often in warm, wet, acidic soils.',
      symptoms: [
        'Sudden wilting of the whole plant while leaves stay green',
        'Wilting of the midday type with recovery overnight (early stage)',
        'Milky white bacterial ooze from cut stem in water test',
      ],
      immediateActions: [
        'Bag and remove wilted plants whole, including roots',
        'Disinfect tools; avoid tilling the bed afterwards',
        'Raised beds and strict drainage',
        'No chemical cure exists',
      ],
      prevention: [
        'Grafting onto resistant rootstocks',
        'Long crop rotations with rice or non-hosts',
        'Lime acidic soil; add organic amendments',
        'Use disease-free transplants',
      ],
      expertNote:
          'Confirmed bacterial wilt means that bed should sit in non-host crop for 2+ seasons, get a formal field diagnosis.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Anthracnose',
    keywords: ['anthracnose'],
    crops: ['eggplant', 'mango', 'pechay'],
    details: DiagnosisDetails(
      cause:
          'Colletotrichum species (fungus). Spread by rain splash and warm humid weather.',
      symptoms: [
        'Small sunken dark spots that expand to circular lesions',
        'Orange spore masses in the center of lesions in wet weather',
        'Fruit rot and flower/leaf blackening',
      ],
      immediateActions: [
        'Remove and bag affected fruit, leaves, and stems',
        'Thin canopy to reduce humidity',
        'Apply a registered copper or chlorothalonil fungicide preventively',
      ],
      prevention: [
        'Resistant varieties; clean seed',
        'Mulching and drip irrigation (avoid wet foliage)',
        'Post-harvest dipping for mangos before storage',
      ],
      expertNote:
          'Anthracnose shows most damage after harvest, dipping protocol matters if you market fruit.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Sooty Mold',
    keywords: ['sooty mold'],
    crops: ['mango'],
    details: DiagnosisDetails(
      cause:
          'Fungi growing on honeydew excreted by scale insects/mealybugs; the mold itself is secondary.',
      symptoms: [
        'Black soot-like coating on leaves and fruit',
        'Sticky honeydew on leaves beneath colonies',
        'Reduced photosynthesis and dull fruit finish',
      ],
      immediateActions: [
        'Wash foliage and fruit with soapy water, then clean water',
        'Control scale insects and mealybugs first (horticultural oil)',
        'Prune to let more light and air reach the canopy',
      ],
      prevention: [
        'Routine inspection for honeydew insects each flowering flush',
        'Ant management, ants farm and protect scales',
        'Balanced fertility; avoid excess vegetative flush',
      ],
      expertNote:
          'Sooty mold disappears once the insects are controlled. Spend effort on the scales, not the black film.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Powdery Mildew',
    keywords: ['powdery mildew'],
    crops: ['mango'],
    details: DiagnosisDetails(
      cause:
          'Oidium/Erysiphe species (fungus). Dry-weather disease favoring dense, shaded canopy.',
      symptoms: [
        'White powdery coating on shoots, flowers, and young leaves',
        'Purplish-brown patches on maturing fruit',
        'Deformed shoots and poor fruit set',
      ],
      immediateActions: [
        'Prune to open the canopy; remove heavily infected shoots',
        'Spray sulfur-based fungicide at panicle emergence per label',
        'Avoid nitrogen flush right before flowering',
      ],
      prevention: [
        'Canopy management each season',
        'Preventive sulfur sprays at early panicle stage',
        'Resistant varieties if available',
      ],
      expertNote:
          'Powdery mildew ruins fruit finish. A single well-timed panicle-stage spray prevents most losses.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Downy Mildew',
    keywords: ['downy mildew'],
    crops: ['pechay', 'cabbage', 'cucurbit'],
    details: DiagnosisDetails(
      cause:
          'Hyaloperonospora/Peronospora species (water mold); favored by cool nights and leaf wetness.',
      symptoms: [
        'Yellow angular spots between veins on older leaves',
        'Grayish-purple fuzz on undersides in humid mornings',
        'Leaves curl and dry; head formation stunted',
      ],
      immediateActions: [
        'Remove infected leaves; destroy them away from the bed',
        'Reduce overhead irrigation; water at the base early',
        'Apply a registered copper fungicide before forecast wet nights',
      ],
      prevention: [
        'Wide spacing and full-sun planting',
        'Resistant varieties where available',
        'Rotate crucifers with non-host crops',
      ],
      expertNote:
          'Downy mildew thrives in the rainy season. Watch undersides after 3 wet nights in a row.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Bacterial Soft Rot',
    keywords: ['Erwinia', 'soft rot', 'wet rot'],
    crops: ['pechay', 'cabbage', 'tomato'],
    details: DiagnosisDetails(
      cause:
          'Pectobacterium/Erwinia carotovora bacteria; enters through wounds, harvest cuts, and insect injury.',
      symptoms: [
        'Watery, foul-smelling decay of leaf petioles and stem bases',
        'Soft, translucent, sunken spots that expand rapidly',
        'Whole plant collapse in warm, humid conditions',
      ],
      immediateActions: [
        'Remove and dispose of rotting plants completely',
        'Stop overhead irrigation; drain the bed',
        'Avoid harvest injury; handle gently',
        'Disinfect tools and crates between uses',
      ],
      prevention: [
        'Avoid wounding petioles; harvest dry in the morning',
        'Fast cooling or prompt market delivery',
        'Balanced calcium; avoid excessive nitrogen',
        'Rotate out of crucifers; raised beds',
      ],
      expertNote:
          'Soft rot in packing sheds spreads fast. Separate clean and suspect lots, and chlorinate crates.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Panama Disease',
    keywords: ['panama', 'fusarium wilt of banana', 'panama disease'],
    crops: ['banana'],
    details: DiagnosisDetails(
      cause:
          'Fusarium oxysporum f. sp. cubense (soil fungus). Infests soil for decades; enters through root injuries.',
      symptoms: [
        'Yellowing of leaf margins on older leaves, moving inward',
        'Collapse of leaf petioles forming a skirt of dead leaves',
        'Vascular browning when the pseudostem is cut',
      ],
      immediateActions: [
        'Bag pups by variety, do not replant from diseased mats',
        'Mark infested mats; do not move soil from them',
        'Burn or bury infected plant residues away from the plantation',
      ],
      prevention: [
        'Plant certified Fusarium-free suckers (tissue culture)',
        'Resistant cultivars (e.g., for Race 1)',
        'Clean tools and footwear; quarantine new plantlets',
        'Non-host rotation is impractical, focus on exclusion',
      ],
      expertNote:
          'Panama disease is untreatable. Contact your local agriculturist and BPI immediately, containment is the only option.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Sigatoka Leaf Streak',
    keywords: ['sigatoka', 'black leaf streak', 'yellow leaf streak'],
    crops: ['banana'],
    details: DiagnosisDetails(
      cause:
          'Mycosphaerella/Pseudocercospora species (fungus). Spread by wind and rain splash; humidity-driven.',
      symptoms: [
        'Yellow-brown streaks parallel to leaf veins, becoming necrotic',
        'Leaf streaks fuse; portions of leaf dry and die',
        'Reduced photosynthesis and poor bunch filling',
      ],
      immediateActions: [
        'Remove and fold infected leaves into the row cover or bury them',
        'Spray a registered protectant fungicide by rotation',
        'Improve drainage; avoid wetting the canopy',
      ],
      prevention: [
        'Resistant varieties; wide spacing for airflow',
        'Regular leaf pruning of up to 3 dead or diseased leaves per quarter',
        'Nutrition program matched to Sigatoka pressure',
      ],
      expertNote:
          'Sigatoka management is a year-round program. Your local agriculturist or cooperative can schedule the rotation.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Banana Bunchy Top',
    keywords: ['bunchy top'],
    crops: ['banana'],
    details: DiagnosisDetails(
      cause:
          'Banana bunchy top virus (BBTV), transmitted by the banana aphid (Pentalonia nigronervosa).',
      symptoms: [
        'New leaves stunted, upright, narrow, and chlorotic-margined',
        'Morse code yellow-green streaks along veins',
        'Dark streaks on the pseudostem; no fruit production',
      ],
      immediateActions: [
        'Bag or burn and bury symptomatic mats completely',
        'Do not use their suckers',
        'Control banana aphids (soap solution on aphid clusters)',
      ],
      prevention: [
        'Certified BBTV-free planting material',
        'Clean tools and footwear between farms',
        'Coordinate village-level roguing programs',
      ],
      expertNote:
          'BBTV has no cure and spreads farm-to-farm. Report clusters to your municipal agriculture office for a containment plan.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Coconut Bud Rot',
    keywords: ['bud rot'],
    crops: ['coconut'],
    details: DiagnosisDetails(
      cause:
          'Phytophthora katsurae (fungus-like water mold); enters through the spear leaf base, often after injury or drought stress.',
      symptoms: [
        'Spear leaf (newest) rots and comes out with a foul smell',
        'Yellowing and drooping of surrounding fronds',
        'Crown collapse when the bud is destroyed',
      ],
      immediateActions: [
        'Pour registered copper fungicide into the crown/bud area weekly until the spear resumes growth',
        'Remove and burn the rotted spear and surrounding debris',
        'Protect the new spear; do not cut healthy leaves unnecessarily',
      ],
      prevention: [
        'Good water management; avoid severe drought stress',
        'Regular scarring-frond care; avoid injuries to the crown',
        'Balanced fertility with emphasis on potassium',
      ],
      expertNote:
          'A destroyed bud means the palm dies. Treat early and aggressively. Get a PCC/PCA officer to confirm before spending.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Coconut Lethal Yellowing',
    keywords: ['lethal yellowing', 'lethal wilt', 'marchitez sorpresiva', 'phytoplasma'],
    crops: ['coconut'],
    details: DiagnosisDetails(
      cause:
          'Phytoplasma transmitted by leafhoppers Myndus crudus. No cure.',
      symptoms: [
        'Premature nut drop while nuts are still small',
        'Yellowing of fronds beginning with the oldest leaves',
        'Blackened immature inflorescences; full crown death in months',
      ],
      immediateActions: [
        'Do not harvest anything from a symptomatic palm until advised',
        'Cut and split dead trunks to discourage leafhopper breeding',
        'Contact PCC immediately, this is a notifiable disease',
      ],
      prevention: [
        'Plant tolerant varieties (e.g., Mawa hybrid) in affected zones',
        'Leafhopper vector management near the farm',
        'Do not move infected plant material',
      ],
      expertNote:
          'Notifiable disease: the Philippine Coconut Authority must be involved. Do not ignore or wait.',
    ),
  ),
  _KnowledgeEntry(
    label: 'Ganoderma Basal Stem Rot',
    keywords: ['ganoderma', 'basal stem rot', 'heart rot'],
    crops: ['coconut'],
    details: DiagnosisDetails(
      cause:
          'Ganoderma boninense (white rot fungus); infects through root wounds and the stem base.',
      symptoms: [
        'Pale yellowing of older fronds; reduced bunch size',
        'Conks (shelf fungi) at the stem base in wet season',
        'Internal dry rot and trunk weakening; palm falls in wind',
      ],
      immediateActions: [
        'Remove and split or burn trunks with conks; do not chip into the field',
        'Improve drainage; avoid waterlogging around the base',
        'Replant with tolerant material on clean land',
      ],
      prevention: [
        'Clean planting sites; do not replant into dead palm holes',
        'Balanced nutrition; avoid root injuries from weeding and vehicles',
        'Isolate infested spots',
      ],
      expertNote:
          'Ganoderma confirms slow death of the stand. Count palms with conks and plan replanting with your PCA officer.',
    ),
  ),
];

const _healthyEntry = _KnowledgeEntry(
  label: 'Healthy crop',
  keywords: ['healthy'],
  crops: [],
  details: _healthyDetails,
);

String _normalize(String raw) {
  final trimmed = raw.trim().toLowerCase();
  return trimmed.replaceAll(RegExp(r'\s+'), ' ');
}

bool _looksHealthy(String text) {
  const healthyTerms = ['healthy', 'no disease', 'no problem', 'uninfected'];
  return healthyTerms.any(text.contains);
}

bool _cropMatches(List<String> entryCrops, String cropName) {
  if (entryCrops.isEmpty) return true;
  final crop = _normalize(cropName);
  return entryCrops.any((c) => crop.contains(c));
}

bool _keywordMatches(List<String> keywords, String text) {
  return keywords.any((k) => text.contains(k.toLowerCase()));
}

/// Returns curated details for a diagnosis, or generic honest guidance when
/// the disease is unknown. Never returns null: the UI can always render the
/// cause / symptoms / actions / prevention sections.
DiagnosisDetails knowledgeFor({
  required String diseaseDetected,
  required String cropName,
}) {
  final text = _normalize(diseaseDetected);

  if (_looksHealthy(text)) return _healthyEntry.details;

  // 1) Crop-scoped match (best quality).
  for (final entry in _entries) {
    if (_cropMatches(entry.crops, cropName) && _keywordMatches(entry.keywords, text)) {
      return entry.details;
    }
  }

  // 2) Cross-crop keyword match (disease is distinctive).
  for (final entry in _entries) {
    if (_keywordMatches(entry.keywords, text)) {
      return entry.details;
    }
  }

  // 3) Honest generic guidance: unknown disease, still useful.
  return _genericDetails;
}

/// Every curated disease's details; used by tests to guarantee completeness.
List<DiagnosisDetails> get allCuratedDetails =>
    _entries.map((entry) => entry.details).toList();

/// Disease candidates for the offline demo engine for a given crop.
/// Unknown crops get every curated disease so the demo stays varied.
List<(String, DiagnosisDetails)> demoDiagnosesForCrop(String cropName) {
  final matches = _entries
      .where((entry) => _cropMatches(entry.crops, cropName))
      .toList();
  if (matches.isEmpty) {
    return _entries.map((entry) => (entry.label, entry.details)).toList();
  }
  return matches.map((entry) => (entry.label, entry.details)).toList();
}

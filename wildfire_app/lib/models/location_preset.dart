class LocationPreset {
  final String name;
  final String region;
  final String state;
  final double latitude;
  final double longitude;
  final String description;
  final String ecosystem;
  final String riskSeason;

  const LocationPreset({
    required this.name,
    required this.region,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.ecosystem,
    required this.riskSeason,
  });

  static const List<LocationPreset> indiaPresets = [
    LocationPreset(
      name: 'Nainital / Almora Forest Belt',
      region: 'Kumaon Division',
      state: 'Uttarakhand',
      latitude: 29.3803,
      longitude: 79.4636,
      description: 'Chir Pine (Pinus roxburghii) forests with heavy dry needle litter prone to seasonal summer infernos.',
      ecosystem: 'Himalayan Subtropical Pine Forest',
      riskSeason: 'March – June (Pre-Monsoon)',
    ),
    LocationPreset(
      name: 'Simlipal Biosphere Reserve',
      region: 'Mayurbhanj District',
      state: 'Odisha',
      latitude: 21.9333,
      longitude: 86.3500,
      description: 'Dense Sal (Shorea robusta) deciduous forests with high seasonal ground biomass accumulation.',
      ecosystem: 'Eastern Highlands Moist Deciduous',
      riskSeason: 'February – May',
    ),
    LocationPreset(
      name: 'Bandipur & Nagarhole Tiger Reserves',
      region: 'Mysuru & Chamarajanagar',
      state: 'Karnataka',
      latitude: 11.6664,
      longitude: 76.6291,
      description: 'Western Ghats transition zone containing dry bamboo brakes and thorny scrub vulnerable to severe summer blazes.',
      ecosystem: 'Western Ghats Dry Deciduous',
      riskSeason: 'January – April',
    ),
    LocationPreset(
      name: 'Satpura & Kanha Forest Range',
      region: 'Hoshangabad & Mandla',
      state: 'Madhya Pradesh',
      latitude: 22.4500,
      longitude: 78.4333,
      description: 'Central Indian teak and bamboo tracts susceptible to widespread pre-monsoon leaf-litter fires.',
      ecosystem: 'Central Deccan Plateau Moist Forest',
      riskSeason: 'February – May',
    ),
    LocationPreset(
      name: 'Dzukou Valley & Kohima Range',
      region: 'Kohima / Senapati Border',
      state: 'Nagaland & Manipur',
      latitude: 25.5683,
      longitude: 94.0672,
      description: 'High-altitude sub-alpine bamboo valley prone to fierce winter and pre-spring wildfires across rugged ridges.',
      ecosystem: 'Northeast Montane Grasslands',
      riskSeason: 'December – March',
    ),
    LocationPreset(
      name: 'Nilgiri Foothills & Mudumalai',
      region: 'Nilgiris District',
      state: 'Tamil Nadu',
      latitude: 11.5833,
      longitude: 76.5333,
      description: 'Biosphere reserve interface between moist rainforest and dry deciduous slopes with invasive senna weed fuel.',
      ecosystem: 'South Western Ghats Montane',
      riskSeason: 'February – May',
    ),
    LocationPreset(
      name: 'Sariska & Aravalli Forest Ridge',
      region: 'Alwar District',
      state: 'Rajasthan',
      latitude: 27.3167,
      longitude: 76.4333,
      description: 'Arid scrub and Dhok (Anogeissus pendula) forest experiencing extreme heatwaves up to 45°C.',
      ecosystem: 'Aravalli Dry Scrub & Forest',
      riskSeason: 'April – June (Heatwave Peak)',
    ),
    LocationPreset(
      name: 'Wayanad Wildlife Sanctuary',
      region: 'Sultan Bathery Range',
      state: 'Kerala',
      latitude: 11.6854,
      longitude: 76.3683,
      description: 'Contiguous with Nilgiri Biosphere; dry deciduous patches face acute drying during rainshadow months.',
      ecosystem: 'Malabar Coast Moist Deciduous',
      riskSeason: 'January – April',
    ),
  ];

  // Backwards compatibility alias
  static List<LocationPreset> get presets => indiaPresets;
}

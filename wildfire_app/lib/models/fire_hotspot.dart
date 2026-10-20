class FireHotspot {
  final String id;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double brightnessKelvin;
  final double frpMw;
  final String confidence;
  final int confidencePercent;
  final String satellite;
  final String instrument;
  final String acquisitionDate;
  final String acquisitionTime;
  final String dayNight;
  final String status;

  FireHotspot({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.brightnessKelvin,
    required this.frpMw,
    required this.confidence,
    required this.confidencePercent,
    required this.satellite,
    required this.instrument,
    required this.acquisitionDate,
    required this.acquisitionTime,
    required this.dayNight,
    required this.status,
  });

  factory FireHotspot.fromJson(Map<String, dynamic> json) {
    return FireHotspot(
      id: json['id']?.toString() ?? 'hotspot_unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      brightnessKelvin: (json['brightness_kelvin'] as num?)?.toDouble() ?? 330.0,
      frpMw: (json['frp_mw'] as num?)?.toDouble() ?? 10.0,
      confidence: json['confidence']?.toString() ?? 'nominal',
      confidencePercent: (json['confidence_percent'] as num?)?.toInt() ?? 80,
      satellite: json['satellite']?.toString() ?? 'VIIRS',
      instrument: json['instrument']?.toString() ?? 'VIIRS',
      acquisitionDate: json['acquisition_date']?.toString() ?? '',
      acquisitionTime: json['acquisition_time']?.toString() ?? '',
      dayNight: json['daynight']?.toString() ?? 'D',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class HotspotsReport {
  final String source;
  final String attribution;
  final bool isLiveApi;
  final double centerLat;
  final double centerLon;
  final double radiusKm;
  final int hotspotsCount;
  final String timestamp;
  final String satelliteDelayNote;
  final List<FireHotspot> hotspots;

  HotspotsReport({
    required this.source,
    required this.attribution,
    required this.isLiveApi,
    required this.centerLat,
    required this.centerLon,
    required this.radiusKm,
    required this.hotspotsCount,
    required this.timestamp,
    required this.satelliteDelayNote,
    required this.hotspots,
  });

  factory HotspotsReport.fromJson(Map<String, dynamic> json) {
    final center = (json['center'] as Map<String, dynamic>?) ?? {};
    final list = (json['hotspots'] as List<dynamic>?)
            ?.map((e) => FireHotspot.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return HotspotsReport(
      source: json['source']?.toString() ?? 'NASA FIRMS',
      attribution: json['attribution']?.toString() ?? 'NASA ESDIS',
      isLiveApi: json['is_live_api'] as bool? ?? false,
      centerLat: (center['latitude'] as num?)?.toDouble() ?? 0.0,
      centerLon: (center['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 100.0,
      hotspotsCount: (json['hotspots_count'] as num?)?.toInt() ?? list.length,
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      satelliteDelayNote: json['satellite_delay_note']?.toString() ??
          'NASA FIRMS satellite overpass observations may have ~3-6 hour latency.',
      hotspots: list,
    );
  }
}

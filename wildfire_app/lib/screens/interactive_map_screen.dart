import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../models/fire_hotspot.dart';
import '../models/location_preset.dart';
import '../state/app_state.dart';
import '../widgets/hotspot_bottom_sheet.dart';
import '../widgets/preset_selector_sheet.dart';

class InteractiveMapScreen extends StatefulWidget {
  final AppState appState;

  const InteractiveMapScreen({super.key, required this.appState});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  late final MapController _mapController;
  bool _showPredictedRiskZone = true;
  bool _showObservedHotspots = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _recenterMap() {
    final lat = widget.appState.currentLatitude;
    final lon = widget.appState.currentLongitude;
    _mapController.move(LatLng(lat, lon), 9.0);
  }

  void _flyToIndiaOverview() {
    // Geographic center of India
    _mapController.move(const LatLng(22.5937, 78.9629), 5.2);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final lat = widget.appState.currentLatitude;
        final lon = widget.appState.currentLongitude;
        final centerLatLng = LatLng(lat, lon);
        final prediction = widget.appState.prediction;
        final hotspotsReport = widget.appState.hotspots;
        final hotspots = hotspotsReport?.hotspots ?? [];
        final riskColor = AppColors.getRiskColorForScore(prediction?.riskScore ?? 50);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // 1. OpenStreetMap Interactive Canvas Focused on India
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centerLatLng,
                  initialZoom: 8.5,
                  minZoom: 4.5, // Keeps focus primarily on Indian Subcontinent
                  maxZoom: 18.0,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(
                      const LatLng(6.0, 66.0),   // South-West of India
                      const LatLng(38.0, 99.0),  // North-East of India
                    ),
                  ),
                  onTap: (tapPosition, point) {
                    _onMapTapped(point);
                  },
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.wildfire.ai',
                    maxZoom: 19,
                  ),

                  // Predicted Risk Area (Semi-transparent circle overlay)
                  if (_showPredictedRiskZone)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: centerLatLng,
                          radius: 35000, // 35 km radius zone
                          useRadiusInMeter: true,
                          color: riskColor.withValues(alpha: 0.18),
                          borderColor: riskColor,
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),

                  // Markers: Center Location & Observed Hotspots
                  MarkerLayer(
                    markers: [
                      // Center Location Marker
                      Marker(
                        point: centerLatLng,
                        width: 50,
                        height: 50,
                        child: _buildCenterMarker(),
                      ),

                      // Satellite Detected Active Fire Hotspots (NASA FIRMS)
                      if (_showObservedHotspots)
                        ...hotspots.map((hotspot) {
                          return Marker(
                            point: LatLng(hotspot.latitude, hotspot.longitude),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () {
                                HotspotBottomSheet.show(
                                  context,
                                  hotspot,
                                  attribution: hotspotsReport?.attribution,
                                );
                              },
                              child: _buildHotspotMarker(hotspot),
                            ),
                          );
                        }),
                    ],
                  ),
                ],
              ),

              // 2. Top Floating Header & India Forest Region Quick Selector
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Column(
                    children: [
                      _buildTopLocationBar(context),
                      const SizedBox(height: 6),
                      _buildIndiaRegionChips(),
                      const SizedBox(height: 6),
                      _buildMapLegendBanner(riskColor, hotspots.length),
                    ],
                  ),
                ),
              ),

              // 3. Floating Map Controls (Right Side)
              Positioned(
                right: 14,
                bottom: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // India Overview Zoom
                    _buildFloatingButton(
                      icon: Icons.public_rounded,
                      isActive: true,
                      activeColor: const Color(0xFFFF9933), // Saffron
                      tooltip: 'Zoom to India Overview',
                      onPressed: _flyToIndiaOverview,
                    ),
                    const SizedBox(height: 8),

                    // Layer Toggle: Predicted Risk Zone
                    _buildFloatingButton(
                      icon: Icons.radar_rounded,
                      isActive: _showPredictedRiskZone,
                      activeColor: AppColors.primary,
                      tooltip: 'Toggle Predicted Risk Zone',
                      onPressed: () {
                        setState(() => _showPredictedRiskZone = !_showPredictedRiskZone);
                      },
                    ),
                    const SizedBox(height: 8),

                    // Layer Toggle: Observed Hotspots
                    _buildFloatingButton(
                      icon: Icons.whatshot_rounded,
                      isActive: _showObservedHotspots,
                      activeColor: AppColors.hotspotCore,
                      tooltip: 'Toggle Satellite Hotspots',
                      onPressed: () {
                        setState(() => _showObservedHotspots = !_showObservedHotspots);
                      },
                    ),
                    const SizedBox(height: 8),

                    // Recenter button
                    _buildFloatingButton(
                      icon: Icons.my_location_rounded,
                      isActive: true,
                      activeColor: AppColors.info,
                      tooltip: 'Recenter to Monitored Forest Belt',
                      onPressed: _recenterMap,
                    ),
                  ],
                ),
              ),

              // 4. Tap-To-Inspect Instructions Pill
              Positioned(
                left: 14,
                bottom: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Tap Indian map to test risk',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapTapped(LatLng point) {
    widget.appState.setCustomLocation(
      point.latitude,
      point.longitude,
      name: 'Pinned Indian Coordinate',
      region: 'India (${point.latitude.toStringAsFixed(2)}° N, ${point.longitude.toStringAsFixed(2)}° E)',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moved monitoring to ${point.latitude.toStringAsFixed(3)}° N, ${point.longitude.toStringAsFixed(3)}° E',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildCenterMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.person_pin_circle_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildHotspotMarker(FireHotspot hotspot) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hotspotCore,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.yellow, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotspotCore.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_fire_department_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  Widget _buildTopLocationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHighlight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forest_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.appState.currentLocationName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9933).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'INDIA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF9933),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.appState.currentRegion,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => PresetSelectorSheet.show(context, widget.appState),
          ),
        ],
      ),
    );
  }

  Widget _buildIndiaRegionChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: LocationPreset.indiaPresets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final preset = LocationPreset.indiaPresets[index];
          final isSelected = !widget.appState.isCustomLocation &&
              widget.appState.currentPreset.name == preset.name;

          return InkWell(
            onTap: () {
              widget.appState.selectPreset(preset, index);
              _mapController.move(LatLng(preset.latitude, preset.longitude), 9.0);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: isSelected ? AppColors.background : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    preset.state,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.background : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapLegendBanner(Color riskColor, int hotspotCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: riskColor.withValues(alpha: 0.4),
                  border: Border.all(color: riskColor, width: 1.5),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Predicted Risk Zone',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.hotspotCore,
                  border: Border.all(color: Colors.yellow, width: 1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'NASA FIRMS Hotspots ($hotspotCount)',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? activeColor : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: isActive ? activeColor : AppColors.textSecondary, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

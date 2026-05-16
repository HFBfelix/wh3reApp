import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/models/suggestion_model.dart';

/// Carte Google Maps avec les marqueurs des suggestions.
class SuggestionsMap extends StatefulWidget {
  const SuggestionsMap({
    super.key,
    required this.suggestions,
    this.height = 240,
    this.onSuggestionTap,
  });

  final List<SuggestionModel> suggestions;
  final double height;
  final ValueChanged<SuggestionModel>? onSuggestionTap;

  @override
  State<SuggestionsMap> createState() => _SuggestionsMapState();
}

class _SuggestionsMapState extends State<SuggestionsMap> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant SuggestionsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions) {
      _fitBounds();
    }
  }

  List<SuggestionModel> get _located => widget.suggestions
      .where((s) => s.placeLocation != null)
      .toList();

  @override
  Widget build(BuildContext context) {
    if (_located.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppColors.radiusCard),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Carte indisponible — coordonnées manquantes',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final initial = _located.first.placeLocation!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusCard),
      child: SizedBox(
        height: widget.height,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(initial.latitude, initial.longitude),
            zoom: 13,
          ),
          markers: _buildMarkers(),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            _fitBounds();
          },
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _located.map((suggestion) {
      final point = suggestion.placeLocation!;
      return Marker(
        markerId: MarkerId(suggestion.id),
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
          title: '#${suggestion.rank} ${suggestion.placeName}',
          snippet: suggestion.placeAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          suggestion.isSelected
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueViolet,
        ),
        onTap: () => widget.onSuggestionTap?.call(suggestion),
      );
    }).toSet();
  }

  Future<void> _fitBounds() async {
    final controller = _controller;
    if (controller == null || _located.length < 2) return;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final s in _located) {
      final p = s.placeLocation!;
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 48),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../providers/report_draft_provider.dart';
import 'widgets/report_flow_stepper.dart';

class ReportLocationScreen extends ConsumerStatefulWidget {
  const ReportLocationScreen({super.key});

  @override
  ConsumerState<ReportLocationScreen> createState() =>
      _ReportLocationScreenState();
}

class _ReportLocationScreenState extends ConsumerState<ReportLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  late final TextEditingController _addressController;

  static const _defaultLocation = LatLng(1.2136, -77.2811);
  LatLng _selectedLocation = _defaultLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportDraftProvider);
    _addressController = TextEditingController(text: draft.address);
    if (draft.latitude != 0.0 && draft.longitude != 0.0) {
      _selectedLocation = LatLng(draft.latitude, draft.longitude);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveLocation() {
    ref.read(reportDraftProvider.notifier).setLocation(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          address: _addressController.text.trim(),
        );
  }

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLocating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        _showToast(l10n.locationServiceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showToast(l10n.locationPermissionDenied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showToast(l10n.locationPermissionPermanentlyDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = point);
      _mapController.move(point, 14.5);
    } catch (_) {
      if (mounted) _showToast(l10n.locationFetchError);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? true) {
      _saveLocation();
      context.push('/report/new/details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 4 de 6
            ReportFlowStepper(
              currentStep: 4,
              stepTitle: l10n.reportLocationTitle,
              onBack: () {
                _saveLocation();
                context.pop();
              },
            ),

            // Contenido
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PetTokens.gutter,
                  12,
                  PetTokens.gutter,
                  110,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Título según Paso4Ubicacion.dc.html
                      Text(
                        isLost
                            ? l10n.reportLocationLostQuestion
                            : l10n.reportLocationFoundQuestion,
                        style: PetTokens.displayThemed(context, 34),
                      ),
                      const SizedBox(height: 16),

                      // Mapa con radio de alerta de 5 km
                      Container(
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: PetTokens.borderDark),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x122A1A29),
                              offset: Offset(0, 6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _selectedLocation,
                                  initialZoom: 13.5,
                                  minZoom: 4,
                                  maxZoom: 18,
                                  onTap: (_, point) {
                                    setState(() => _selectedLocation = point);
                                  },
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.all &
                                        ~InteractiveFlag.rotate,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    fallbackUrl:
                                        'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.petlink',
                                  ),
                                  // Círculo de radio de alerta de 5 km
                                  CircleLayer(
                                    circles: [
                                      CircleMarker(
                                        point: _selectedLocation,
                                        radius: 5000,
                                        useRadiusInMeter: true,
                                        color: PetTokens.clay
                                            .withValues(alpha: 0.12),
                                        borderColor: PetTokens.clay,
                                        borderStrokeWidth: 1.5,
                                      ),
                                    ],
                                  ),
                                  // Pin de ubicación de la mascota
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _selectedLocation,
                                        width: 52,
                                        height: 62,
                                        alignment: Alignment.topCenter,
                                        child: PetMapPin(
                                          color: isLost
                                              ? PetTokens.pinLost
                                              : PetTokens.mint,
                                          isSelected: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Badge flotante inferior sobre el mapa
                              Positioned(
                                left: 14,
                                right: 14,
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PetTokens.surface
                                        .withValues(alpha: 0.96),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1F2A1A29),
                                        offset: Offset(0, 6),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFCEEE8),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          PhosphorIconsBold.broadcast,
                                          color: PetTokens.clayText,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Localizations.localeOf(context).languageCode == 'en'
                                                  ? 'Alert within 5 km radius'
                                                  : 'Alerta en un radio de 5 km',
                                              style: PetTokens.bodyThemed(
                                                context,
                                                13,
                                                color: PetTokens.inkOf(context),
                                                weight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              Localizations.localeOf(context).languageCode == 'en'
                                                  ? 'We will notify the nearby community.'
                                                  : 'Avisaremos a la comunidad cercana.',
                                              style: PetTokens.bodyThemed(
                                                context,
                                                12,
                                                color: PetTokens.mutedOf(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Campo de dirección con botón de ubicación GPS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _addressController,
                              style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context)),
                              decoration: InputDecoration(
                                hintText: l10n.reportLocationHint,
                                hintStyle: PetTokens.body(
                                  15,
                                  color: PetTokens.placeholder,
                                ),
                                prefixIcon: const Icon(
                                  PhosphorIconsRegular.mapPin,
                                  color: PetTokens.muted,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: PetTokens.surfaceOf(context),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: PetTokens.borderOf(context),
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: PetTokens.plum,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.requiredLocation;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: _isLocating ? null : _useCurrentLocation,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: PetTokens.plum,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x334A2D4A),
                                    offset: Offset(0, 6),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _isLocating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      PhosphorIconsBold.crosshair,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones inferiores (Volver + Continuar)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter,
                0,
                PetTokens.gutter,
                24,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _saveLocation();
                      context.pop();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 110,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PetTokens.plum, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.backAction,
                        style: PetTokens.body(
                          15,
                          color: PetTokens.plum,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _onContinue,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: PetTokens.plum,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: PetTokens.shadowButton,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.continueAction,
                              style: PetTokens.body(
                                16,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
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
}

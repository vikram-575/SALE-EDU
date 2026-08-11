import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/lead_provider.dart';

class GeoFilterSheet extends ConsumerStatefulWidget {
  const GeoFilterSheet({super.key});

  @override
  ConsumerState<GeoFilterSheet> createState() => _GeoFilterSheetState();
}

class _GeoFilterSheetState extends ConsumerState<GeoFilterSheet> {
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(leadProvider);
    _cityController.text = state.selectedCity ?? '';
    _districtController.text = state.selectedDistrict ?? '';
    _pincodeController.text = state.selectedPincode ?? '';
  }

  void _applyFilters() {
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();
    final pincode = _pincodeController.text.trim();

    ref.read(leadProvider.notifier).setGeoFilters(
      city: city.isEmpty ? null : city,
      district: district.isEmpty ? null : district,
      pincode: pincode.isEmpty ? null : pincode,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    _cityController.clear();
    _districtController.clear();
    _pincodeController.clear();
    ref.read(leadProvider.notifier).clearGeoFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadProvider);
    final hasActiveGeoFilter = state.selectedCity != null || state.selectedDistrict != null || state.selectedPincode != null;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text('Geo Location Filter', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                if (hasActiveGeoFilter)
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Clear All', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            const SizedBox(height: 4),
            Text('Filter CRM Leads, Pipelines & Metrics by City, District or Pincode', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 24, color: AppColors.border),

            TextFormField(
              controller: _cityController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'City (e.g. Jaipur, Lucknow, Indore)',
                prefixIcon: Icon(Icons.location_city, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _districtController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'District (e.g. Jaipur, Gautam Buddha Nagar)',
                prefixIcon: Icon(Icons.map_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Pincode (e.g. 302001, 201301)',
                prefixIcon: Icon(Icons.pin_drop_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_alt, color: Colors.white),
                label: Text('APPLY GEO FILTERS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

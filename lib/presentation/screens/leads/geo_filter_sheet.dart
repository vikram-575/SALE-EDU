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
  String? _selectedState;
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  final List<String> _states = [
    'ALL',
    'Rajasthan',
    'Uttar Pradesh',
    'Delhi NCR',
    'Haryana',
    'Punjab',
    'Madhya Pradesh',
    'Gujarat',
    'Maharashtra',
    'Bihar',
    'Uttarakhand',
  ];

  final List<String> _popularDistricts = [
    'Jaipur',
    'Jodhpur',
    'Kota',
    'Udaipur',
    'Alwar',
    'Sikar',
    'Ajmer',
    'Bikaner',
    'Noida',
    'Lucknow',
    'Gurgaon',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(leadProvider);
    _selectedState = state.selectedState ?? 'ALL';
    _cityController.text = state.selectedCity ?? '';
    _districtController.text = state.selectedDistrict ?? '';
    _pincodeController.text = state.selectedPincode ?? '';
  }

  void _applyFilters() {
    final city = _cityController.text.trim();
    final district = _districtController.text.trim();
    final pincode = _pincodeController.text.trim();
    final stateFilter = (_selectedState == null || _selectedState == 'ALL') ? null : _selectedState;

    ref.read(leadProvider.notifier).setGeoFilters(
      stateFilter: stateFilter,
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
    _selectedState = 'ALL';
    ref.read(leadProvider.notifier).clearGeoFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadProvider);
    final hasActiveGeoFilter = state.selectedState != null || state.selectedCity != null || state.selectedDistrict != null || state.selectedPincode != null;

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
                    Text('Location & Territory Filter', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
            Text('Filter leads state-wise, district-wise, and pincode-wise', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 20, color: AppColors.border),

            // State Selector
            DropdownButtonFormField<String>(
              value: _selectedState,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Filter by State',
                prefixIcon: Icon(Icons.public, color: AppColors.primary),
              ),
              items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s == 'ALL' ? 'All States (Pan India)' : s))).toList(),
              onChanged: (v) => setState(() => _selectedState = v),
            ),
            const SizedBox(height: 12),

            // District Input + Quick Chips
            TextFormField(
              controller: _districtController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'District Name (e.g. Jaipur, Kota, Noida)',
                prefixIcon: Icon(Icons.map_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularDistricts.map((d) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(d, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                    backgroundColor: AppColors.background,
                    onPressed: () => setState(() => _districtController.text = d),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // City Input
            TextFormField(
              controller: _cityController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'City / Town',
                prefixIcon: Icon(Icons.location_city, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 12),

            // Pincode Input
            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Pincode (e.g. 302001, 302020)',
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
                label: Text('APPLY FILTERS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
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

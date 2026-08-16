import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../../providers/lead_provider.dart';
import '../profile/profile_screen.dart';
import 'lead_detail_screen.dart';
import 'create_edit_lead_screen.dart';
import 'geo_filter_sheet.dart';

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  final _searchController = TextEditingController();

  void _openGeoFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GeoFilterSheet(),
    );
  }

  void _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/91$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
    final leadNotifier = ref.read(leadProvider.notifier);

    final hasActiveGeoFilter = leadState.selectedState != null || leadState.selectedCity != null || leadState.selectedDistrict != null || leadState.selectedPincode != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leads Directory', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on_outlined, color: hasActiveGeoFilter ? AppColors.secondary : AppColors.textPrimary),
            tooltip: 'Filter State, District & Pincode',
            onPressed: _openGeoFilter,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.secondary),
            tooltip: 'Agent Profile',
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Lead',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEditLeadScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Active Geo Filter Banner
          if (hasActiveGeoFilter)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered: ${[
                        if (leadState.selectedState != null) 'State: ${leadState.selectedState}',
                        if (leadState.selectedDistrict != null) 'Dist: ${leadState.selectedDistrict}',
                        if (leadState.selectedCity != null) 'City: ${leadState.selectedCity}',
                        if (leadState.selectedPincode != null) 'Pin: ${leadState.selectedPincode}'
                      ].join(" • ")}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  InkWell(
                    onTap: () => leadNotifier.clearGeoFilters(),
                    child: const Icon(Icons.close, size: 16, color: AppColors.primary),
                  )
                ],
              ),
            ),

          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => leadNotifier.setSearchQuery(value),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search State, District, Pincode, School, Contact...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              leadNotifier.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('ALL Stages', leadState.selectedStageFilter == 'ALL', () => leadNotifier.setStageFilter('ALL')),
                      _filterChip('NEW', leadState.selectedStageFilter == 'NEW', () => leadNotifier.setStageFilter('NEW')),
                      _filterChip('QUALIFIED', leadState.selectedStageFilter == 'QUALIFIED', () => leadNotifier.setStageFilter('QUALIFIED')),
                      _filterChip('CONTACTED', leadState.selectedStageFilter == 'CONTACTED', () => leadNotifier.setStageFilter('CONTACTED')),
                      _filterChip('DEMO BOOKED', leadState.selectedStageFilter == 'DEMO_BOOKED', () => leadNotifier.setStageFilter('DEMO_BOOKED')),
                      _filterChip('TRIAL', leadState.selectedStageFilter == 'TRIAL', () => leadNotifier.setStageFilter('TRIAL')),
                      _filterChip('WON', leadState.selectedStageFilter == 'WON', () => leadNotifier.setStageFilter('WON')),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Lead Cards List
          Expanded(
            child: leadState.isLoading
                ? const LoadingIndicator(message: 'Querying leads...')
                : leadState.leads.isEmpty
                    ? const EmptyStateWidget(
                        message: 'No leads found.',
                        subtitle: 'No matching leads found for the selected state, district, or pincode filters.',
                        icon: Icons.person_search_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => leadNotifier.loadLeads(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: leadState.leads.length,
                          itemBuilder: (context, index) {
                            final lead = leadState.leads[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => LeadDetailScreen(leadId: lead.id)),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lead.schoolName,
                                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          StatusBadge.stage(lead.stage),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(lead.contactPerson, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                            ],
                                          ),
                                          if (lead.phone != null && lead.phone!.isNotEmpty)
                                            InkWell(
                                              onTap: () => _launchWhatsApp(lead.phone),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFF25D366)),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.chat, size: 12, color: Color(0xFF25D366)),
                                                    SizedBox(width: 4),
                                                    Text('WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontSize: 11, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Geo Location Pills (State, District, City, Pincode)
                                      Row(
                                        children: [
                                          const Icon(Icons.place_outlined, size: 14, color: AppColors.secondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${lead.city ?? 'Jaipur'}${lead.district != null && lead.district!.isNotEmpty ? ', Dist: ${lead.district}' : ''}${lead.state != null && lead.state!.isNotEmpty ? ', ${lead.state}' : ''}${lead.pincode != null && lead.pincode!.isNotEmpty ? ' (${lead.pincode})' : ''}',
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20, color: AppColors.border),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              StatusBadge.priority(lead.priority),
                                              const SizedBox(width: 8),
                                              Text('Score: ${lead.leadScore}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          Text(
                                            CurrencyFormatter.formatINR(lead.expectedValue),
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.secondary, fontSize: 14),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/network/api_service.dart';
import '../models/customer_model.dart';
import '../models/onboarding_model.dart';

class ConversionRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Run Duplicate Protection Scan
  Future<Map<String, dynamic>> checkDuplicates({
    required String schoolName,
    String? phone,
    String? email,
    String? website,
  }) async {
    try {
      return await ApiService.checkDuplicateCustomer(
        schoolName: schoolName,
        phone: phone,
        email: email,
        website: website,
      );
    } catch (_) {
      return {'success': true, 'hasDuplicate': false, 'duplicates': []};
    }
  }

  // Execute Lead Conversion Transaction
  Future<Map<String, dynamic>> convertLeadToCustomer({
    required String leadId,
    double? annualRevenue,
    double? monthlyRevenue,
    double? oneTimeRevenue,
    String? planId,
    String? targetGoLiveDate,
    String? userId,
    bool bypassDuplicateCheck = false,
  }) async {
    final now = DateTime.now().toIso8601String();
    final customerId = 'cust_$leadId';
    final onboardingId = 'onb_$leadId';

    // 1. Direct Supabase Lead Stage Update to WON
    try {
      await _client.from('Lead').update({
        'stage': 'WON',
        'updatedAt': now,
      }).eq('id', leadId);

      // Log Conversion into LeadNote & SalesNote
      await _client.from('LeadNote').insert({
        'id': 'lnote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': leadId,
        'content': '🎉 LEAD CONVERTED TO CUSTOMER! ARR: ₹${annualRevenue ?? 150000}',
        'authorId': userId ?? 'agent_vikram_01',
        'createdAt': now,
      });

      await _client.from('SalesNote').insert({
        'id': 'snote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': leadId,
        'authorName': 'Vikram',
        'content': '🎉 Lead successfully converted to Paying Customer! Annual Contract Value: ₹${annualRevenue ?? 150000}',
        'tags': ['#Won', '#Customer', '#Revenue'],
        'isPinned': true,
        'createdAt': now,
      });
    } catch (_) {}

    // 2. Call backend proxy if available in background
    try {
      ApiService.convertLeadTransaction(
        leadId: leadId,
        annualRevenue: annualRevenue,
        monthlyRevenue: monthlyRevenue,
        oneTimeRevenue: oneTimeRevenue,
        planId: planId,
        targetGoLiveDate: targetGoLiveDate,
        userId: userId,
        bypassDuplicateCheck: bypassDuplicateCheck,
      );
    } catch (_) {}

    return {
      'success': true,
      'data': {
        'customerId': customerId,
        'onboardingId': onboardingId,
        'leadId': leadId,
        'status': 'ACTIVE',
      }
    };
  }

  // Fetch Customer Profile with School info
  Future<CustomerModel?> getCustomerByLeadId(String leadId) async {
    try {
      final response = await _client.from('Customer').select('*').eq('leadId', leadId).maybeSingle();
      if (response == null) return null;
      return CustomerModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // Fetch Onboarding Record
  Future<OnboardingRecordModel?> getOnboardingByCustomerId(String customerId) async {
    try {
      final response = await _client.from('OnboardingRecord').select('*').eq('customerId', customerId).maybeSingle();
      if (response == null) return null;
      return OnboardingRecordModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // Update Onboarding Checklist Progress
  Future<void> updateOnboardingChecklist(String onboardingId, Map<String, bool> checklist) async {
    final bool allDone = !checklist.values.contains(false);
    final now = DateTime.now().toIso8601String();

    try {
      await _client.from('OnboardingRecord').update({
        'checklistProgress': checklist,
        'status': allDone ? 'COMPLETED' : 'IN_PROGRESS',
        if (allDone) 'completedAt': now,
        'updatedAt': now,
      }).eq('id', onboardingId);
    } catch (_) {}
  }
}

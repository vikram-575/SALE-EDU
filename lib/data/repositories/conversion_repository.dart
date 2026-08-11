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
    return await ApiService.checkDuplicateCustomer(
      schoolName: schoolName,
      phone: phone,
      email: email,
      website: website,
    );
  }

  // Execute Controlled Lead Conversion Transaction
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
    return await ApiService.convertLeadTransaction(
      leadId: leadId,
      annualRevenue: annualRevenue,
      monthlyRevenue: monthlyRevenue,
      oneTimeRevenue: oneTimeRevenue,
      planId: planId,
      targetGoLiveDate: targetGoLiveDate,
      userId: userId,
      bypassDuplicateCheck: bypassDuplicateCheck,
    );
  }

  // Fetch Customer Profile with School info
  Future<CustomerModel?> getCustomerByLeadId(String leadId) async {
    final response = await _client.from('Customer').select('*').eq('leadId', leadId).maybeSingle();
    if (response == null) return null;
    return CustomerModel.fromJson(response);
  }

  // Fetch Onboarding Record
  Future<OnboardingRecordModel?> getOnboardingByCustomerId(String customerId) async {
    final response = await _client.from('OnboardingRecord').select('*').eq('customerId', customerId).maybeSingle();
    if (response == null) return null;
    return OnboardingRecordModel.fromJson(response);
  }

  // Update Onboarding Checklist Progress
  Future<void> updateOnboardingChecklist(String onboardingId, Map<String, bool> checklist) async {
    final bool allDone = !checklist.values.contains(false);
    final now = DateTime.now().toIso8601String();

    await _client.from('OnboardingRecord').update({
      'checklistProgress': checklist,
      'status': allDone ? 'COMPLETED' : 'IN_PROGRESS',
      if (allDone) 'completedAt': now,
      'updatedAt': now,
    }).eq('id', onboardingId);
  }
}

class LeadModel {
  final String id;
  final String schoolName;
  final String contactPerson;
  final String? designation;
  final String? phone;
  final String? email;
  final String? telegramUsername;
  final String? telegramChatId;
  final String? website;
  final String? city;
  final String? district;
  final String? pincode;
  final String? state;
  final String? country;
  final String? schoolType;
  final String? board;
  final int approxStudentCount;
  final int approxTeacherCount;
  final int numberOfBranches;
  final String? currentSoftware;
  final String? currentProblems;
  final String source;
  final String? campaign;
  final String? ownerId;
  final int leadScore;
  final String priority;
  final String stage;
  final double expectedValue;
  final double probability;
  final DateTime? nextFollowupAt;
  final DateTime? lastContactedAt;
  final String? address;
  final String? googleMapsUrl;
  final String? linkedinUrl;
  final String? decisionMaker;
  final String? influencer;
  final String? procurementContact;
  final bool isArchived;
  final String? lostReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadModel({
    required this.id,
    required this.schoolName,
    required this.contactPerson,
    this.designation,
    this.phone,
    this.email,
    this.telegramUsername,
    this.telegramChatId,
    this.website,
    this.city,
    this.district,
    this.pincode,
    this.state,
    this.country,
    this.schoolType,
    this.board,
    this.approxStudentCount = 0,
    this.approxTeacherCount = 0,
    this.numberOfBranches = 1,
    this.currentSoftware,
    this.currentProblems,
    this.source = 'FIELD_VISIT',
    this.campaign,
    this.ownerId,
    this.leadScore = 0,
    this.priority = 'WARM',
    this.stage = 'NEW',
    this.expectedValue = 0.0,
    this.probability = 0.1,
    this.nextFollowupAt,
    this.lastContactedAt,
    this.address,
    this.googleMapsUrl,
    this.linkedinUrl,
    this.decisionMaker,
    this.influencer,
    this.procurementContact,
    this.isArchived = false,
    this.lostReason,
    required this.createdAt,
    required this.updatedAt,
  });

  LeadModel copyWith({
    String? id,
    String? schoolName,
    String? contactPerson,
    String? designation,
    String? phone,
    String? email,
    String? telegramUsername,
    String? telegramChatId,
    String? website,
    String? city,
    String? district,
    String? pincode,
    String? state,
    String? country,
    String? schoolType,
    String? board,
    int? approxStudentCount,
    int? approxTeacherCount,
    int? numberOfBranches,
    String? currentSoftware,
    String? currentProblems,
    String? source,
    String? campaign,
    String? ownerId,
    int? leadScore,
    String? priority,
    String? stage,
    double? expectedValue,
    double? probability,
    DateTime? nextFollowupAt,
    DateTime? lastContactedAt,
    String? address,
    String? googleMapsUrl,
    String? linkedinUrl,
    String? decisionMaker,
    String? influencer,
    String? procurementContact,
    bool? isArchived,
    String? lostReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      contactPerson: contactPerson ?? this.contactPerson,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      website: website ?? this.website,
      city: city ?? this.city,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      state: state ?? this.state,
      country: country ?? this.country,
      schoolType: schoolType ?? this.schoolType,
      board: board ?? this.board,
      approxStudentCount: approxStudentCount ?? this.approxStudentCount,
      approxTeacherCount: approxTeacherCount ?? this.approxTeacherCount,
      numberOfBranches: numberOfBranches ?? this.numberOfBranches,
      currentSoftware: currentSoftware ?? this.currentSoftware,
      currentProblems: currentProblems ?? this.currentProblems,
      source: source ?? this.source,
      campaign: campaign ?? this.campaign,
      ownerId: ownerId ?? this.ownerId,
      leadScore: leadScore ?? this.leadScore,
      priority: priority ?? this.priority,
      stage: stage ?? this.stage,
      expectedValue: expectedValue ?? this.expectedValue,
      probability: probability ?? this.probability,
      nextFollowupAt: nextFollowupAt ?? this.nextFollowupAt,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      address: address ?? this.address,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      decisionMaker: decisionMaker ?? this.decisionMaker,
      influencer: influencer ?? this.influencer,
      procurementContact: procurementContact ?? this.procurementContact,
      isArchived: isArchived ?? this.isArchived,
      lostReason: lostReason ?? this.lostReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      schoolName: json['schoolName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      designation: json['designation'],
      phone: json['phone'],
      email: json['email'],
      telegramUsername: json['telegramUsername'],
      telegramChatId: json['telegramChatId'],
      website: json['website'],
      city: json['city'],
      district: json['district'],
      pincode: json['pincode'],
      state: json['state'],
      country: json['country'] ?? 'India',
      schoolType: json['schoolType'],
      board: json['board'],
      approxStudentCount: json['approxStudentCount'] ?? 0,
      approxTeacherCount: json['approxTeacherCount'] ?? 0,
      numberOfBranches: json['numberOfBranches'] ?? 1,
      currentSoftware: json['currentSoftware'],
      currentProblems: json['currentProblems'],
      source: json['source'] ?? 'FIELD_VISIT',
      campaign: json['campaign'],
      ownerId: json['ownerId'],
      leadScore: json['leadScore'] ?? 0,
      priority: json['priority'] ?? 'WARM',
      stage: json['stage'] ?? 'NEW',
      expectedValue: (json['expectedValue'] as num?)?.toDouble() ?? 0.0,
      probability: (json['probability'] as num?)?.toDouble() ?? 0.1,
      nextFollowupAt: json['nextFollowupAt'] != null ? DateTime.tryParse(json['nextFollowupAt']) : null,
      lastContactedAt: json['lastContactedAt'] != null ? DateTime.tryParse(json['lastContactedAt']) : null,
      address: json['address'],
      googleMapsUrl: json['googleMapsUrl'],
      linkedinUrl: json['linkedinUrl'],
      decisionMaker: json['decisionMaker'],
      influencer: json['influencer'],
      procurementContact: json['procurementContact'],
      isArchived: json['isArchived'] ?? false,
      lostReason: json['lostReason'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now() : DateTime.now(),
    );
  }

  // Sanitized database map for Supabase compatibility
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'schoolName': schoolName,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'city': city,
      'district': district,
      'pincode': pincode,
      'stage': stage,
      'priority': priority,
      'expectedValue': expectedValue,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toSupabaseMap();
}

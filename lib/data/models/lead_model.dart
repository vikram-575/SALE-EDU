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
    this.source = 'Website',
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

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'],
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
      source: json['source'] ?? 'Website',
      campaign: json['campaign'],
      ownerId: json['ownerId'],
      leadScore: json['leadScore'] ?? 0,
      priority: json['priority'] ?? 'WARM',
      stage: json['stage'] ?? 'NEW',
      expectedValue: (json['expectedValue'] as num?)?.toDouble() ?? 0.0,
      probability: (json['probability'] as num?)?.toDouble() ?? 0.1,
      nextFollowupAt: json['nextFollowupAt'] != null ? DateTime.parse(json['nextFollowupAt']) : null,
      lastContactedAt: json['lastContactedAt'] != null ? DateTime.parse(json['lastContactedAt']) : null,
      address: json['address'],
      googleMapsUrl: json['googleMapsUrl'],
      linkedinUrl: json['linkedinUrl'],
      decisionMaker: json['decisionMaker'],
      influencer: json['influencer'],
      procurementContact: json['procurementContact'],
      isArchived: json['isArchived'] ?? false,
      lostReason: json['lostReason'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'contactPerson': contactPerson,
      'designation': designation,
      'phone': phone,
      'email': email,
      'telegramUsername': telegramUsername,
      'telegramChatId': telegramChatId,
      'website': website,
      'city': city,
      'district': district,
      'pincode': pincode,
      'state': state,
      'country': country,
      'schoolType': schoolType,
      'board': board,
      'approxStudentCount': approxStudentCount,
      'approxTeacherCount': approxTeacherCount,
      'numberOfBranches': numberOfBranches,
      'currentSoftware': currentSoftware,
      'currentProblems': currentProblems,
      'source': source,
      'campaign': campaign,
      'ownerId': ownerId,
      'leadScore': leadScore,
      'priority': priority,
      'stage': stage,
      'expectedValue': expectedValue,
      'probability': probability,
      'nextFollowupAt': nextFollowupAt?.toIso8601String(),
      'lastContactedAt': lastContactedAt?.toIso8601String(),
      'address': address,
      'googleMapsUrl': googleMapsUrl,
      'linkedinUrl': linkedinUrl,
      'decisionMaker': decisionMaker,
      'influencer': influencer,
      'procurementContact': procurementContact,
      'isArchived': isArchived,
      'lostReason': lostReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

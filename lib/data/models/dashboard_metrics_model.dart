class DashboardMetricsModel {
  final int todaysLeads;
  final int newLeads;
  final int qualifiedLeads;
  final int contactedLeads;
  final int demosToday;
  final int demosThisWeek;
  final int activeTrials;
  final int trialsExpiring;
  final int conversions;
  final double conversionRate;
  final int lostLeads;
  final int followupsDueToday;
  final int overdueFollowups;
  final double expectedRevenue;
  final double pipelineValue;
  final double mrr;
  final int newCustomers;
  final double revenueThisMonth;

  DashboardMetricsModel({
    this.todaysLeads = 0,
    this.newLeads = 0,
    this.qualifiedLeads = 0,
    this.contactedLeads = 0,
    this.demosToday = 0,
    this.demosThisWeek = 0,
    this.activeTrials = 0,
    this.trialsExpiring = 0,
    this.conversions = 0,
    this.conversionRate = 0.0,
    this.lostLeads = 0,
    this.followupsDueToday = 0,
    this.overdueFollowups = 0,
    this.expectedRevenue = 0.0,
    this.pipelineValue = 0.0,
    this.mrr = 0.0,
    this.newCustomers = 0,
    this.revenueThisMonth = 0.0,
  });
}

class ApiConstants {
  // Supabase Credentials (gosonxfusaymwvkcqjgw)
  static const String supabaseUrl = 'https://gosonxfusaymwvkcqjgw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';
  static const String supabaseJwksUrl = 'https://gosonxfusaymwvkcqjgw.supabase.co/auth/v1/.well-known/jwks.json';

  // Live Production Render Backend API URL
  static const String backendApiUrl = 'https://sale-edu.onrender.com';
  static const String backendApiUrlLocal = 'https://sale-edu.onrender.com';

  // Endpoint routes
  static const String healthEndpoint = '/health';
  static const String telegramSendEndpoint = '/api/telegram/send';
  static const String telegramWebhookEndpoint = '/api/telegram/webhook';
  static const String duplicateCheckEndpoint = '/api/sales/duplicate-check';
  static const String convertLeadEndpoint = '/api/sales/convert-lead';
  static const String copilotEndpoint = '/api/sales/copilot';
}

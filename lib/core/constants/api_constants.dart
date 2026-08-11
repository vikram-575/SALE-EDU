class ApiConstants {
  // Supabase Credentials (Fully Functional Active Database)
  static const String supabaseUrl = 'https://rygtyzwkhcuiwxzqmmlo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5Z3R5endraGN1aXd4enFtbWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNzE5NjcsImV4cCI6MjA5ODY0Nzk2N30.wbG8zerewUJae0nMldQYbHJheE0yp1gnyjFBp5BqpdQ';

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

class ApiConstants {
  // Supabase Credentials
  static const String supabaseUrl = 'https://rygtyzwkhcuiwxzqmmlo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ5Z3R5endraGN1aXd4enFtbWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNzE5NjcsImV4cCI6MjA5ODY0Nzk2N30.wbG8zerewUJae0nMldQYbHJheE0yp1gnyjFBp5BqpdQ';

  // Backend API URL (Express / Supabase Backend)
  static const String backendApiUrl = 'http://10.0.2.2:5000'; // Standard Android emulator loopback or localhost
  static const String backendApiUrlLocal = 'http://localhost:5000';

  // Endpoint routes
  static const String healthEndpoint = '/health';
  static const String telegramSendEndpoint = '/api/telegram/send';
  static const String telegramWebhookEndpoint = '/api/telegram/webhook';
  static const String duplicateCheckEndpoint = '/api/sales/duplicate-check';
  static const String convertLeadEndpoint = '/api/sales/convert-lead';
  static const String copilotEndpoint = '/api/sales/copilot';
}

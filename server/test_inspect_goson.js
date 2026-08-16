const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const candidateTables = [
  'Lead', 'leads', 'lead',
  'SalesNote', 'sales_notes', 'sales_note',
  'LeadNote', 'lead_notes', 'lead_note',
  'LeadTask', 'lead_tasks', 'tasks', 'Task',
  'LeadActivity', 'lead_activities', 'Activity', 'activities',
  'Customer', 'customers', 'customer',
  'School', 'schools', 'school',
  'Subscription', 'subscriptions', 'subscription',
  'OnboardingRecord', 'onboarding_records', 'Onboarding', 'onboarding',
  'TelegramConversation', 'telegram_conversations', 'telegram_conversation',
  'TelegramMessage', 'telegram_messages', 'telegram_message',
  'User', 'users', 'user'
];

async function probe() {
  console.log('Probing tables on gosonxfusaymwvkcqjgw:');
  for (const t of candidateTables) {
    const { data, error } = await supabase.from(t).select('*').limit(1);
    if (!error) {
      console.log(`✅ Table exists: "${t}" (sample count: ${data ? data.length : 0})`);
      if (data && data.length > 0) {
        console.log(`   Columns:`, Object.keys(data[0]));
      }
    }
  }
}

probe().catch(console.error);

const dotenv = require('dotenv');
dotenv.config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function inspectAll() {
  const candidates = [
    'lead', 'leads', 'Lead', 'Leads',
    'telegram_message', 'telegram_messages', 'TelegramMessage', 'TelegramMessages',
    'telegram_conversation', 'telegram_conversations', 'TelegramConversation', 'TelegramConversations',
    'sales_note', 'sales_notes', 'SalesNote', 'SalesNotes',
    'customer', 'customers', 'Customer', 'Customers',
    'school', 'schools', 'School', 'Schools',
    'SystemSetting', 'system_setting', 'system_settings'
  ];

  for (const t of candidates) {
    const { data, error } = await supabase.from(t).select('*').limit(1);
    if (!error) {
      console.log(`✅ MATCH FOUND: '${t}' exists! Data count: ${data ? data.length : 0}`);
    }
  }
}

inspectAll();

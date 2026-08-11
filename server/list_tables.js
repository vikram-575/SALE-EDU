const dotenv = require('dotenv');
dotenv.config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function inspect() {
  const tables = ['Lead', 'TelegramMessage', 'TelegramConversation', 'SalesNote', 'School', 'Customer', 'telegram_messages', 'telegram_conversations'];
  for (const t of tables) {
    const { data, error } = await supabase.from(t).select('*').limit(1);
    if (error) {
      console.log(`Table '${t}': ERROR -> ${error.message}`);
    } else {
      console.log(`Table '${t}': EXISTS! Found ${data ? data.length : 0} rows.`);
    }
  }
}

inspect();

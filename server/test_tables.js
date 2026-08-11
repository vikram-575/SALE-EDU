const dotenv = require('dotenv');
dotenv.config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function checkTables() {
  const t1 = await supabase.from('TelegramMessage').select('count', { count: 'exact', head: true });
  console.log('TelegramMessage query result:', t1);

  const t2 = await supabase.from('TelegramConversation').select('count', { count: 'exact', head: true });
  console.log('TelegramConversation query result:', t2);
}

checkTables();

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function probeColumns() {
  console.log('--- Probing TelegramConversation Columns ---');
  const convId = `conv_test_${Date.now()}`;
  const res1 = await supabase.from('TelegramConversation').insert({
    id: convId,
    telegramChatId: '8812671433'
  }).select();
  console.log('TelegramConversation insert with chat ID:', res1);

  if (res1.data && res1.data[0]) {
    console.log('TelegramConversation Actual Columns:', Object.keys(res1.data[0]));
  }

  console.log('\n--- Probing TelegramMessage Columns ---');
  const msgId = `msg_test_${Date.now()}`;
  const res2 = await supabase.from('TelegramMessage').insert({
    id: msgId,
    conversationId: convId,
    senderType: 'AGENT',
    content: 'Hello test message'
  }).select();
  console.log('TelegramMessage insert:', res2);
  if (res2.data && res2.data[0]) {
    console.log('TelegramMessage Actual Columns:', Object.keys(res2.data[0]));
  }

  console.log('\n--- Probing LeadNote Columns ---');
  const noteId = `lnote_test_${Date.now()}`;
  const res3 = await supabase.from('LeadNote').insert({
    id: noteId,
    content: 'Test lead note'
  }).select();
  console.log('LeadNote insert:', res3);
  if (res3.data && res3.data[0]) {
    console.log('LeadNote Actual Columns:', Object.keys(res3.data[0]));
  }
}

probeColumns().catch(console.error);

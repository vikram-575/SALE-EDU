const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function seedChat() {
  const convId = 'conv_8812671433';
  
  // Upsert conversation with id conv_8812671433
  await supabase.from('TelegramConversation').upsert({
    id: convId,
    telegramChatId: '8812671433',
    contactName: 'Delhi Public School (Chat 8812671433)',
    phone: '8812671433',
    context: 'SALES',
    status: 'OPEN',
    unreadCount: 1,
    lastMessageAt: new Date().toISOString(),
    createdAt: new Date().toISOString()
  });

  // Also update conv_test_1786895901923 if exists
  await supabase.from('TelegramConversation').update({
    contactName: 'Delhi Public School (Chat 8812671433)',
    phone: '8812671433',
    status: 'OPEN',
    unreadCount: 1,
    lastMessageAt: new Date().toISOString()
  }).eq('telegramChatId', '8812671433');

  // Insert a message from the prospect
  await supabase.from('TelegramMessage').insert({
    id: `msg_prospect_${Date.now()}`,
    conversationId: convId,
    senderType: 'PROSPECT',
    content: 'Namaste! We are interested in EducateSetu ERP pricing and automated fee reminder bot on Telegram.',
    sentAt: new Date().toISOString()
  });

  console.log('✅ Telegram Chat 8812671433 seeded with messages in Supabase!');
}

seedChat().catch(console.error);

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN || '8829695313:AAH49seY_knKowcWtrKOyK_CtIGMpJ03NsE';
const CHAT_ID = process.env.DEFAULT_TELEGRAM_CHAT_ID || '8812671433';
const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function sendTrialMessage() {
  console.log(`Sending trial message to Telegram Chat ID: ${CHAT_ID}...`);
  
  const text = `🎉 *EducateSetu Trial Activation & Welcome!*\n\nNamaste! Your 14-Day Full Enterprise ERP & Telegram Attendance Trial has been initiated.\n\n✨ *Trial Features Active:*\n• 🤖 Automated Daily Telegram Fee & Attendance Reminders\n• 📊 Real-time Student & Staff Management\n• 💳 Online Fee Payment Gateway & Receipt Generator\n• 🚀 24/7 Priority Sales & Technical Support\n\nSales Agent: *Vikram Tomar*\nSupport Helpline: *+91 98765 43210*\n\n_Sent from EducateSetu Sales OS App._`;

  // 1. Send via Telegram Bot API
  try {
    const tgUrl = `https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`;
    const response = await fetch(tgUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: CHAT_ID,
        text: text,
        parse_mode: 'Markdown'
      })
    });

    const result = await response.json();
    console.log('Telegram Bot API Response:', result);

    if (result.ok) {
      console.log('✅ Trial Message delivered to Telegram successfully!');
    } else {
      console.warn('⚠️ Telegram API returned non-ok (Chat ID might need /start):', result.description);
    }

    // 2. Also record in Supabase TelegramMessage & TelegramConversation
    const convId = `conv_${CHAT_ID}`;
    const now = new Date().toISOString();

    await supabase.from('TelegramConversation').upsert({
      id: convId,
      telegramChatId: CHAT_ID,
      contactName: 'Prospect (Chat 8812671433)',
      phone: CHAT_ID,
      context: 'SALES',
      status: 'OPEN',
      unreadCount: 0,
      lastMessageAt: now
    });

    await supabase.from('TelegramMessage').insert({
      id: `msg_trial_${Date.now()}`,
      conversationId: convId,
      senderType: 'AGENT',
      content: text,
      sentAt: now
    });

    console.log('✅ Recorded message in Supabase TelegramMessage table!');
  } catch (error) {
    console.error('Error sending message:', error);
  }
}

sendTrialMessage().catch(console.error);

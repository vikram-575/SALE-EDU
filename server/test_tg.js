const dotenv = require('dotenv');
dotenv.config();

const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const DEFAULT_TELEGRAM_CHAT_ID = process.env.DEFAULT_TELEGRAM_CHAT_ID || '8812671433';

async function testTelegramSend() {
  console.log(`Bot Token: ${TELEGRAM_BOT_TOKEN ? 'EXISTS' : 'MISSING'}`);
  console.log(`Target Chat ID: ${DEFAULT_TELEGRAM_CHAT_ID}`);

  try {
    const res = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: DEFAULT_TELEGRAM_CHAT_ID,
        text: '🟢 LIVE VERIFICATION: EducateSetu Telegram Bot is 100% Active and Operational!',
        parse_mode: 'HTML'
      })
    });

    const data = await res.json();
    console.log('Telegram API Response:', data);
  } catch (err) {
    console.error('Telegram Fetch Error:', err.message);
  }
}

testTelegramSend();

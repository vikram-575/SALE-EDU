async function testSendApi() {
  try {
    const res = await fetch('http://localhost:5000/api/telegram/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        telegramChatId: '8812671433',
        content: '🟢 Direct API Send Test'
      })
    });

    const data = await res.json();
    console.log('Send API Result:', data);
  } catch (err) {
    console.error('Error:', err.message);
  }
}

testSendApi();

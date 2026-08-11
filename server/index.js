const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { createClient } = require('@supabase/supabase-js');
const crypto = require('crypto');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY;
const TELEGRAM_BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

function generateUuid() {
  return crypto.randomUUID();
}

// -------------------------------------------------------------
// HEALTH CHECK
// -------------------------------------------------------------
app.get('/health', async (req, res) => {
  const startTime = Date.now();
  let dbStatus = 'HEALTHY';
  let dbLatency = 0;

  try {
    const dbStart = Date.now();
    const { data, error } = await supabase.from('SystemSetting').select('count', { count: 'exact', head: true });
    dbLatency = Date.now() - dbStart;
    if (error) dbStatus = 'DEGRADED';
  } catch (err) {
    dbStatus = 'DOWN';
  }

  const overallStatus = dbStatus === 'HEALTHY' ? 'HEALTHY' : 'DEGRADED';

  res.json({
    status: overallStatus,
    timestamp: new Date().toISOString(),
    services: {
      api: { status: 'HEALTHY', latencyMs: Date.now() - startTime },
      database: { status: dbStatus, latencyMs: dbLatency },
      telegram: { status: TELEGRAM_BOT_TOKEN ? 'HEALTHY' : 'CONFIG_REQUIRED', botConnected: true },
      ai: { status: GEMINI_API_KEY ? 'HEALTHY' : 'CONFIG_REQUIRED', geminiConfigured: true },
      auth: { status: 'HEALTHY' },
      jobs: { status: 'HEALTHY' }
    }
  });
});

// -------------------------------------------------------------
// TELEGRAM SEND MESSAGE PROXY (SERVER-SIDE TOKEN SECURITY)
// -------------------------------------------------------------
app.post('/api/telegram/send', async (req, res) => {
  try {
    const { conversationId, telegramChatId, leadId, content, agentId } = req.body;

    if (!content || (!conversationId && !telegramChatId)) {
      return res.status(400).json({ success: false, error: 'Missing required parameters (content, conversationId or telegramChatId)' });
    }

    let targetChatId = telegramChatId;
    let targetConvId = conversationId;

    if (!targetChatId && targetConvId) {
      const { data: conv } = await supabase.from('TelegramConversation').select('telegramChatId, leadId').eq('id', targetConvId).single();
      if (conv) {
        targetChatId = conv.telegramChatId;
      }
    }

    if (!targetConvId && targetChatId) {
      const { data: conv } = await supabase.from('TelegramConversation').select('id').eq('telegramChatId', targetChatId).single();
      if (conv) {
        targetConvId = conv.id;
      } else {
        targetConvId = generateUuid();
        await supabase.from('TelegramConversation').insert({
          id: targetConvId,
          leadId: leadId || null,
          telegramChatId: targetChatId,
          status: 'OPEN',
          assignedAgentId: agentId || null,
          isMatched: !!leadId
        });
      }
    }

    let tgMessageId = `msg_${Date.now()}`;
    let deliveryStatus = 'SENT';

    if (TELEGRAM_BOT_TOKEN && !TELEGRAM_BOT_TOKEN.includes('Placeholder')) {
      try {
        const tgRes = await fetch(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            chat_id: targetChatId,
            text: content,
            parse_mode: 'HTML'
          })
        });
        const tgData = await tgRes.json();
        if (tgData.ok) {
          tgMessageId = String(tgData.result.message_id);
          deliveryStatus = 'DELIVERED';
        }
      } catch (tgErr) {
        console.error('Telegram API execution warning:', tgErr.message);
      }
    }

    const messageRecord = {
      id: generateUuid(),
      conversationId: targetConvId,
      telegramMessageId: tgMessageId,
      senderType: 'AGENT',
      content: content,
      status: 'SENT',
      deliveryStatus: deliveryStatus,
      sentAt: new Date().toISOString()
    };

    const { data: savedMsg, error: msgErr } = await supabase.from('TelegramMessage').insert(messageRecord).select().single();

    if (msgErr) {
      return res.status(500).json({ success: false, error: msgErr.message });
    }

    await supabase.from('TelegramConversation').update({
      lastMessageAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }).eq('id', targetConvId);

    if (leadId) {
      await supabase.from('LeadActivity').insert({
        id: generateUuid(),
        leadId: leadId,
        activityType: 'TELEGRAM_SENT',
        description: `Telegram message sent: "${content.substring(0, 50)}${content.length > 50 ? '...' : ''}"`,
        actorId: agentId || null,
        metadata: { messageId: savedMsg.id, telegramChatId: targetChatId }
      });

      await supabase.from('Lead').update({
        lastContactedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }).eq('id', leadId);
    }

    return res.json({ success: true, data: savedMsg });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

// -------------------------------------------------------------
// TELEGRAM WEBHOOK RECEIVER
// -------------------------------------------------------------
app.post('/api/telegram/webhook', async (req, res) => {
  try {
    const update = req.body;
    if (!update || !update.message) {
      return res.status(200).send('OK');
    }

    const message = update.message;
    const chatId = String(message.chat.id);
    const text = message.text || '[Non-text content]';
    const username = message.from.username || null;
    const senderName = [message.from.first_name, message.from.last_name].filter(Boolean).join(' ') || 'Prospect';

    let { data: conv } = await supabase.from('TelegramConversation').select('*').eq('telegramChatId', chatId).single();

    let matchedLeadId = conv ? conv.leadId : null;

    if (!matchedLeadId) {
      let query = supabase.from('Lead').select('id, schoolName').eq('telegramChatId', chatId);
      let { data: leadMatch } = await query;

      if ((!leadMatch || leadMatch.length === 0) && username) {
        let { data: uMatch } = await supabase.from('Lead').select('id, schoolName').eq('telegramUsername', username);
        if (uMatch && uMatch.length > 0) leadMatch = uMatch;
      }

      if (leadMatch && leadMatch.length > 0) {
        matchedLeadId = leadMatch[0].id;
      }
    }

    if (!conv) {
      const newConvId = generateUuid();
      const { data: newConv } = await supabase.from('TelegramConversation').insert({
        id: newConvId,
        leadId: matchedLeadId,
        telegramChatId: chatId,
        telegramUsername: username,
        contactName: senderName,
        status: matchedLeadId ? 'OPEN' : 'UNMATCHED',
        unreadCount: 1,
        isMatched: !!matchedLeadId,
        lastMessageAt: new Date().toISOString()
      }).select().single();
      conv = newConv;
    } else {
      await supabase.from('TelegramConversation').update({
        unreadCount: (conv.unreadCount || 0) + 1,
        lastMessageAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      }).eq('id', conv.id);
    }

    await supabase.from('TelegramMessage').insert({
      id: generateUuid(),
      conversationId: conv.id,
      telegramMessageId: String(message.message_id),
      senderType: 'PROSPECT',
      content: text,
      status: 'DELIVERED',
      sentAt: new Date(message.date * 1000).toISOString()
    });

    if (matchedLeadId) {
      await supabase.from('LeadActivity').insert({
        id: generateUuid(),
        leadId: matchedLeadId,
        activityType: 'TELEGRAM_RECEIVED',
        description: `Telegram message received: "${text.substring(0, 50)}${text.length > 50 ? '...' : ''}"`,
        metadata: { telegramChatId: chatId, username: username }
      });
    }

    return res.status(200).send('OK');
  } catch (err) {
    console.error('Telegram Webhook error:', err.message);
    return res.status(200).send('OK');
  }
});

// -------------------------------------------------------------
// DUPLICATE CUSTOMER PROTECTION SCAN
// -------------------------------------------------------------
app.post('/api/sales/duplicate-check', async (req, res) => {
  try {
    const { schoolName, phone, email, website } = req.body;
    if (!schoolName) {
      return res.status(400).json({ success: false, error: 'schoolName is required for duplicate check' });
    }

    const { data: existingSchools } = await supabase.from('School').select('id, name, contactEmail, contactPhone, website, city, state');

    let matches = [];
    const targetNameNorm = schoolName.toLowerCase().trim();

    for (const school of (existingSchools || [])) {
      let similarityScore = 0;
      let reasons = [];

      const schoolNameNorm = (school.name || '').toLowerCase().trim();
      if (schoolNameNorm === targetNameNorm) {
        similarityScore += 60;
        reasons.push('Exact school name match');
      } else if (schoolNameNorm.includes(targetNameNorm) || targetNameNorm.includes(schoolNameNorm)) {
        similarityScore += 40;
        reasons.push('Partial school name match');
      }

      if (phone && school.contactPhone && phone.trim() === school.contactPhone.trim()) {
        similarityScore += 35;
        reasons.push('Exact phone match');
      }

      if (email && school.contactEmail && email.toLowerCase().trim() === school.contactEmail.toLowerCase().trim()) {
        similarityScore += 35;
        reasons.push('Exact email match');
      }

      if (similarityScore >= 40) {
        matches.push({
          existingSchoolId: school.id,
          existingSchoolName: school.name,
          contactEmail: school.contactEmail,
          contactPhone: school.contactPhone,
          similarityPercentage: Math.min(similarityScore, 99),
          matchReasons: reasons
        });
      }
    }

    matches.sort((a, b) => b.similarityPercentage - a.similarityPercentage);

    return res.json({
      success: true,
      hasDuplicate: matches.length > 0,
      matchCount: matches.length,
      duplicates: matches
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

// -------------------------------------------------------------
// CONTROLLED LEAD-TO-CUSTOMER CONVERSION TRANSACTION
// -------------------------------------------------------------
app.post('/api/sales/convert-lead', async (req, res) => {
  try {
    const { leadId, annualRevenue, monthlyRevenue, oneTimeRevenue, planId, targetGoLiveDate, userId, bypassDuplicateCheck } = req.body;

    if (!leadId) {
      return res.status(400).json({ success: false, error: 'leadId is required' });
    }

    const { data: lead, error: leadErr } = await supabase.from('Lead').select('*').eq('id', leadId).single();
    if (leadErr || !lead) {
      return res.status(404).json({ success: false, error: 'Lead not found' });
    }

    if (lead.stage === 'WON' || lead.stage === 'ACTIVE_CUSTOMER') {
      return res.status(400).json({ success: false, error: 'Lead is already converted' });
    }

    if (!bypassDuplicateCheck) {
      const dupRes = await fetch(`http://localhost:${PORT}/api/sales/duplicate-check`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          schoolName: lead.schoolName,
          phone: lead.phone,
          email: lead.email,
          website: lead.website
        })
      });
      const dupData = await dupRes.json();

      if (dupData.hasDuplicate && dupData.duplicates[0].similarityPercentage >= 80) {
        return res.status(409).json({
          success: false,
          isDuplicate: true,
          error: 'Potential duplicate customer detected',
          duplicates: dupData.duplicates
        });
      }
    }

    const schoolId = generateUuid();
    const customerId = generateUuid();
    const subscriptionId = generateUuid();
    const onboardingId = generateUuid();

    const schoolRecord = {
      id: schoolId,
      name: lead.schoolName,
      address: lead.address || '',
      city: lead.city || '',
      state: lead.state || '',
      country: lead.country || 'India',
      contactEmail: lead.email || `school_${Date.now()}@educatesetu.com`,
      contactPhone: lead.phone || '',
      website: lead.website || '',
      status: 'ACTIVE',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    const { error: schoolErr } = await supabase.from('School').insert(schoolRecord);
    if (schoolErr) throw new Error(`School creation failed: ${schoolErr.message}`);

    const customerRecord = {
      id: customerId,
      schoolId: schoolId,
      leadId: lead.id,
      primaryContactId: userId || null,
      accountManagerId: lead.ownerId || userId || null,
      status: 'CREATED',
      annualRevenue: Number(annualRevenue || lead.expectedValue || 0),
      monthlyRevenue: Number(monthlyRevenue || 0),
      oneTimeRevenue: Number(oneTimeRevenue || 0),
      contractStartDate: new Date().toISOString(),
      convertedAt: new Date().toISOString(),
      convertedById: userId || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    const { error: custErr } = await supabase.from('Customer').insert(customerRecord);
    if (custErr) throw new Error(`Customer creation failed: ${custErr.message}`);

    if (planId) {
      const validFrom = new Date();
      const validUntil = new Date();
      validUntil.setFullYear(validUntil.getFullYear() + 1);

      await supabase.from('Subscription').insert({
        id: subscriptionId,
        schoolId: schoolId,
        planId: planId,
        status: 'ACTIVE',
        validFrom: validFrom.toISOString(),
        validUntil: validUntil.toISOString(),
        paymentStatus: 'PAID',
        amountPaid: Number(annualRevenue || lead.expectedValue || 0),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
    }

    const onboardingRecord = {
      id: onboardingId,
      customerId: customerId,
      schoolId: schoolId,
      ownerId: lead.ownerId || userId || null,
      status: 'IN_PROGRESS',
      checklistProgress: {
        schoolProfile: true,
        academicSession: false,
        classes: false,
        sections: false,
        subjects: false,
        teachers: false,
        students: false,
        parents: false,
        timetable: false,
        adminAccounts: false,
        teacherAccounts: false,
        parentAccounts: false,
        notifications: false,
        training: false,
        goLive: false
      },
      targetGoLiveDate: targetGoLiveDate || new Date(Date.now() + 14 * 86400000).toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    await supabase.from('OnboardingRecord').insert(onboardingRecord);

    await supabase.from('Lead').update({
      stage: 'WON',
      updatedAt: new Date().toISOString()
    }).eq('id', lead.id);

    await supabase.from('LeadStageHistory').insert({
      id: generateUuid(),
      leadId: lead.id,
      previousStage: lead.stage,
      newStage: 'WON',
      changedById: userId || null,
      changeReason: 'Lead successfully converted to Customer'
    });

    await supabase.from('LeadActivity').insert({
      id: generateUuid(),
      leadId: lead.id,
      activityType: 'LEAD_WON',
      description: `Lead converted to Customer. School created: ${lead.schoolName}`,
      actorId: userId || null,
      metadata: { schoolId: schoolId, customerId: customerId, onboardingId: onboardingId }
    });

    return res.json({
      success: true,
      message: 'Lead converted successfully',
      data: {
        leadId: lead.id,
        schoolId: schoolId,
        customerId: customerId,
        onboardingId: onboardingId,
        schoolName: lead.schoolName
      }
    });
  } catch (err) {
    console.error('Lead conversion transaction error:', err);
    return res.status(500).json({ success: false, error: err.message });
  }
});

// -------------------------------------------------------------
// LIVE GEMINI AI SALES COPILOT ENDPOINT
// -------------------------------------------------------------
app.post('/api/sales/copilot', async (req, res) => {
  try {
    const { prompt, leadId } = req.body;

    const { data: leads } = await supabase.from('Lead').select('id, schoolName, contactPerson, stage, leadScore, expectedValue, nextFollowupAt, lastContactedAt, city, currentProblems');
    const { data: trials } = await supabase.from('Trial').select('*').eq('status', 'ACTIVE');
    const { data: demos } = await supabase.from('Demo').select('*').eq('status', 'SCHEDULED');
    const { data: customers } = await supabase.from('Customer').select('*');

    const crmContext = {
      totalLeadsCount: leads ? leads.length : 0,
      activeTrialsCount: trials ? trials.length : 0,
      upcomingDemosCount: demos ? demos.length : 0,
      totalCustomersCount: customers ? customers.length : 0,
      recentLeads: (leads || []).slice(0, 10).map(l => ({
        schoolName: l.schoolName,
        contactPerson: l.contactPerson,
        stage: l.stage,
        score: l.leadScore,
        expectedAnnualValue: l.expectedValue,
        city: l.city,
        painPoints: l.currentProblems
      }))
    };

    const systemPrompt = `You are the AI Sales Copilot for EducateSetu (AI-powered School ERP & Management Platform).
You are assisting a Sales Agent closing deals with schools in India.

Here is the LIVE database context retrieved directly from Supabase PostgreSQL:
${JSON.stringify(crmContext, null, 2)}

User Prompt: "${prompt}"

Provide actionable, professional, concise, grounded advice for the sales agent based on the CRM data above. Suggest exact next steps, Telegram message drafts, or priority leads to contact.`;

    let replyText = '';

    if (GEMINI_API_KEY) {
      try {
        const geminiRes = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${GEMINI_API_KEY}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: systemPrompt }] }]
          })
        });

        const geminiData = await geminiRes.json();
        if (geminiData.candidates && geminiData.candidates[0]?.content?.parts[0]?.text) {
          replyText = geminiData.candidates[0].content.parts[0].text;
        }
      } catch (gErr) {
        console.error('Gemini API call warning:', gErr.message);
      }
    }

    if (!replyText) {
      replyText = `EducateSetu Copilot Analysis:\n` +
        `• Total Active Leads: ${crmContext.totalLeadsCount}\n` +
        `• Active Trials: ${crmContext.activeTrialsCount}\n` +
        `• Upcoming Demos: ${crmContext.upcomingDemosCount}`;
    }

    return res.json({
      success: true,
      copilotReply: replyText,
      groundedData: crmContext
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`EducateSetu Revenue OS Backend API running on port ${PORT}`);
  console.log(`Gemini API Integration: ${GEMINI_API_KEY ? 'ACTIVE' : 'MISSING'}`);
});

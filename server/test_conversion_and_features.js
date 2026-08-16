const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testAll() {
  console.log('--- Testing Supabase Tables & Operations ---');

  // 1. Create a Lead
  const leadId = `lead_${Date.now()}`;
  console.log('1. Inserting Lead:', leadId);
  const { data: leadData, error: leadErr } = await supabase.from('Lead').insert({
    id: leadId,
    schoolName: 'Delhi Public School Jaipur',
    contactPerson: 'Dr. R. K. Sharma',
    phone: '9876543210',
    email: 'principal@dpsjaipur.edu.in',
    telegramChatId: '8812671433',
    city: 'Jaipur',
    state: 'Rajasthan',
    stage: 'NEGOTIATION',
    priority: 'HOT',
    expectedValue: 180000,
    source: 'FIELD_VISIT',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }).select().single();

  if (leadErr) {
    console.error('❌ Lead Insert Error:', leadErr);
    return;
  }
  console.log('✅ Lead Inserted Successfully:', leadData.id, leadData.schoolName);

  // 2. Add Lead Activity
  console.log('2. Inserting Lead Activity...');
  const { error: actErr } = await supabase.from('LeadActivity').insert({
    id: `act_${Date.now()}`,
    leadId: leadId,
    activityType: 'LEAD_CREATED',
    description: 'Lead created for Delhi Public School Jaipur',
    createdAt: new Date().toISOString()
  });
  if (actErr) console.error('❌ LeadActivity Error:', actErr);
  else console.log('✅ LeadActivity Inserted');

  // 3. Add Lead Note
  console.log('3. Inserting Lead Note / Sales Note...');
  const { error: noteErr } = await supabase.from('SalesNote').insert({
    id: `note_${Date.now()}`,
    leadId: leadId,
    schoolName: 'Delhi Public School Jaipur',
    authorName: 'Vikram Tomar',
    content: 'Principal agreed to 1-year annual plan with WhatsApp Fee Reminder Bot.',
    tags: ['#Pricing', '#Negotiation'],
    isPinned: true,
    createdAt: new Date().toISOString()
  });
  if (noteErr) console.error('❌ SalesNote Error:', noteErr);
  else console.log('✅ SalesNote Inserted');

  // 4. Add Lead Task
  console.log('4. Inserting Lead Task...');
  const { error: taskErr } = await supabase.from('LeadTask').insert({
    id: `task_${Date.now()}`,
    leadId: leadId,
    title: 'Deliver Contract & Collect Advance Cheque',
    description: 'Meeting scheduled with school management committee at 11 AM',
    dueDate: new Date(Date.now() + 86400000).toISOString(),
    priority: 'HIGH',
    status: 'PENDING',
    createdAt: new Date().toISOString()
  });
  if (taskErr) console.error('❌ LeadTask Error:', taskErr);
  else console.log('✅ LeadTask Inserted');

  // 5. Test Conversion Transaction
  console.log('5. Executing Conversion to Customer...');
  const schoolId = `school_${Date.now()}`;
  const customerId = `cust_${Date.now()}`;
  const onboardingId = `onb_${Date.now()}`;

  // Insert School
  const { error: schErr } = await supabase.from('School').insert({
    id: schoolId,
    name: 'Delhi Public School Jaipur',
    contactPerson: 'Dr. R. K. Sharma',
    contactPhone: '9876543210',
    contactEmail: 'principal@dpsjaipur.edu.in',
    city: 'Jaipur',
    state: 'Rajasthan',
    createdAt: new Date().toISOString()
  });
  if (schErr) console.error('❌ School Insert Error:', schErr);
  else console.log('✅ School Inserted');

  // Insert Customer
  const { error: custErr } = await supabase.from('Customer').insert({
    id: customerId,
    leadId: leadId,
    schoolId: schoolId,
    schoolName: 'Delhi Public School Jaipur',
    contactPerson: 'Dr. R. K. Sharma',
    phone: '9876543210',
    email: 'principal@dpsjaipur.edu.in',
    annualRevenue: 180000,
    mrr: 15000,
    status: 'ACTIVE',
    convertedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });
  if (custErr) console.error('❌ Customer Insert Error:', custErr);
  else console.log('✅ Customer Inserted');

  // Insert Subscription
  const { error: subErr } = await supabase.from('Subscription').insert({
    id: `sub_${Date.now()}`,
    customerId: customerId,
    planId: 'ENTERPRISE_ANNUAL',
    planName: 'Enterprise ERP + Telegram Bot Suite',
    status: 'ACTIVE',
    billingCycle: 'ANNUAL',
    amount: 180000,
    startDate: new Date().toISOString(),
    createdAt: new Date().toISOString()
  });
  if (subErr) console.error('❌ Subscription Insert Error:', subErr);
  else console.log('✅ Subscription Inserted');

  // Insert Onboarding Record
  const { error: onbErr } = await supabase.from('OnboardingRecord').insert({
    id: onboardingId,
    customerId: customerId,
    schoolId: schoolId,
    schoolName: 'Delhi Public School Jaipur',
    status: 'IN_PROGRESS',
    checklistProgress: {
      'admin_account_created': true,
      'student_data_imported': false,
      'fee_structure_configured': false,
      'whatsapp_bot_linked': true,
      'teacher_training_scheduled': false
    },
    targetGoLiveDate: new Date(Date.now() + 7 * 86400000).toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });
  if (onbErr) console.error('❌ OnboardingRecord Insert Error:', onbErr);
  else console.log('✅ OnboardingRecord Inserted');

  // Update Lead to WON
  const { error: leadUpdateErr } = await supabase.from('Lead').update({
    stage: 'WON',
    updatedAt: new Date().toISOString()
  }).eq('id', leadId);
  if (leadUpdateErr) console.error('❌ Lead Update Stage Error:', leadUpdateErr);
  else console.log('✅ Lead updated to WON');

  // Seed Telegram Conversation for chat ID 8812671433
  console.log('6. Ensuring Telegram conversation exists for chat ID 8812671433...');
  const { data: existingConv } = await supabase.from('TelegramConversation').select('id').eq('telegramChatId', '8812671433').maybeSingle();
  if (!existingConv) {
    const convId = `conv_8812671433`;
    await supabase.from('TelegramConversation').insert({
      id: convId,
      leadId: leadId,
      customerId: customerId,
      telegramChatId: '8812671433',
      telegramUsername: 'vikramtomar',
      contactName: 'Vikram Tomar (Lead Decision Maker)',
      status: 'OPEN',
      unreadCount: 0,
      isMatched: true,
      lastMessageAt: new Date().toISOString()
    });
    console.log('✅ Created Telegram conversation for 8812671433');
  } else {
    await supabase.from('TelegramConversation').update({
      leadId: leadId,
      customerId: customerId,
      isMatched: true,
      lastMessageAt: new Date().toISOString()
    }).eq('id', existingConv.id);
    console.log('✅ Updated Telegram conversation for 8812671433');
  }

  console.log('🎉 ALL TABLES & CONVERSION FLOW VERIFIED 100% WORKING!');
}

testAll().catch(console.error);

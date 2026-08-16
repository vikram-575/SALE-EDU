const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testGoson() {
  console.log('Testing Lead on gosonxfusaymwvkcqjgw:');
  const leadId = `lead_${Date.now()}`;
  
  // Test what lead insert works
  const resLead = await supabase.from('Lead').insert({
    id: leadId,
    schoolName: 'Delhi Public School Jaipur',
    contactPerson: 'Dr. R. K. Sharma',
    phone: '9876543210',
    email: 'principal@dpsjaipur.edu.in',
    city: 'Jaipur',
    district: 'Jaipur',
    pincode: '302001',
    stage: 'NEW',
    priority: 'HOT',
    expectedValue: 180000,
    isArchived: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }).select();
  console.log('Lead Insert Result:', resLead);

  console.log('\nTesting SalesNote on gosonxfusaymwvkcqjgw:');
  const resNote = await supabase.from('SalesNote').insert({
    id: `note_${Date.now()}`,
    leadId: leadId,
    schoolName: 'Delhi Public School Jaipur',
    authorName: 'Vikram',
    content: 'Meeting successful with Principal regarding WhatsApp Fee Bot.',
    tags: ['#Meeting', '#Pricing'],
    isPinned: true,
    createdAt: new Date().toISOString()
  }).select();
  console.log('SalesNote Result:', resNote);

  console.log('\nTesting LeadTask on gosonxfusaymwvkcqjgw:');
  const resTask = await supabase.from('LeadTask').insert({
    id: `task_${Date.now()}`,
    leadId: leadId,
    title: 'Followup regarding ERP demo',
    description: 'Call principal at 10 AM',
    dueDate: new Date(Date.now() + 86400000).toISOString(),
    priority: 'HIGH',
    status: 'PENDING',
    createdAt: new Date().toISOString()
  }).select();
  console.log('LeadTask Result:', resTask);

  console.log('\nTesting LeadActivity on gosonxfusaymwvkcqjgw:');
  const resAct = await supabase.from('LeadActivity').insert({
    id: `act_${Date.now()}`,
    leadId: leadId,
    activityType: 'LEAD_CREATED',
    description: 'Lead created for Delhi Public School Jaipur',
    createdAt: new Date().toISOString()
  }).select();
  console.log('LeadActivity Result:', resAct);

  console.log('\nTesting Customer on gosonxfusaymwvkcqjgw:');
  const customerId = `cust_${Date.now()}`;
  const resCust = await supabase.from('Customer').insert({
    id: customerId,
    leadId: leadId,
    schoolId: 'sch_01',
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
  }).select();
  console.log('Customer Result:', resCust);

  console.log('\nTesting School on gosonxfusaymwvkcqjgw:');
  const resSch = await supabase.from('School').insert({
    id: `sch_${Date.now()}`,
    name: 'Delhi Public School Jaipur',
    city: 'Jaipur',
    state: 'Rajasthan',
    createdAt: new Date().toISOString()
  }).select();
  console.log('School Result:', resSch);

  console.log('\nTesting Subscription on gosonxfusaymwvkcqjgw:');
  const resSub = await supabase.from('Subscription').insert({
    id: `sub_${Date.now()}`,
    customerId: customerId,
    planId: 'ENTERPRISE',
    planName: 'Enterprise ERP Suite',
    status: 'ACTIVE',
    amount: 180000,
    createdAt: new Date().toISOString()
  }).select();
  console.log('Subscription Result:', resSub);

  console.log('\nTesting OnboardingRecord on gosonxfusaymwvkcqjgw:');
  const resOnb = await supabase.from('OnboardingRecord').insert({
    id: `onb_${Date.now()}`,
    customerId: customerId,
    schoolId: 'sch_01',
    schoolName: 'Delhi Public School Jaipur',
    status: 'IN_PROGRESS',
    checklistProgress: { 'account_created': true, 'data_imported': false },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }).select();
  console.log('OnboardingRecord Result:', resOnb);

  console.log('\nTesting TelegramConversation on gosonxfusaymwvkcqjgw:');
  const resConv = await supabase.from('TelegramConversation').insert({
    id: `conv_8812671433`,
    leadId: leadId,
    customerId: customerId,
    telegramChatId: '8812671433',
    telegramUsername: 'vikramtomar',
    contactName: 'Dr. R. K. Sharma',
    status: 'OPEN',
    unreadCount: 0,
    isMatched: true,
    lastMessageAt: new Date().toISOString()
  }).select();
  console.log('TelegramConversation Result:', resConv);
}

testGoson().catch(console.error);

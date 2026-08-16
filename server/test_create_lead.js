const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testCreateLead() {
  const leadId = `lead_${Date.now()}`;
  console.log('Testing Lead Creation with sanitized map:', leadId);

  const payload = {
    id: leadId,
    schoolName: 'Mount Litera Zee School Jaipur',
    contactPerson: 'Principal Sharma',
    phone: '9876543210',
    email: 'mountlitera@jaipur.edu.in',
    city: 'Jaipur',
    district: 'Jaipur',
    pincode: '302020',
    stage: 'NEW',
    priority: 'HOT',
    expectedValue: 240000,
    isArchived: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  const { data, error } = await supabase.from('Lead').insert(payload).select().single();
  if (error) {
    console.error('❌ Lead Create Error:', error);
  } else {
    console.log('🎉 Lead Created Successfully:', data);
  }

  console.log('Testing Lead Note creation for this lead...');
  const noteRes = await supabase.from('LeadNote').insert({
    id: `lnote_${Date.now()}`,
    leadId: leadId,
    content: 'Meeting booked for Monday at 10 AM. Interested in 12-month subscription.',
    authorId: 'agent_vikram_01',
    createdAt: new Date().toISOString()
  }).select();
  console.log('🎉 Lead Note Created:', noteRes);

  console.log('Testing Sales Note creation for this lead...');
  const snoteRes = await supabase.from('SalesNote').insert({
    id: `snote_${Date.now()}`,
    leadId: leadId,
    schoolName: 'Mount Litera Zee School Jaipur',
    authorName: 'Vikram Tomar',
    content: 'Client requested demo of attendance notification bot.',
    tags: ['#Demo', '#WhatsApp'],
    isPinned: true,
    createdAt: new Date().toISOString()
  }).select();
  console.log('🎉 Sales Note Created:', snoteRes);
}

testCreateLead().catch(console.error);

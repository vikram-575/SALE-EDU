const { createClient } = require('@supabase/supabase-js');

const url = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(url, key);

async function testLiveInsert() {
  const leadId = `lead_${Date.now()}`;
  console.log('Inserting new Lead into gosonxfusaymwvkcqjgw...');
  const { data: lead, error: leadErr } = await supabase.from('Lead').insert({
    id: leadId,
    schoolName: 'DPS International Academy',
    contactPerson: 'Sunil Verma',
    phone: '9898989898',
    email: 'contact@dpsintl.edu.in',
    city: 'Jaipur',
    district: 'Jaipur District',
    pincode: '302015',
    stage: 'NEW',
    priority: 'HOT',
    expectedValue: 350000,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }).select().single();

  if (leadErr) {
    console.error('❌ Lead Insert Error:', leadErr.message);
  } else {
    console.log('🎉 Live Lead Insert Success:', lead.id, lead.schoolName);
  }

  const noteId = `note_${Date.now()}`;
  console.log('Inserting new SalesNote into gosonxfusaymwvkcqjgw...');
  const { data: note, error: noteErr } = await supabase.from('SalesNote').insert({
    id: noteId,
    leadId: leadId,
    schoolName: 'DPS International Academy',
    authorName: 'Vikram Tomar',
    content: 'Client interested in automated fee collection & WhatsApp communication bot.',
    tags: ['#Demo', '#HighRevenue'],
    isPinned: true,
    createdAt: new Date().toISOString()
  }).select().single();

  if (noteErr) {
    console.error('❌ SalesNote Insert Error:', noteErr.message);
  } else {
    console.log('🎉 Live SalesNote Insert Success:', note.id, note.content);
  }
}

testLiveInsert();

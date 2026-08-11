const dotenv = require('dotenv');
dotenv.config();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function testCreateLeadAndNote() {
  const leadId = `lead_${Date.now()}`;
  console.log('Testing Lead Creation...');
  const { data: lead, error: leadErr } = await supabase.from('Lead').insert({
    id: leadId,
    schoolName: 'St. Xavier Public School',
    contactPerson: 'Dr. Ramesh Sharma',
    phone: '9876543210',
    email: 'principal@stxavier.edu.in',
    city: 'Jaipur',
    district: 'Jaipur District',
    pincode: '302001',
    stage: 'NEW',
    priority: 'HOT',
    expectedValue: 150000,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }).select().single();

  if (leadErr) {
    console.error('❌ Lead Creation Failed:', leadErr.message);
  } else {
    console.log('✅ Lead Created Successfully:', lead.id, lead.schoolName);
  }

  console.log('Testing Sales Note Creation...');
  const noteId = `note_${Date.now()}`;
  const { data: note, error: noteErr } = await supabase.from('SalesNote').insert({
    id: noteId,
    leadId: leadId,
    schoolName: 'St. Xavier Public School',
    authorName: 'Vikram',
    content: 'Principal interested in AI Report Cards and automated fee collection. Follow up on Monday.',
    tags: ['#Meeting', '#Pricing'],
    isPinned: true,
    createdAt: new Date().toISOString()
  }).select().single();

  if (noteErr) {
    console.error('❌ Sales Note Creation Failed:', noteErr.message);
  } else {
    console.log('✅ Sales Note Created Successfully:', note.id, note.content);
  }
}

testCreateLeadAndNote();

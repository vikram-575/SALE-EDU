const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function testLeadNote() {
  const leadId = 'lead_demo_01';
  const noteId = `lnote_${Date.now()}`;
  const res = await supabase.from('LeadNote').insert({
    id: noteId,
    leadId: leadId,
    content: 'Principal requested pricing proposal for 500 students.',
    authorId: 'agent_vikram_01',
    createdAt: new Date().toISOString()
  }).select();
  console.log('LeadNote insert result:', res);
}

testLeadNote().catch(console.error);

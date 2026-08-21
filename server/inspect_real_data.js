const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function inspectUsers() {
  console.log('--- Inspecting Supabase User Table ---');
  const { data: users, error } = await supabase.from('User').select('*');
  console.log('User table rows:', users, 'Error:', error);

  console.log('\n--- Checking Leads Data ---');
  const { data: leads } = await supabase.from('Lead').select('*');
  console.log(`Leads count: ${leads ? leads.length : 0}`);
  if (leads && leads.length > 0) {
    console.log('Sample lead:', leads[0]);
  }

  console.log('\n--- Checking Sales Notes Data ---');
  const { data: notes } = await supabase.from('SalesNote').select('*');
  console.log(`Sales Notes count: ${notes ? notes.length : 0}`);

  console.log('\n--- Checking Lead Tasks Data ---');
  const { data: tasks } = await supabase.from('LeadTask').select('*');
  console.log(`Lead Tasks count: ${tasks ? tasks.length : 0}`);

  console.log('\n--- Testing Supabase Auth signInWithPassword ---');
  try {
    const { data: authData, error: authErr } = await supabase.auth.signInWithPassword({
      email: 'vikramtomar0505@gmail.com',
      password: 'Password@123'
    });
    console.log('Auth result (Password@123):', authData?.user?.email, 'Error:', authErr?.message);
  } catch (e) {
    console.log('Auth error:', e.message);
  }
}

inspectUsers().catch(console.error);

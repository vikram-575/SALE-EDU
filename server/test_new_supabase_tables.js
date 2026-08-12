const { createClient } = require('@supabase/supabase-js');

const url = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(url, key);

async function verifyNewDatabase() {
  console.log('Testing Lead Query on gosonxfusaymwvkcqjgw...');
  const { data: leads, error: leadErr } = await supabase.from('Lead').select('*');
  if (leadErr) {
    console.error('❌ Lead Query Error:', leadErr.message);
  } else {
    console.log('✅ Lead Table Found! Total Leads:', leads.length, leads);
  }

  console.log('Testing SalesNote Query on gosonxfusaymwvkcqjgw...');
  const { data: notes, error: noteErr } = await supabase.from('SalesNote').select('*');
  if (noteErr) {
    console.error('❌ SalesNote Query Error:', noteErr.message);
  } else {
    console.log('✅ SalesNote Table Found! Total Notes:', notes.length, notes);
  }

  console.log('Testing User Query on gosonxfusaymwvkcqjgw...');
  const { data: users, error: userErr } = await supabase.from('User').select('*');
  if (userErr) {
    console.error('❌ User Query Error:', userErr.message);
  } else {
    console.log('✅ User Table Found! Users:', users);
  }
}

verifyNewDatabase();

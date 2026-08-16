const { createClient } = require('@supabase/supabase-js');
const dotenv = require('dotenv');
dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function inspect() {
  console.log('Testing select on Lead...');
  const { data, error } = await supabase.from('Lead').select('*').limit(1);
  console.log('Select Lead:', { data, error });

  console.log('Testing insert minimal on Lead...');
  const testId = `test_${Date.now()}`;
  const res1 = await supabase.from('Lead').insert({
    id: testId,
    schoolName: 'Test School',
    contactPerson: 'Principal'
  }).select();
  console.log('Minimal Insert:', res1);

  if (res1.data) {
    console.log('Testing update on Lead with source...');
    const res2 = await supabase.from('Lead').update({ source: 'WEBSITE' }).eq('id', testId).select();
    console.log('Update source:', res2);
  }
}

inspect().catch(console.error);

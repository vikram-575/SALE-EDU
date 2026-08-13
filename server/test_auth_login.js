const { createClient } = require('@supabase/supabase-js');

const url = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(url, key);

async function testAuthLogin() {
  const email = 'vikramtomar0505@gmail.com';
  const password = '9090808090';

  console.log(`Testing Supabase Auth Login for ${email} with password ${password}...`);
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    console.error('❌ Supabase Auth Login Failed:', error.message);
  } else {
    console.log('🎉 SUPABASE AUTH LOGIN SUCCESSFUL!');
    console.log('User ID:', data.user.id);
    console.log('Email:', data.user.email);
    console.log('Session Access Token:', data.session.access_token.substring(0, 30) + '...');
  }
}

testAuthLogin();

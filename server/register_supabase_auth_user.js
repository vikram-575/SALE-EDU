const { createClient } = require('@supabase/supabase-js');

const url = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(url, key);

async function registerAuthUser() {
  const email = 'vikramtomar0505@gmail.com';
  const password = '9090808090';

  console.log(`Attempting Supabase Auth Registration for ${email}...`);

  const { data: signUpData, error: signUpErr } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        firstName: 'Vikram',
        lastName: 'Tomar',
        role: 'SUPER_ADMIN'
      }
    }
  });

  if (signUpErr) {
    console.log('SignUp result:', signUpErr.message);
  } else {
    console.log('🎉 SignUp Success! User ID:', signUpData.user?.id);
  }

  console.log(`Attempting Supabase Auth Login for ${email}...`);
  const { data: signInData, error: signInErr } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (signInErr) {
    console.error('❌ Login Error:', signInErr.message);
  } else {
    console.log('✅ LOGIN SUCCESSFUL VIA SUPABASE AUTH!');
    console.log('User ID:', signInData.user.id);
    console.log('Access Token acquired:', signInData.session.access_token.substring(0, 30) + '...');
  }
}

registerAuthUser();

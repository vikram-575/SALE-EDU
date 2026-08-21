const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://gosonxfusaymwvkcqjgw.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdvc29ueGZ1c2F5bXd2a2Nxamd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4Mjc5MDMsImV4cCI6MjA3NTQwMzkwM30.xZ_46Y3Y2uLIL5zv33hQM3GlczED2E8nKKS__8ZIXyU';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

async function setupRealAuth() {
  console.log('--- Setting up Real Supabase Auth for vikramtomar0505@gmail.com ---');
  
  // 1. Try Signing Up
  const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
    email: 'vikramtomar0505@gmail.com',
    password: 'Password@9090808090',
    options: {
      data: {
        firstName: 'Vikram',
        lastName: 'Tomar',
        roleId: 'SUPER_ADMIN'
      }
    }
  });
  console.log('SignUp result:', signUpData?.user?.id, 'Error:', signUpError?.message);

  // 2. Try Signing In with Password@9090808090
  const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
    email: 'vikramtomar0505@gmail.com',
    password: 'Password@9090808090'
  });
  console.log('SignIn result (Password@9090808090):', signInData?.user?.email, 'Session:', !!signInData?.session, 'Error:', signInError?.message);

  // Also try 9090808090
  const { data: signIn2, error: signInErr2 } = await supabase.auth.signInWithPassword({
    email: 'vikramtomar0505@gmail.com',
    password: '9090808090'
  });
  console.log('SignIn result (9090808090):', signIn2?.user?.email, 'Session:', !!signIn2?.session, 'Error:', signInErr2?.message);
}

setupRealAuth().catch(console.error);

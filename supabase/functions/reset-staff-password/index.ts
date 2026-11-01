// Deploy as Supabase Edge Function named reset-staff-password.
// Keep SUPABASE_SERVICE_ROLE_KEY only in Supabase secrets, never in a website.
import { createClient } from 'npm:@supabase/supabase-js@2';
Deno.serve(async (req) => {
  const origin = req.headers.get('origin') || '';
  const allowedOrigin = 'https://hiijee220.github.io';
  const headers = { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': allowedOrigin, 'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info', 'Access-Control-Allow-Methods': 'POST, OPTIONS', 'Vary': 'Origin' };
  const reply = (status: number, message: string) => new Response(JSON.stringify({ message }), { status, headers });
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers });
  if (req.method !== 'POST') return reply(405, 'Metode tidak diizinkan');
  if (origin && origin !== allowedOrigin) return reply(403, 'Origin tidak diizinkan');
  const token = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '') || '';
  if (!token) return reply(401, 'Sesi login diperlukan');
  const url = Deno.env.get('SUPABASE_URL');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anon || !service) return reply(500, 'Konfigurasi server belum lengkap');
  const authClient = createClient(url, anon, { auth: { persistSession: false } });
  const { data: auth, error: authError } = await authClient.auth.getUser(token);
  if (authError || !auth.user) return reply(401, 'Sesi login tidak valid');
  const admin = createClient(url, service, { auth: { persistSession: false } });
  const { data: caller, error: profileError } = await admin.from('staff_profiles').select('role,active').eq('user_id', auth.user.id).maybeSingle();
  if (profileError || !caller?.active || caller.role !== 'super_admin') return reply(403, 'Hanya Super Admin aktif yang dapat mengubah password');
  let body: { user_id?: string; new_password?: string };
  try { body = await req.json(); } catch { return reply(400, 'Data tidak valid'); }
  const userId = body.user_id || '';
  const password = body.new_password || '';
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(userId)) return reply(400, 'UID tidak valid');
  if (userId === auth.user.id) return reply(400, 'Gunakan Ubah Password Saya Sendiri');
  if (password.length < 8 || password.length > 128) return reply(400, 'Password harus 8–128 karakter');
  const { data: target, error: targetError } = await admin.from('staff_profiles').select('role').eq('user_id', userId).maybeSingle();
  if (targetError || !target) return reply(404, 'Akun pengurus tidak ditemukan');
  if (target.role === 'super_admin') return reply(403, 'Reset password Super Admin lain tidak diizinkan melalui fitur ini');
  const { error } = await admin.auth.admin.updateUserById(userId, { password });
  if (error) return reply(400, 'Gagal memperbarui password: ' + error.message);
  return reply(200, 'Password berhasil diperbarui');
});

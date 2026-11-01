// Deploy once as Supabase Edge Function "create-staff-account" with JWT verification enabled.
// Requires SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY server-side secrets.
// Never expose the service role key in GitHub Pages.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const cors = {"Access-Control-Allow-Origin":"https://hiijee220.github.io","Access-Control-Allow-Headers":"authorization, apikey, content-type","Access-Control-Allow-Methods":"POST, OPTIONS","Content-Type":"application/json"};
const reply=(status:number,message:string)=>new Response(JSON.stringify({message}),{status,headers:cors});
Deno.serve(async(req)=>{
  if(req.method==="OPTIONS")return new Response(null,{headers:cors});
  if(req.method!=="POST")return reply(405,"Metode tidak diizinkan");
  try{
    const url=Deno.env.get("SUPABASE_URL")!,anon=Deno.env.get("SUPABASE_ANON_KEY")!,service=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const token=req.headers.get("authorization")?.replace(/^Bearer\s+/i,"");
    if(!token)return reply(401,"Harus login sebagai Super Admin");
    const caller=createClient(url,anon,{global:{headers:{Authorization:"Bearer "+token}},auth:{persistSession:false}});
    const {data:{user},error:authError}=await caller.auth.getUser();
    if(authError||!user)return reply(401,"Sesi login tidak valid");
    const admin=createClient(url,service,{auth:{persistSession:false}});
    const {data:profile,error:profileError}=await admin.from("staff_profiles").select("role,active").eq("user_id",user.id).maybeSingle();
    if(profileError||profile?.role!=="super_admin"||profile?.active!==true)return reply(403,"Hanya Super Admin aktif yang dapat membuat akun");
    const body=await req.json();
    const username=String(body.username||"").trim().toLowerCase(),password=String(body.password||"");
    const fullName=String(body.full_name||"").trim(),role=String(body.role||"");
    const commission=String(body.commission_name||"").trim()||null;
    const kolom=body.kolom_number===null||body.kolom_number===""?null:Number(body.kolom_number);
    const roles=["pendeta","ketua_bpmj","sekretaris","bendahara","komisi_pelayanan","ketua_kolom","pengurus_kolom","admin","operator"];
    if(!/^[a-z0-9][a-z0-9._-]{2,39}$/.test(username))return reply(400,"Username harus 3-40 karakter: huruf kecil, angka, titik, garis atau garis bawah");
    if(password.length<12||password.length>128)return reply(400,"Password awal harus 12-128 karakter");
    if(fullName.length<2||fullName.length>160||!roles.includes(role))return reply(400,"Nama atau jabatan tidak valid");
    if(kolom!==null&&(!Number.isInteger(kolom)||kolom<1||kolom>16))return reply(400,"Kolom harus 1 sampai 16");
    const email=username+"@example.com"; // Internal login identity; not a real mailbox.
    const {data:created,error:createError}=await admin.auth.admin.createUser({email,password,email_confirm:true,user_metadata:{username}});
    if(createError||!created.user)return reply(400,"Tidak dapat membuat akun: "+(createError?.message||"tidak diketahui"));
    const {error:saveError}=await caller.rpc("manage_staff_account",{p_user_id:created.user.id,p_full_name:fullName,p_role:role,p_active:true,p_commission_name:commission,p_kolom_number:kolom});
    if(saveError){await admin.auth.admin.deleteUser(created.user.id);return reply(500,"Akun dibatalkan karena gagal menyimpan hak akses: "+saveError.message)}
    return new Response(JSON.stringify({message:"Akun berhasil dibuat",username}),{status:201,headers:cors});
  }catch(e){return reply(500,"Terjadi kesalahan pada layanan pembuatan akun")}
});

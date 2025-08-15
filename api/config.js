// api/config.js

export default function handler(req, res) {
  res.setHeader('Content-Type', 'text/javascript');
  res.status(200).send(`window.env = { SUPABASE_URL: '${process.env.SUPABASE_URL}', SUPABASE_ANON_KEY: '${process.env.SUPABASE_ANON_KEY}' };`);
}
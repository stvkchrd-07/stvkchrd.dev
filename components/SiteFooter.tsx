'use client';

function copyEmail() {
  const email = 'satvikc73@gmail.com';
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(email).then(() => showToast(email));
  } else {
    const el = document.createElement('textarea');
    el.value = email;
    el.style.position = 'fixed';
    document.body.appendChild(el);
    el.focus(); el.select();
    try { document.execCommand('copy'); showToast(email); } catch {}
    document.body.removeChild(el);
  }
}

function showToast(email: string) {
  const toast = document.getElementById('copy-toast');
  if (!toast) return;
  toast.textContent = `${email} copied to clipboard`;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 800);
}

export default function SiteFooter() {
  return (
    <>
      <footer className="mt-20 pt-8 border-t-2 border-black bg-white/80 backdrop-blur-sm">
        <div className="text-center">
          <p className="mb-2">
            <span onClick={copyEmail} className="underline hover:no-underline cursor-pointer">
              satvikc73@gmail.com
            </span>
          </p>
          <p>© 2025 Satvik Chaturvedi. All rights reserved.</p>
        </div>
      </footer>
      <div id="copy-toast" />
    </>
  );
}

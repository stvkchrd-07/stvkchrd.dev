// js/utils.js — shared utilities across all pages

function copyEmailToClipboard(email) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(email).then(() => {
            showCopyToast(email);
        }).catch(() => fallbackCopy(email));
    } else {
        fallbackCopy(email);
    }
}

function fallbackCopy(email) {
    const el = document.createElement('textarea');
    el.value = email;
    el.style.position = 'fixed';
    document.body.appendChild(el);
    el.focus();
    el.select();
    try { document.execCommand('copy'); showCopyToast(email); }
    catch (e) { console.error('Copy failed', e); }
    document.body.removeChild(el);
}

function showCopyToast(email) {
    const toast = document.getElementById('copy-toast');
    if (!toast) return;
    toast.textContent = `${email} copied to clipboard`;
    toast.classList.add('show');
    setTimeout(() => toast.classList.remove('show'), 800);
}

// js/utils.js

function escapeHtml(value) {
    if (value === null || value === undefined) return '';
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function formatDate(value, options) {
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) {
        return '';
    }

    return date.toLocaleDateString('en-US', options || {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
    });
}

function showCopyToast(text) {
    const toast = document.getElementById('copy-toast');
    if (!toast) return;

    toast.textContent = `${text} copied to clipboard`;
    toast.classList.add('show');
    setTimeout(() => {
        toast.classList.remove('show');
    }, 1000);
}

function fallbackCopy(text) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.opacity = '0';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        document.execCommand('copy');
        showCopyToast(text);
    } catch (err) {
        console.error('Unable to copy text:', err);
    } finally {
        document.body.removeChild(textArea);
    }
}

function copyEmailToClipboard(email) {
    if (!email) return;

    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(email)
            .then(() => showCopyToast(email))
            .catch(() => fallbackCopy(email));
        return;
    }

    fallbackCopy(email);
}

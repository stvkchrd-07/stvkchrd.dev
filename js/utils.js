function copyEmailToClipboard(e) {
    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(e).then(() => {
            showCopyToast(e)
        }).catch(t => {
            console.warn("Modern copy failed, falling back.", t), fallbackCopy(e)
        })
    } else {
        fallbackCopy(e)
    }
}

function fallbackCopy(e) {
    const o = document.createElement("textarea");
    o.value = e, o.style.position = "fixed", document.body.appendChild(o), o.focus(), o.select();
    try {
        document.execCommand("copy"), showCopyToast(e)
    } catch (e) {
        console.error("Fallback: Oops, unable to copy", e)
    }
    document.body.removeChild(o)
}

function showCopyToast(e) {
    const o = document.getElementById("copy-toast");
    o && (o.textContent = `${e} copied to clipboard`, o.classList.add("show"), setTimeout(() => {
        o.classList.remove("show")
    }, 800))
}
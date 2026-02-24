(function () {
    const button = document.getElementById('rao-ai-button');
    const status = document.getElementById('rao-status');
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

    if (!button) return;

    const BACKEND_URL = (window.env && window.env.RAO_BACKEND_URL) || 'http://127.0.0.1:5000/api/rao';

    function setStatus(message) {
        if (status) {
            status.textContent = message;
        }
    }

    function speak(text) {
        if (!window.speechSynthesis) return;
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = 'en-US';
        window.speechSynthesis.cancel();
        window.speechSynthesis.speak(utterance);
    }

    async function fetchRaoReply(transcript) {
        const response = await fetch(BACKEND_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ transcript })
        });

        if (!response.ok) {
            throw new Error('Rao backend request failed.');
        }

        const data = await response.json();
        return data.reply;
    }

    async function handleTranscript(transcript) {
        setStatus('Rao is thinking...');

        try {
            const reply = await fetchRaoReply(transcript);
            setStatus(`Rao: ${reply}`);
            speak(reply);
        } catch (error) {
            const fallback = 'Sorry, I hit a snag. Please try again — Rao out.';
            setStatus(fallback);
            speak(fallback);
            console.error(error);
        } finally {
            button.disabled = false;
            button.textContent = 'Rao AI';
        }
    }

    function startListening() {
        if (!SpeechRecognition) {
            const unsupported = 'Speech recognition is not supported in this browser.';
            setStatus(unsupported);
            return;
        }

        const recognition = new SpeechRecognition();
        recognition.lang = 'en-US';
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;

        button.disabled = true;
        button.textContent = 'Listening...';
        setStatus('Listening...');

        recognition.onresult = function (event) {
            const transcript = event.results[0][0].transcript.trim();
            setStatus(`You: ${transcript}`);
            recognition.stop();
            handleTranscript(transcript);
        };

        recognition.onerror = function () {
            const msg = 'Could not capture audio. Please try again.';
            setStatus(msg);
            button.disabled = false;
            button.textContent = 'Rao AI';
        };

        recognition.onend = function () {
            if (button.disabled && button.textContent === 'Listening...') {
                button.disabled = false;
                button.textContent = 'Rao AI';
            }
        };

        recognition.start();
    }

    button.addEventListener('click', startListening);
})();

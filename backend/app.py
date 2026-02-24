import os

from flask import Flask, jsonify, request
from flask_cors import CORS
import google.generativeai as genai

ALLOWED_ORIGIN = os.environ.get('ALLOWED_ORIGIN', 'https://stvkchrd.dev')
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-1.5-flash')

app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": [ALLOWED_ORIGIN]}})

if not GEMINI_API_KEY:
    raise RuntimeError('GEMINI_API_KEY environment variable is required')

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(GEMINI_MODEL)


@app.post('/api/rao')
def rao_chat():
    body = request.get_json(silent=True) or {}
    transcript = (body.get('transcript') or '').strip()

    if not transcript:
        return jsonify({'error': 'transcript is required'}), 400

    prompt = (
        'You are Rao, a concise and friendly voice assistant for a personal website. '
        'Answer conversationally and helpfully. Always end every response with "— Rao out." '\
        f'\n\nUser said: {transcript}'
    )

    try:
        result = model.generate_content(prompt)
        text = (result.text or '').strip()
    except Exception:
        return jsonify({'error': 'Upstream model request failed'}), 502

    if not text.endswith('— Rao out.'):
        text = f"{text.rstrip('. ')} — Rao out."

    return jsonify({'reply': text})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', '5000')))

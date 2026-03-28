import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { text } = await req.json();
    const apiKey = process.env.ELEVENLABS_API_KEY;

    if (!apiKey) {
      console.error("SERVER ERROR: ELEVENLABS_API_KEY is missing. Did you restart the server?");
      return NextResponse.json({ error: "Missing ElevenLabs API Key in .env.local" }, { status: 500 });
    }

    const VOICE_ID = "pNInz6obbfIdG4L1peC2"; // Standard Adam voice, handles Hinglish well
    
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}/stream`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: text,
        model_id: "eleven_multilingual_v2",
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.75,
        }
      })
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error("ELEVENLABS API ERROR:", errorData);
      return NextResponse.json({ error: `ElevenLabs Error: ${errorData}` }, { status: response.status });
    }

    const audioBuffer = await response.arrayBuffer();
    
    // Use standard Response (instead of NextResponse) for raw binary audio in Next.js 15
    return new Response(audioBuffer, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'no-store, max-age=0',
      }
    });

  } catch (error: any) {
    console.error("CRITICAL RAO AI Error:", error);
    return NextResponse.json({ error: error.message || "Internal Server Error" }, { status: 500 });
  }
}

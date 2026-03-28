import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const { text } = await req.json();

    if (!process.env.ELEVENLABS_API_KEY) {
      return NextResponse.json({ error: "Missing ElevenLabs API Key" }, { status: 500 });
    }

    // You can change this to a specific Indian Male Voice ID from your ElevenLabs dashboard
    const VOICE_ID = "pNInz6obbfIdG4L1peC2"; // Placeholder Adam voice. Replace with your custom Hinglish voice ID.
    
    // Call ElevenLabs API
    const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}/stream`, {
      method: 'POST',
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': process.env.ELEVENLABS_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: text,
        // Turbo v2.5 is the best model for switching smoothly between Hindi and English
        model_id: "eleven_turbo_v2_5",
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.75,
        }
      })
    });

    if (!response.ok) {
      throw new Error(`ElevenLabs API error: ${response.statusText}`);
    }

    const audioBuffer = await response.arrayBuffer();
    
    return new NextResponse(audioBuffer, {
      headers: { 'Content-Type': 'audio/mpeg' }
    });

  } catch (error) {
    console.error("RAO AI Error:", error);
    return NextResponse.json({ error: "Voice generation failed." }, { status: 500 });
  }
}

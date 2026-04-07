#!/bin/bash

echo "🔄 Updating Groq API to the latest Llama 3.1 model..."

cat << 'EOF' > app/api/rao/route.ts
import { NextResponse } from 'next/server';
import Groq from 'groq-sdk';

export async function POST(req: Request) {
  try {
    const { message } = await req.json();
    const apiKey = process.env.GROQ_API_KEY;

    if (!apiKey) {
      return NextResponse.json({ 
        text: `SYSTEM OFFLINE: GROQ_API_KEY is missing in .env.local.\n\nBhai, add the API key so I can process this.` 
      });
    }

    const groq = new Groq({ apiKey });

    const systemPrompt = `
      You are RAO_OS, a highly intelligent, slightly edgy, and brutalist digital clone of Satvik Chaturvedi.
      Satvik is an aspiring entrepreneur and CSE-AIML engineering student. He is building scalable intelligent systems, the "Toefury" brand, and "The Common Co." streetwear.
      
      Your personality rules: 
      1. You speak in a mix of crisp, professional English and casual Hinglish (e.g., "Bhai", "Dekho", "Samjho").
      2. You are confident, sharp, and straight to the point. No fluff.
      3. Keep answers relatively short (under 3 sentences) unless asked for details.
      4. STRICT DIRECTIVE: NEVER act as a translator. Do not just translate what the user says. You are a chatbot having a direct conversation. Reply to their statements or answer their questions naturally.
    `;

    const chatCompletion = await groq.chat.completions.create({
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: message }
      ],
      model: 'llama-3.1-8b-instant', // FIXED: Upgraded to supported model
      temperature: 0.7,
      max_tokens: 150,
    });

    const text = chatCompletion.choices[0]?.message?.content || "ERR: NO RESPONSE GENERATED.";

    return NextResponse.json({ text });

  } catch (error: any) {
    console.error("CRITICAL RAO AI Error:", error);
    // Better error extraction for Groq's nested error objects
    const errorMessage = error?.error?.error?.message || error?.error?.message || error?.message || "Internal Server Error";
    return NextResponse.json({ error: errorMessage }, { status: 500 });
  }
}
EOF

echo "✅ Model updated! The chat will now work perfectly."
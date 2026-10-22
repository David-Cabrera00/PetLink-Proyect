import { BadGatewayException, Injectable, ServiceUnavailableException } from '@nestjs/common';

@Injectable()
export class AiService {
  async analyzePetImage(imageUrl: string) {
    const apiKey = process.env.OPENROUTER_API_KEY;
    const model = process.env.OPENROUTER_MODEL;
    if (!apiKey || !model) {
      throw new ServiceUnavailableException('OpenRouter AI is not configured');
    }
    if (!/^https?:\/\//i.test(imageUrl)) {
      throw new BadGatewayException('The image URL must be publicly accessible');
    }

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': process.env.OPENROUTER_SITE_URL ?? 'http://localhost:3000',
        'X-Title': process.env.OPENROUTER_APP_NAME ?? 'PetLink',
      },
      body: JSON.stringify({
        model,
        temperature: 0,
        max_tokens: 500,
        messages: [{
          role: 'user',
          content: [
            { type: 'text', text: 'Analiza esta mascota. Responde únicamente JSON válido con estas claves: species, breed, color, size, sex, visibleTraits, confidence. No inventes datos; usa null o [] si no son visibles.' },
            { type: 'image_url', image_url: { url: imageUrl } },
          ],
        }],
      }),
    });
    const raw = await response.text();
    if (!response.ok) throw new BadGatewayException(`OpenRouter error (${response.status})`);
    try {
      const content = JSON.parse(raw).choices?.[0]?.message?.content ?? '{}';
      const json = content.replace(/^```json\s*|\s*```$/g, '').trim();
      return JSON.parse(json);
    } catch {
      throw new BadGatewayException('OpenRouter returned an invalid analysis');
    }
  }
}

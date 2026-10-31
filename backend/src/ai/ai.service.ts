import { BadGatewayException, Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';

export interface PetAnalysisResult {
  species: string;
  breed: string;
  color: string;
  size: string;
  sex: string | null;
  visibleTraits: string[];
  confidence: number;
}

export interface AnalyzeImageOptions {
  file?: { originalname?: string; mimetype?: string; buffer: Buffer; size?: number };
  imageUrl?: string;
  imageBase64?: string;
}

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  async analyzePetImage(options: AnalyzeImageOptions): Promise<PetAnalysisResult> {
    const geminiKey = process.env.GEMINI_API_KEY;
    const openRouterKey = process.env.OPENROUTER_API_KEY;

    // 1. Obtener los bytes base64 y mimeType de la imagen
    let base64Data: string;
    let mimeType = 'image/jpeg';

    if (options.file?.buffer) {
      base64Data = options.file.buffer.toString('base64');
      mimeType = options.file.mimetype || 'image/jpeg';
    } else if (options.imageBase64) {
      const match = options.imageBase64.match(/^data:([^;]+);base64,(.+)$/);
      if (match) {
        mimeType = match[1];
        base64Data = match[2];
      } else {
        base64Data = options.imageBase64;
      }
    } else if (options.imageUrl) {
      if (!/^https?:\/\//i.test(options.imageUrl)) {
        throw new BadGatewayException('The image URL must be publicly accessible');
      }
      try {
        const imgResp = await fetch(options.imageUrl);
        if (!imgResp.ok) throw new BadGatewayException('Could not fetch image URL');
        const arrayBuf = await imgResp.arrayBuffer();
        base64Data = Buffer.from(arrayBuf).toString('base64');
        mimeType = imgResp.headers.get('content-type') || 'image/jpeg';
      } catch (err: any) {
        throw new BadGatewayException(`Failed to download image: ${err.message}`);
      }
    } else {
      throw new BadGatewayException('No image provided for analysis (file, imageBase64, or imageUrl required)');
    }

    // 2. Prioridad: Google Gemini Vision (rápido y de alta precisión)
    let lastError: string | null = null;
    if (geminiKey) {
      try {
        return await this.analyzeWithGemini(base64Data, mimeType, geminiKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`Gemini analysis failed: ${err.message}`);
      }
    }

    // 3. Fallback: OpenRouter
    if (openRouterKey && options.imageUrl) {
      try {
        return await this.analyzeWithOpenRouter(options.imageUrl, openRouterKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`OpenRouter analysis failed: ${err.message}`);
      }
    }

    if (!geminiKey && !openRouterKey) {
      throw new ServiceUnavailableException('AI Vision service is not configured (missing GEMINI_API_KEY)');
    }

    throw new BadGatewayException(
      `No se pudo analizar la imagen con los proveedores de IA disponibles: ${lastError ?? 'error desconocido'}`
    );
  }

  private async analyzeWithGemini(
    base64Data: string,
    mimeType: string,
    geminiKey: string,
  ): Promise<PetAnalysisResult> {
    const model = process.env.GEMINI_MODEL || 'gemini-3.8-flash';
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${geminiKey}`;

    const prompt = `Analiza esta imagen de mascota para un reporte de rescate o pérdida.
Responde EXCLUSIVAMENTE con un JSON válido con la siguiente estructura y valores exactos:
{
  "species": "Perro" | "Gato" | "Otro",
  "breed": "Nombre de la raza identificada (o Criollo si es mestizo o no definida)",
  "color": "Color predominante en español (ej: Dorado, Negro, Café, Blanco, Gris, Bicolor, Atigrado)",
  "size": "Pequeño" | "Mediano" | "Grande",
  "sex": "Macho" | "Hembra" | null,
  "visibleTraits": ["rasgo 1", "rasgo 2"],
  "confidence": 0.95
}`;

    const payload = {
      contents: [{
        parts: [
          { text: prompt },
          {
            inlineData: {
              mimeType: mimeType,
              data: base64Data,
            },
          },
        ],
      }],
      generationConfig: {
        response_mime_type: 'application/json',
        temperature: 0.1,
      },
    };

    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Gemini API error (${response.status}): ${errText}`);
    }

    const data = await response.json();
    const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!rawText) throw new Error('Empty response from Gemini');

    const parsed = JSON.parse(rawText);
    return {
      species: parsed.species || 'Perro',
      breed: parsed.breed || '',
      color: parsed.color || '',
      size: parsed.size || 'Mediano',
      sex: parsed.sex || null,
      visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.9,
    };
  }

  private async analyzeWithOpenRouter(
    imageUrl: string,
    apiKey: string,
  ): Promise<PetAnalysisResult> {
    const model = process.env.OPENROUTER_MODEL || 'openrouter/free';
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
        max_tokens: 400,
        messages: [{
          role: 'user',
          content: [
            { type: 'text', text: 'Analiza esta mascota. Responde unicamente JSON valido con: species, breed, color, size, sex, visibleTraits, confidence.' },
            { type: 'image_url', image_url: { url: imageUrl } },
          ],
        }],
      }),
    });

    if (!response.ok) throw new Error(`OpenRouter error (${response.status})`);
    const raw = await response.text();
    const content = JSON.parse(raw).choices?.[0]?.message?.content ?? '{}';
    const json = content.replace(/^```json\s*|\s*```$/g, '').trim();
    const parsed = JSON.parse(json);
    return {
      species: parsed.species || 'Perro',
      breed: parsed.breed || '',
      color: parsed.color || '',
      size: parsed.size || 'Mediano',
      sex: parsed.sex || null,
      visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.8,
    };
  }
}

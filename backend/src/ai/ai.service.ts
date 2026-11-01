import { BadGatewayException, Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';

export interface PetAnalysisResult {
  species: string;
  breed: string;
  color: string;
  size: string;
  sex: string | null;
  description?: string;
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
    const groqKey = process.env.GROQ_API_KEY;
    const metaKey = process.env.META_API_KEY;
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

    let lastError: string | null = null;

    // 2. Prioridad 1: Groq Vision (Llama 3.2 Vision - Ultra rápido)
    if (groqKey) {
      try {
        return await this.analyzeWithGroq(base64Data, mimeType, groqKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`Groq analysis failed: ${err.message}`);
      }
    }

    // 3. Fallback: Meta AI (dev.meta.ai)
    if (metaKey) {
      try {
        return await this.analyzeWithMetaAi(base64Data, mimeType, metaKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`Meta AI analysis failed: ${err.message}`);
      }
    }

    // 4. Fallback: Google Gemini Vision
    if (geminiKey) {
      try {
        return await this.analyzeWithGemini(base64Data, mimeType, geminiKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`Gemini analysis failed: ${err.message}`);
      }
    }

    // 5. Fallback: OpenRouter
    if (openRouterKey) {
      try {
        return await this.analyzeWithOpenRouter(base64Data, mimeType, options.imageUrl, openRouterKey);
      } catch (err: any) {
        lastError = err.message;
        this.logger.error(`OpenRouter analysis failed: ${err.message}`);
      }
    }

    if (!groqKey && !metaKey && !geminiKey && !openRouterKey) {
      throw new ServiceUnavailableException('AI Vision service is not configured');
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
    // Lista de modelos oficiales de Gemini Vision
    const candidateModels = [
      process.env.GEMINI_MODEL,
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
    ].filter(Boolean) as string[];

    const prompt = `Eres un veterinario experto identificando mascotas para rescate o búsqueda.
Analiza la foto con atención y extrae:
1. Especie exacta: "Perro", "Gato" u "Otro". Si es un felino/gato NUNCA digas perro.
2. Raza: si es clara dilo (ej: "Siamés", "Labrador"), si es mestizo pon "Criollo" (perro) o "Mestizo" (gato).
3. Color predominante: en español (ej: "Gris", "Atigrado", "Bicolor", "Negro y blanco", "Dorado", "Café").
4. Tamaño aproximado: "Pequeño", "Mediano" o "Grande".
5. Sexo: "Macho", "Hembra" o null si no se distingue.
6. Descripción detallada: 1 o 2 oraciones describiendo el aspecto general de la mascota.
7. Señas o rasgos físicos visibles (patrones de pelaje, manchas, hocico, orejas, etc.).

Responde EXCLUSIVAMENTE un JSON válido con esta estructura:
{
  "species": "Perro" | "Gato" | "Otro",
  "breed": "Raza o Criollo/Mestizo",
  "color": "Color predominante",
  "size": "Pequeño" | "Mediano" | "Grande",
  "sex": "Macho" | "Hembra" | null,
  "description": "Breve descripción general de la mascota observada",
  "visibleTraits": ["rasgo 1", "rasgo 2", "rasgo 3"],
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

    let lastError = '';
    for (const model of candidateModels) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${geminiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        });

        if (!response.ok) {
          const errText = await response.text();
          lastError = `Gemini (${model}) error (${response.status}): ${errText}`;
          this.logger.warn(lastError);
          continue; // Intenta con el siguiente modelo si está en sobrecarga (503/429)
        }

        const data = await response.json();
        const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!rawText) throw new Error(`Empty response from Gemini ${model}`);

        const parsed = JSON.parse(rawText);
        return {
          species: parsed.species || 'Otro',
          breed: parsed.breed || 'Criollo',
          color: parsed.color || '',
          size: parsed.size || 'Mediano',
          sex: parsed.sex || null,
          description: parsed.description || '',
          visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
          confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.9,
        };
      } catch (err: any) {
        lastError = err.message;
        this.logger.warn(`Error trying model ${model}: ${err.message}`);
      }
    }

    throw new Error(lastError || 'All Gemini models failed');
  }

  private async analyzeWithGroq(
    base64Data: string,
    mimeType: string,
    apiKey: string,
  ): Promise<PetAnalysisResult> {
    const model = process.env.GROQ_MODEL || 'llama-3.2-11b-vision-preview';
    const imageUri = `data:${mimeType};base64,${base64Data}`;

    const prompt = `Eres un asistente veterinario experto. Analiza la imagen de la mascota para un reporte de rescate o pérdida.
Devuelve EXCLUSIVAMENTE un objeto JSON con la siguiente estructura:
{
  "species": "Perro" o "Gato" o "Otro",
  "breed": "Nombre de la raza identificada (o Criollo si es mestizo o dudas)",
  "color": "Color predominante del pelaje en español",
  "size": "Pequeño" o "Mediano" o "Grande",
  "sex": "Macho" o "Hembra" o null,
  "description": "Descripción general y clara de la mascota",
  "visibleTraits": ["rasgo 1", "rasgo 2"],
  "confidence": 0.95
}`;

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: prompt },
              { type: 'image_url', image_url: { url: imageUri } },
            ],
          },
        ],
        temperature: 0.2,
        response_format: { type: 'json_object' },
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Groq API error (${response.status}): ${err}`);
    }

    const raw = await response.text();
    const data = JSON.parse(raw);
    const content = data.choices?.[0]?.message?.content ?? '{}';
    const json = content.replace(/^```json\s*|\s*```$/g, '').trim();
    const parsed = JSON.parse(json);

    return {
      species: parsed.species || 'Otro',
      breed: parsed.breed || 'Criollo',
      color: parsed.color || '',
      size: parsed.size || 'Mediano',
      sex: parsed.sex || null,
      description: parsed.description || '',
      visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.9,
    };
  }

  private async analyzeWithMetaAi(
    base64Data: string,
    mimeType: string,
    apiKey: string,
  ): Promise<PetAnalysisResult> {
    const model = process.env.META_MODEL || 'muse-spark-1.3';
    const imageUri = `data:${mimeType};base64,${base64Data}`;

    const prompt = `Analiza esta imagen de mascota para un reporte de rescate o pérdida.
Devuelve EXCLUSIVAMENTE un JSON válido con esta estructura:
{
  "species": "Perro" o "Gato" o "Otro",
  "breed": "Nombre de la raza identificada (o Criollo/Mestizo si dudas)",
  "color": "Color predominante en español (ej: Gris, Bicolor, Negro, Dorado)",
  "size": "Pequeño" o "Mediano" o "Grande",
  "sex": "Macho" o "Hembra" o null,
  "description": "Breve descripción general de la mascota",
  "visibleTraits": ["rasgo 1", "rasgo 2"],
  "confidence": 0.95
}`;

    const response = await fetch('https://api.meta.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages: [{
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            { type: 'image_url', image_url: { url: imageUri } },
          ],
        }],
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Meta API error (${response.status}): ${err}`);
    }

    const raw = await response.text();
    const content = JSON.parse(raw).choices?.[0]?.message?.content ?? '{}';
    const json = content.replace(/^```json\s*|\s*```$/g, '').trim();
    const parsed = JSON.parse(json);

    return {
      species: parsed.species || 'Otro',
      breed: parsed.breed || 'Criollo',
      color: parsed.color || '',
      size: parsed.size || 'Mediano',
      sex: parsed.sex || null,
      description: parsed.description || '',
      visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.9,
    };
  }

  private async analyzeWithOpenRouter(
    base64Data: string,
    mimeType: string,
    imageUrl: string | undefined,
    apiKey: string,
  ): Promise<PetAnalysisResult> {
    const model = process.env.OPENROUTER_MODEL || 'google/gemini-2.0-flash-exp:free';
    const imageUri = imageUrl ?? `data:${mimeType};base64,${base64Data}`;

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
        temperature: 0.1,
        max_tokens: 400,
        messages: [{
          role: 'user',
          content: [
            { type: 'text', text: 'Analiza esta mascota. Responde unicamente JSON valido con: species, breed, color, size, sex, visibleTraits, confidence.' },
            { type: 'image_url', image_url: { url: imageUri } },
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
      species: parsed.species || 'Otro',
      breed: parsed.breed || 'Criollo',
      color: parsed.color || '',
      size: parsed.size || 'Mediano',
      sex: parsed.sex || null,
      description: parsed.description || '',
      visibleTraits: Array.isArray(parsed.visibleTraits) ? parsed.visibleTraits : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0.8,
    };
  }
}

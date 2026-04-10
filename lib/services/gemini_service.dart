import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:project/models/nutrition.dart';

class GeminiService {
  GenerativeModel? _model;

  Future<void> _ensureInitialized() async {
    if (_model != null) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Saya adalah suatu mesin yang mampu mengidentifikasi nutrisi atau '
        'kandungan gizi pada makanan layaknya uji laboratorium makanan. '
        'Hal yang bisa diidentifikasi adalah kalori, karbohidrat, lemak, '
        'serat, dan protein pada makanan. Satuan dari indikator tersebut '
        'berupa gram.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'nutrition': Schema.object(
              properties: {
                'calories': Schema.integer(),
                'carbs': Schema.integer(),
                'protein': Schema.integer(),
                'fat': Schema.integer(),
                'fiber': Schema.integer(),
              },
              requiredProperties: [
                'calories',
                'carbs',
                'protein',
                'fat',
                'fiber',
              ],
            ),
          },
          requiredProperties: ['nutrition'],
        ),
      ),
    );
  }

  /// Get nutrition info for a food name
  Future<Nutrition> getNutritionInfo(String foodName) async {
    await _ensureInitialized();

    final prompt = 'Nama makanannya adalah $foodName.';
    debugPrint('Gemini request: $prompt');

    final response = await _model!.generateContent([Content.text(prompt)]);

    final text = response.text;
    debugPrint('Gemini response: $text');

    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    final jsonData = json.decode(text) as Map<String, dynamic>;
    return Nutrition.fromJson(jsonData);
  }
}

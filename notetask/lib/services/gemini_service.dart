// Em lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // ATENÇÃO: Substitua 'YOUR_API_KEY' pela sua chave de API do Gemini.
  // Você pode obter a chave em: https://aistudio.google.com/
  // Para segurança, evite deixar a chave diretamente no código em apps de produção.
  static const String _apiKey = 'AIzaSyBeLiOCW-9TEhUkRsQPcz6znJjktAMVAKw';

  final _model = GenerativeModel(model: 'gemini-2.5-pro', apiKey: _apiKey);

  Future<String> getResponse(String prompt) async {
    if (_apiKey == 'YOUR_API_KEY') {
      return 'Erro: Chave de API não configurada. Por favor, substitua "YOUR_API_KEY" pela sua chave.';
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Não foi possível obter uma resposta.';
    } catch (e) {
      print('Erro ao se comunicar com a API do Gemini: $e');
      return 'Ocorreu um erro ao processar sua solicitação. Tente novamente mais tarde.';
    }
  }
}

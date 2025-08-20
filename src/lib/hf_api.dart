import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'settings.dart';

class HFClient {
  final String apiKey;
  final String model;
  final AppLang lang;
  HFClient({required this.apiKey, required this.model, required this.lang});

  Future<List<Question>> generate(List<String> excerpts, {int count = 25}) async {
    final prompt = _buildPrompt(excerpts, count);
    final uri = Uri.parse('https://api-inference.huggingface.co/models/$model');
    final resp = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: json.encode({
        'inputs': prompt,
        'parameters': {'max_new_tokens': 1100},
        'options': {'wait_for_model': true, 'use_cache': false}
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('HF ${resp.statusCode}: ${resp.body}');
    }
    final body = json.decode(resp.body);
    String text;
    if (body is List && body.isNotEmpty && body[0]['generated_text'] != null) text = body[0]['generated_text'];
    else if (body is Map && body['generated_text'] != null) text = body['generated_text'];
    else if (body is String) text = body;
    else text = json.encode(body);

    final s = text.indexOf('['); final e = text.lastIndexOf(']');
    final jsonSegment = (s != -1 && e != -1) ? text.substring(s, e + 1) : text;

    final decoded = json.decode(jsonSegment);
    final List<Question> qs = (decoded as List).map((e) => Question.fromJson(e)).toList();
    return qs;
  }

  String _buildPrompt(List<String> ex, int n) {
    final joined = ex.take(4).join("\\n---\\n");
    final langInstruction = lang == AppLang.ar
      ? 'أنت مؤلف امتحانات لرمز البناء في دبي (2021) واختبارات ميكانيكية وكهربائية وصحية بأسلوب DEWA. '
        'أنشئ بالضبط '+n.toString()+' أسئلة اختيار من متعدد باللغة العربية كمصفوفة JSON. '
        'كل عنصر يجب أن يكون: {"id":"string","text":"string","choices":[{"id":"A|B|C|D","text":"string","isCorrect":bool}],"topic":"string","ref":"string","explanation":"string"}. '
        'غطِّ الكهرباء والميكانيكا (HVAC) والصحية ومكافحة الحريق. اعتمد على هذه المقتطفات مع إعادة الصياغة: '
      : 'You are an exam writer for Dubai Building Code (2021) and DEWA-style MEP exams. '
        'Generate EXACTLY '+n.toString()+' multiple-choice questions in English as a JSON array. '
        'Each item MUST be: {"id":"string","text":"string","choices":[{"id":"A|B|C|D","text":"string","isCorrect":bool}],"topic":"string","ref":"string","explanation":"string"}. '
        'Cover Electrical, HVAC/Mechanical, Plumbing/Drainage, and Fire & Life Safety. Paraphrase these excerpts: ';
    return langInstruction + joined + '. Ensure exactly one correct option per question and realistic numeric values.';
  }
}

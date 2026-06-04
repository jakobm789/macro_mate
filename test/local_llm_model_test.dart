import 'package:flutter_test/flutter_test.dart';
import 'package:macro_mate/models/local_llm_model.dart';

void main() {
  test('supported local LLM choices are vision-capable', () {
    expect(
      LocalLlmModel.supported.map((model) => model.displayName),
      containsAll([
        'Gemma 4 E2B',
        'Gemma 4 E4B',
        'Gemma 4 E4B Reasoning',
      ]),
    );
    expect(
      LocalLlmModel.supported.map((model) => model.id),
      isNot(contains(LocalLlmModelId.fastVlm05b)),
    );
    expect(
      LocalLlmModel.supported.every((model) => model.supportsVision),
      isTrue,
    );
  });

  test('stored model name falls back to standard Gemma 4 E4B', () {
    final model = LocalLlmModel.byStoredName('missing-model');

    expect(model.id, LocalLlmModelId.gemma4E4b);
  });

  test('stored FastVLM falls back because it is not mobile-supported', () {
    final model = LocalLlmModel.byStoredName(LocalLlmModelId.fastVlm05b.name);

    expect(model.id, LocalLlmModelId.gemma4E4b);
  });
}

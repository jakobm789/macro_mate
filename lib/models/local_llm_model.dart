import 'package:flutter_gemma/flutter_gemma.dart';

enum LocalLlmModelId {
  fastVlm05b,
  gemma4E2b,
  gemma4E4b,
  gemma4E4bReasoning,
}

class LocalLlmModel {
  final LocalLlmModelId id;
  final String displayName;
  final String fileName;
  final String downloadUrl;
  final ModelType modelType;
  final bool supportsVision;
  final int maxTokens;
  final String recommendation;
  final bool reasoningMode;

  const LocalLlmModel({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.downloadUrl,
    required this.modelType,
    required this.supportsVision,
    required this.maxTokens,
    required this.recommendation,
    this.reasoningMode = false,
  });

  static const List<LocalLlmModel> all = [
    LocalLlmModel(
      id: LocalLlmModelId.fastVlm05b,
      displayName: 'FastVLM 0.5B',
      fileName: 'FastVLM-0.5B.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/FastVLM-0.5B/resolve/main/FastVLM-0.5B.litertlm',
      modelType: ModelType.general,
      supportsVision: true,
      maxTokens: 2048,
      recommendation: 'Super leicht, super schnell.',
    ),
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E2b,
      displayName: 'Gemma 4 E2B',
      fileName: 'gemma-4-E2B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 2048,
      recommendation: 'Schnell.',
    ),
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E4b,
      displayName: 'Gemma 4 E4B',
      fileName: 'gemma-4-E4B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 3072,
      recommendation: 'Standard.',
    ),
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E4bReasoning,
      displayName: 'Gemma 4 E4B Reasoning',
      fileName: 'gemma-4-E4B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 3072,
      recommendation: 'Maximale Qualität, dauert länger.',
      reasoningMode: true,
    ),
  ];

  static const List<LocalLlmModel> supported = [
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E2b,
      displayName: 'Gemma 4 E2B',
      fileName: 'gemma-4-E2B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 2048,
      recommendation: 'Schnell.',
    ),
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E4b,
      displayName: 'Gemma 4 E4B',
      fileName: 'gemma-4-E4B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 3072,
      recommendation: 'Standard.',
    ),
    LocalLlmModel(
      id: LocalLlmModelId.gemma4E4bReasoning,
      displayName: 'Gemma 4 E4B Reasoning',
      fileName: 'gemma-4-E4B-it.litertlm',
      downloadUrl:
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm',
      modelType: ModelType.gemma4,
      supportsVision: true,
      maxTokens: 3072,
      recommendation: 'Maximale Qualität, dauert länger.',
      reasoningMode: true,
    ),
  ];

  static LocalLlmModel byId(LocalLlmModelId id) {
    return all.firstWhere(
      (model) => model.id == id,
      orElse: () => supported.first,
    );
  }

  static LocalLlmModel byStoredName(String? storedName) {
    final id = LocalLlmModelId.values.firstWhere(
      (value) => value.name == storedName,
      orElse: () => LocalLlmModelId.gemma4E4b,
    );
    final model = byId(id);
    return supported.any((supportedModel) => supportedModel.id == model.id)
        ? model
        : byId(LocalLlmModelId.gemma4E4b);
  }
}

class RedactionUtil {
  static final _bearerRegex = RegExp(r'Bearer\s+[A-Za-z0-9_\-\.]{10,}', caseSensitive: false);
  static final _openAiKeyRegex = RegExp(r'sk-[A-Za-z0-9_\-]{20,}');
  static final _agentLensKeyRegex = RegExp(r'agt_[A-Za-z0-9_\-]{20,}');
  static final _generalSecretKeyRegex = RegExp(
    r'''(["']?(?:api[_-]?key|secret|password|auth[_-]?token|access[_-]?token)["']?\s*[:=]\s*["'])([^"']+)(["'])''',
    caseSensitive: false,
  );

  static String redact(String? input) {
    if (input == null || input.isEmpty) return '';
    var sanitized = input;
    sanitized = sanitized.replaceAllMapped(_bearerRegex, (m) => 'Bearer [REDACTED_TOKEN]');
    sanitized = sanitized.replaceAllMapped(_openAiKeyRegex, (m) => 'sk-[REDACTED_API_KEY]');
    sanitized = sanitized.replaceAllMapped(_agentLensKeyRegex, (m) => 'agt_[REDACTED_KEY]');
    sanitized = sanitized.replaceAllMapped(_generalSecretKeyRegex, (m) => '${m.group(1)}[REDACTED]${m.group(3)}');
    return sanitized;
  }
}

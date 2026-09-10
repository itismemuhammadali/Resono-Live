class ContentFilter {
  ContentFilter._();

  static final Set<String> _objectionableWords = {
    // Profanity and harassment keywords
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'dick',
    'cunt',
    'nigger',
    'nigga',
    'faggot',
    'bastard',
    'whore',
    'slut',
    'porn',
    'nude',
    'kill yourself',
    'kys',
    'retard',
    'hate',
    'scam',
  };

  /// Checks whether a given string contains objectionable content or hate speech
  static bool isObjectionable(String text) {
    if (text.trim().isEmpty) return false;
    final lower = text.toLowerCase();
    
    for (final word in _objectionableWords) {
      // Check as word boundary or exact match
      final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (pattern.hasMatch(lower) || lower.contains(word)) {
        return true;
      }
    }
    return false;
  }

  /// Sanitizes text by masking objectionable words with asterisks
  static String sanitize(String text) {
    if (text.trim().isEmpty) return text;
    String result = text;
    for (final word in _objectionableWords) {
      final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) => '*' * match.group(0)!.length);
    }
    return result;
  }
}

/// Email validation utility with common typo detection
class EmailValidator {
  // Common email domains
  static const List<String> commonDomains = [
    'gmail.com',
    'yahoo.com',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
    'aol.com',
    'mail.com',
    'protonmail.com',
    'yandex.com',
    'zoho.com',
    'gmx.com',
    'live.com',
    'msn.com',
  ];

  // Common typos for popular domains
  static const Map<String, String> commonTypos = {
    'gamil.com': 'gmail.com',
    'gmial.com': 'gmail.com',
    'gmaill.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gmail.cm': 'gmail.com',
    'gmail.coom': 'gmail.com',
    'yahooo.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'yahoo.co': 'yahoo.com',
    'outlok.com': 'outlook.com',
    'outlook.co': 'outlook.com',
    'outlook.con': 'outlook.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.co': 'hotmail.com',
    'hotmail.con': 'hotmail.com',
  };

  /// Validates email format and checks for common typos
  /// Returns null if valid, or an error message if invalid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email address';
    }

    // Trim whitespace
    final trimmedEmail = email.trim().toLowerCase();

    // Basic format check
    if (!trimmedEmail.contains('@')) {
      return 'Email must contain @ symbol';
    }

    // Split email into local and domain parts
    final parts = trimmedEmail.split('@');
    if (parts.length != 2) {
      return 'Invalid email format. Please check for multiple @ symbols';
    }

    final localPart = parts[0];
    final domain = parts[1];

    // Check local part
    if (localPart.isEmpty) {
      return 'Email address cannot be empty before @';
    }

    if (localPart.length > 64) {
      return 'Email address is too long';
    }

    // Check for valid characters in local part
    if (!RegExp(r'^[a-z0-9._+-]+$').hasMatch(localPart)) {
      return 'Email contains invalid characters. Use only letters, numbers, dots, underscores, plus, and hyphens';
    }

    // Check domain part
    if (domain.isEmpty) {
      return 'Email must include a domain (e.g., @gmail.com)';
    }

    // If domain is already a valid common domain, don't suggest it's a typo
    if (commonDomains.contains(domain)) {
      // Domain is valid, continue with other validations
    } else {
      // Check for common typos
      if (commonTypos.containsKey(domain)) {
        final correctDomain = commonTypos[domain];
        return 'Did you mean @$correctDomain? Please check your email domain spelling.';
      }

      // Check if domain looks like a typo of common domains
      final typoSuggestion = _checkForTypo(domain);
      if (typoSuggestion != null) {
        return 'Did you mean @$typoSuggestion? Please check your email domain spelling.';
      }
    }

    // Validate domain format
    if (!RegExp(r'^[a-z0-9.-]+\.[a-z]{2,}$').hasMatch(domain)) {
      return 'Invalid email domain format. Domain must include a valid top-level domain (e.g., .com, .org)';
    }

    // Check for valid TLD (top-level domain)
    final tldMatch = RegExp(r'\.([a-z]{2,})$').firstMatch(domain);
    if (tldMatch == null) {
      return 'Email domain must end with a valid extension (e.g., .com, .org, .net)';
    }

    final tld = tldMatch.group(1)!;
    if (tld.length < 2 || tld.length > 10) {
      return 'Invalid domain extension. Please check your email address';
    }

    // Check for consecutive dots
    if (domain.contains('..') || localPart.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    // Check if domain starts or ends with dot or hyphen
    if (domain.startsWith('.') || domain.startsWith('-') ||
        domain.endsWith('.') || domain.endsWith('-')) {
      return 'Invalid domain format. Please check your email address';
    }

    // Full email regex validation
    final emailRegex = RegExp(
      r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Invalid email format. Please enter a valid email address';
    }

    return null; // Email is valid
  }

  /// Checks if a domain looks like a typo of a common domain
  static String? _checkForTypo(String domain) {
    for (final commonDomain in commonDomains) {
      if (_isTypo(domain, commonDomain)) {
        return commonDomain;
      }
    }
    return null;
  }

  /// Checks if domain1 is likely a typo of domain2
  static bool _isTypo(String domain1, String domain2) {
    // Don't suggest one valid common domain as a typo of another
    // This prevents gmail.com and mail.com from being flagged as typos of each other
    if (commonDomains.contains(domain1) && commonDomains.contains(domain2)) {
      return false;
    }

    // Same length, check for single character differences
    if (domain1.length == domain2.length) {
      int differences = 0;
      for (int i = 0; i < domain1.length; i++) {
        if (domain1[i] != domain2[i]) {
          differences++;
        }
      }
      // If only 1-2 characters differ, it's likely a typo
      // But be more strict: require at least 3+ character difference for similar-length domains
      // to avoid false positives between valid domains like gmail.com and mail.com
      if (differences > 0 && differences <= 2 && domain1.length >= 8) {
        // For longer domains, be more lenient only if it's a clear typo
        // For shorter domains or when one is not a common domain, allow 1-2 differences
        if (!commonDomains.contains(domain1)) {
          return true;
        }
      }
    }

    // Check for missing/extra characters (Levenshtein-like check)
    // Only check if length difference is exactly 1, and be more careful
    if ((domain1.length - domain2.length).abs() == 1) {
      // Don't suggest if one is a valid common domain and the other contains it
      // This prevents mail.com from being suggested as typo of gmail.com
      if (commonDomains.contains(domain1) || commonDomains.contains(domain2)) {
        // If one is a common domain, only suggest if it's clearly a typo
        // (e.g., missing a character at the end, not at the beginning)
        final shorter = domain1.length < domain2.length ? domain1 : domain2;
        final longer = domain1.length > domain2.length ? domain1 : domain2;
        if (longer.endsWith(shorter) || longer.startsWith(shorter)) {
          // One is a prefix or suffix of the other - likely not a typo if both are common
          return false;
        }
      }
      // Check if one is substring of the other with one char difference
      if (domain2.contains(domain1) || domain1.contains(domain2)) {
        return true;
      }
    }

    // Check for common character swaps (e.g., gmail vs gamil)
    if (domain1.length == domain2.length) {
      for (int i = 0; i < domain1.length - 1; i++) {
        final swapped = domain1.substring(0, i) +
            domain1[i + 1] +
            domain1[i] +
            domain1.substring(i + 2);
        if (swapped == domain2) {
          return true;
        }
      }
    }

    return false;
  }
}


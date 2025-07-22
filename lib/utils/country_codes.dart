class CountryCode {
  final String code;
  final String name;
  final String flag;
  final String dialCode;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    required this.dialCode,
  });

  @override
  String toString() => '$flag $dialCode';
}

class CountryCodes {
  static const List<CountryCode> countries = [
    CountryCode(code: 'TW', name: '台灣', flag: '🇹🇼', dialCode: '+886'),
    CountryCode(code: 'US', name: 'United States', flag: '🇺🇸', dialCode: '+1'),
    CountryCode(code: 'CN', name: '中國', flag: '🇨🇳', dialCode: '+86'),
    CountryCode(code: 'HK', name: '香港', flag: '🇭🇰', dialCode: '+852'),
    CountryCode(code: 'MO', name: '澳門', flag: '🇲🇴', dialCode: '+853'),
    CountryCode(code: 'JP', name: '日本', flag: '🇯🇵', dialCode: '+81'),
    CountryCode(code: 'KR', name: '韓國', flag: '🇰🇷', dialCode: '+82'),
    CountryCode(code: 'SG', name: 'Singapore', flag: '🇸🇬', dialCode: '+65'),
    CountryCode(code: 'MY', name: 'Malaysia', flag: '🇲🇾', dialCode: '+60'),
    CountryCode(code: 'TH', name: 'Thailand', flag: '🇹🇭', dialCode: '+66'),
    CountryCode(code: 'VN', name: 'Vietnam', flag: '🇻🇳', dialCode: '+84'),
    CountryCode(code: 'KH', name: 'Cambodia', flag: '🇰🇭', dialCode: '+855'),
    CountryCode(code: 'LA', name: 'Laos', flag: '🇱🇦', dialCode: '+856'),
    CountryCode(code: 'MM', name: 'Myanmar', flag: '🇲🇲', dialCode: '+95'),
    CountryCode(code: 'PH', name: 'Philippines', flag: '🇵🇭', dialCode: '+63'),
    CountryCode(code: 'ID', name: 'Indonesia', flag: '🇮🇩', dialCode: '+62'),
    CountryCode(code: 'IN', name: 'India', flag: '🇮🇳', dialCode: '+91'),
    CountryCode(code: 'AU', name: 'Australia', flag: '🇦🇺', dialCode: '+61'),
    CountryCode(code: 'NZ', name: 'New Zealand', flag: '🇳🇿', dialCode: '+64'),
    CountryCode(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
    CountryCode(code: 'FR', name: 'France', flag: '🇫🇷', dialCode: '+33'),
    CountryCode(code: 'DE', name: 'Germany', flag: '🇩🇪', dialCode: '+49'),
    CountryCode(code: 'IT', name: 'Italy', flag: '🇮🇹', dialCode: '+39'),
    CountryCode(code: 'ES', name: 'Spain', flag: '🇪🇸', dialCode: '+34'),
    CountryCode(code: 'CA', name: 'Canada', flag: '🇨🇦', dialCode: '+1'),
  ];

  static CountryCode getDefault() {
    return countries.first; // 台灣作為預設
  }

  static CountryCode? findByDialCode(String dialCode) {
    try {
      return countries.firstWhere((country) => country.dialCode == dialCode);
    } catch (e) {
      return null;
    }
  }

  static CountryCode? findByCode(String code) {
    try {
      return countries.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }
}
class OnboardingConfigModel {
  const OnboardingConfigModel({
    required this.categories,
    required this.timezones,
    required this.countries,
  });

  final List<String> categories;
  final List<String> timezones;
  final List<String> countries;

  static const defaultCategories = [
    'E-Commerce & Retail',
    'Creator & Personal Brand',
    'Marketing Agency',
    'SaaS & Software',
    'Education & Coaching',
    'Real Estate & Finance',
    'Healthcare & Wellness',
    'Other Business',
  ];

  static const defaultTimezones = [
    'UTC (Universal Coordinated Time)',
    'EST (UTC-5) New York, Toronto',
    'CST (UTC-6) Chicago, Mexico City',
    'PST (UTC-8) Los Angeles, Vancouver',
    'GMT (UTC+0) London, Dublin',
    'CET (UTC+1) Paris, Berlin, Rome',
    'IST (UTC+5:30) Mumbai, New Delhi',
    'SGT (UTC+8) Singapore, Hong Kong',
    'JST (UTC+9) Tokyo, Seoul',
    'AEST (UTC+10) Sydney, Melbourne',
  ];

  static const defaultCountries = [
    'United States',
    'United Kingdom',
    'India',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Singapore',
    'United Arab Emirates',
    'Brazil',
    'Other',
  ];
}

import 'package:emychat/core/network/api_client.dart';
import '../models/onboarding_model.dart';

class OnboardingService {
  OnboardingService({this.apiClient});

  // ignore: unused_field
  final ApiClient? apiClient;

  OnboardingConfigModel getOnboardingConfig() {
    return const OnboardingConfigModel(
      categories: OnboardingConfigModel.defaultCategories,
      timezones: OnboardingConfigModel.defaultTimezones,
      countries: OnboardingConfigModel.defaultCountries,
    );
  }
}

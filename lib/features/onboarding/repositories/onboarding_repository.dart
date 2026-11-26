import '../models/onboarding_model.dart';
import '../services/onboarding_service.dart';

class OnboardingRepository {
  OnboardingRepository({required this.onboardingService});

  final OnboardingService onboardingService;

  OnboardingConfigModel getConfig() => onboardingService.getOnboardingConfig();
}

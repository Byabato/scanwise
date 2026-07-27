/// Centralized route paths. Screens and the navigation shell should
/// reference these constants rather than repeating string literals.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const scan = '/scan';
  static const library = '/library';
  static const settings = '/settings';

  /// Registered only when `kDebugMode` is true — see app_router.dart.
  static const debugGallery = '/debug/gallery';
}

/// Centralized route paths. Screens and the navigation shell should
/// reference these constants rather than repeating string literals.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const scan = '/scan';
  static const library = '/library';
  static const settings = '/settings';

  /// Registered only when `kDebugMode` is true — see app_router.dart.
  static const debugGallery = '/debug/gallery';

  // Library — real destinations (nested under [library] in app_router.dart).
  static const librarySearch = '/library/search';
  static String libraryScanDetail(String scanId) => '/library/scan/$scanId';
  static String libraryCollectionDetail(String collectionId) =>
      '/library/collection/$collectionId';

  // Settings — real destinations (nested under [settings] in
  // app_router.dart).
  static const settingsPrivacy = '/settings/privacy';
  static const settingsScanning = '/settings/scanning';
  static const settingsHistory = '/settings/history';
  static const settingsAppearance = '/settings/appearance';
  static const settingsPermissions = '/settings/permissions';
  static const settingsFormats = '/settings/formats';
  static const settingsAbout = '/settings/about';
}

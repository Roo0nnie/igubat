import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/navigation/app_router.dart';
import 'package:mobile/services/api/api_client.dart';
import 'package:mobile/services/notifications/notification_service.dart';
import 'package:mobile/services/storage/secure_storage_service.dart';
import 'package:mobile/services/storage/theme_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize awesome_notifications before runApp so channels are registered.
  await NotificationService.instance.initialize();

  // Initialize services in parallel for faster startup
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    Future.value(SecureStorageService()),
  ]);

  final sharedPreferences = results[0] as SharedPreferences;
  final storage = results[1] as SecureStorageService;
  final apiClient = await createApiClient(storage);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        secureStorageProvider.overrideWithValue(storage),
        dioProvider.overrideWithValue(apiClient.dio),
        cookieJarProvider.overrideWithValue(apiClient.cookieJar),
      ],
      child: const App(),
    ),
  );

  // Set up notification action listeners after runApp so navigation and
  // UI updates work correctly when the user taps a notification.
  await NotificationService.instance.setListeners(
    onAction: _handleNotificationAction,
  );
}

/// Global handler for notification tap and action button events.
///
/// This runs on the main isolate after [runApp], so it can route the user to
/// notification targets when the root navigator context is available.
@pragma('vm:entry-point')
Future<void> _handleNotificationAction(ReceivedAction receivedAction) async {
  final payload = receivedAction.payload;
  if (payload == null) return;

  final screen = payload['screen'];
  final notificationType = payload['type'] ?? payload['metadata.type'];
  debugPrint(
    'Notification action received: '
    'buttonKey=${receivedAction.buttonKeyPressed}, '
    'screen=$screen, '
    'type=$notificationType',
  );

  if (notificationType == 'transparency') {
    final slug = payload['slug'] ?? payload['metadata.slug'];
    if (slug == null || slug.isEmpty) return;

    final typeSlug = _transparencyRouteType(
      payload['routeType'] ??
          payload['metadata.routeType'] ??
          payload['transparencyType'] ??
          payload['metadata.transparencyType'] ??
          payload['category'] ??
          payload['metadata.category'],
    );
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    GoRouter.of(
      context,
    ).go('/transparency/$typeSlug/${Uri.encodeComponent(slug)}');
  } else if (notificationType == 'discover_gubat') {
    final slug = payload['slug'] ?? payload['metadata.slug'];
    if (slug == null || slug.isEmpty) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    GoRouter.of(context).go('/discover/${Uri.encodeComponent(slug)}');
  }
}

String _transparencyRouteType(String? value) {
  switch ((value ?? '').toLowerCase().replaceAll('_', '-')) {
    case 'program-project':
    case 'program-projects':
      return 'program-projects';
    case 'bid-procurement':
    case 'bids-projects':
      return 'bids-projects';
    case 'financial-report':
    case 'financial-reports':
      return 'financial-reports';
    case 'annual-budget':
      return 'annual-budget';
    case 'legislative-ordinance':
    case 'legislative-ordinances':
      return 'legislative-ordinances';
    case 'executive-order':
    case 'executive-orders':
      return 'executive-orders';
    default:
      return 'program-projects';
  }
}

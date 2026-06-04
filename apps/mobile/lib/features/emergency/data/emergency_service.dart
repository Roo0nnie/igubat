import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles the external actions reachable from the Emergency Hotline screen:
/// placing calls to hotlines and opening the municipality on a map.
///
/// NOTE: This service does NOT read the device's current location. The map
/// action opens a fixed search for the Municipality of Igubat so a citizen can
/// orient themselves; it does not share the citizen's own coordinates with
/// responders. The UI copy is worded accordingly (see [openMunicipalityMap]).
///
/// All methods are resilient: if no app can handle the intent (e.g. a tablet
/// without a dialer), the user is shown a SnackBar instead of the call
/// silently failing.
class EmergencyService {
  const EmergencyService._();

  /// Strips formatting characters so `(056) 311-1234` becomes a dialable
  /// `0563111234`. A leading `+` is preserved for international numbers.
  static String sanitizeNumber(String number) {
    final hasPlus = number.trim().startsWith('+');
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    return hasPlus ? '+$digits' : digits;
  }

  /// Opens the phone dialer pre-filled with [number]. Returns `true` if the
  /// dialer was launched.
  static Future<bool> call(BuildContext context, String number) async {
    final sanitized = sanitizeNumber(number);
    final uri = Uri(scheme: 'tel', path: sanitized);
    return _launch(
      context,
      uri,
      failureMessage: 'Could not open the dialer for $number.',
    );
  }

  /// Opens a maps app centered on the Municipality of Igubat so a citizen can
  /// reference the municipality on a map. This does NOT use the device's
  /// current location and does not share the citizen's coordinates. Falls back
  /// to the browser when no native maps app is installed.
  static Future<bool> openMunicipalityMap(BuildContext context) async {
    const query = 'Municipality of Igubat, Sorsogon';
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    return _launch(
      context,
      webUri,
      failureMessage: 'Could not open a maps app.',
    );
  }

  static Future<bool> _launch(
    BuildContext context,
    Uri uri, {
    required String failureMessage,
  }) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showError(context, failureMessage);
      }
      return launched;
    } catch (_) {
      if (context.mounted) {
        _showError(context, failureMessage);
      }
      return false;
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

import 'package:in_app_review/in_app_review.dart';
import 'package:mobo_projects/core/globalkey/global_keys.dart';
import 'package:mobo_projects/shared/widgets/dialogs/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();

  factory ReviewService() => _instance;

  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;

  /// Keys for SharedPreferences
  static const String _keyOpenCount = 'review_open_count';
  static const String _keyEventCount = 'review_event_count';
  static const String _keyFirstOpenDate = 'review_first_open_date';
  static const String _keyLastRequestDate = 'review_last_request_date';
  static const String _keyNeverAskAgain = 'review_never_ask_again';

  /// Thresholds
  static const int _thresholdOpens = 5;
  static const int _thresholdEvents = 5;
  static const int _thresholdDays = 5;

  bool _wasRequestedThisRun = false;

  Future<void> trackAppOpen() async {
    final prefs = await SharedPreferences.getInstance();

    /// 1. First Open Date
    if (!prefs.containsKey(_keyFirstOpenDate)) {
      await prefs.setInt(
        _keyFirstOpenDate,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    /// 2. Increment Open Count
    int currentOpens = prefs.getInt(_keyOpenCount) ?? 0;
    currentOpens++;
    await prefs.setInt(_keyOpenCount, currentOpens);
  }

  Future<void> trackSignificantEvent() async {
    final prefs = await SharedPreferences.getInstance();

    /// Increment Event Count
    int currentEvents = prefs.getInt(_keyEventCount) ?? 0;
    currentEvents++;
    await prefs.setInt(_keyEventCount, currentEvents);
  }

  Future<void> _checkAndRequestReview(
    SharedPreferences prefs, [
    BuildContext? context,
  ]) async {
    if (_wasRequestedThisRun) {
      return;
    }

    if (prefs.getBool(_keyNeverAskAgain) ?? false) {
      return;
    }

    if (await _inAppReview.isAvailable()) {
      bool shouldRequest = false;

      /// Criteria 1: Nth usage (open)
      int openCount = prefs.getInt(_keyOpenCount) ?? 0;
      if (openCount >= _thresholdOpens) {
        shouldRequest = true;
      }

      /// Criteria 2: Nth significant event
      int eventCount = prefs.getInt(_keyEventCount) ?? 0;

      if (eventCount >= _thresholdEvents) {
        shouldRequest = true;
      }

      /// Criteria 3: N days usage
      int? firstOpenEpoch = prefs.getInt(_keyFirstOpenDate);
      if (firstOpenEpoch != null) {
        final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(
          firstOpenEpoch,
        );
        final diff = DateTime.now().difference(firstOpenDate).inDays;
        if (diff >= _thresholdDays) {
          shouldRequest = true;
        }
      } else {}

      if (shouldRequest) {
        int? lastRequestEpoch = prefs.getInt(_keyLastRequestDate);
        if (lastRequestEpoch != null) {
          final lastRequest = DateTime.fromMillisecondsSinceEpoch(
            lastRequestEpoch,
          );
          final daysSinceLastRequest = DateTime.now()
              .difference(lastRequest)
              .inDays;

          /// Request again only if it's been a long time (e.g. 30 days)
          if (daysSinceLastRequest < 30) {
            return;
          }
        } else {}

        if (context != null && context.mounted) {
          _wasRequestedThisRun = true;

          /// Update last request date to enforce cooldown period
          await prefs.setInt(
            _keyLastRequestDate,
            DateTime.now().millisecondsSinceEpoch,
          );

          CustomRatingDialog.show(context);
        }
      }
    }
  }

  /// Track app open and show dialog if criteria met
  Future<void> checkAndShowRating(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndRequestReview(prefs, context);
  }

  /// Force a review request. If the native dialog is suppressed by quotas,
  /// it will fall back to opening the Store Listing directly.
  Future<void> forceRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _keyLastRequestDate,
      DateTime.now().millisecondsSinceEpoch,
    );

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text('🔄 Requesting Store review...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue[700],
      ),
    );

    try {
      if (await _inAppReview.isAvailable()) {
        _wasRequestedThisRun = true;

        await Future.delayed(const Duration(milliseconds: 2500));

        await _inAppReview.requestReview();
      } else {
        await openStoreListing();
      }
    } catch (e) {
      await openStoreListing();
    }
  }

  /// Opens the store listing directly. Use this as a fallback or for a "Rate Us" button.
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {}
  }

  /// Send email feedback for low ratings (1-3 stars)
  Future<void> sendEmailFeedback(double rating, String comment) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'cybroplay@gmail.com',

        /// Updated support email
        query: encodeQueryParameters(<String, String>{
          'subject':
              'Feedback for Odoo Mobile Community (${rating.toInt()} Stars)',
          'body':
              'Rating: ${rating.toInt()}/5\n\nComment:\n$comment\n\n---\nSent from Odoo Mobile Community',
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {}
    } catch (e) {}
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  /// Permanently disable future review requests
  Future<void> neverAskAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNeverAskAgain, true);
  }

  /// Debug method to print current review tracking statistics
  Future<void> printReviewStats() async {
    final prefs = await SharedPreferences.getInstance();

    int openCount = prefs.getInt(_keyOpenCount) ?? 0;
    int eventCount = prefs.getInt(_keyEventCount) ?? 0;
    int? firstOpenEpoch = prefs.getInt(_keyFirstOpenDate);
    int? lastRequestEpoch = prefs.getInt(_keyLastRequestDate);

    if (firstOpenEpoch != null) {
      final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpenEpoch);
      final daysSinceFirst = DateTime.now().difference(firstOpenDate).inDays;
    } else {}

    if (lastRequestEpoch != null) {
      final lastRequestDate = DateTime.fromMillisecondsSinceEpoch(
        lastRequestEpoch,
      );
    } else {}
  }

  /// Reset all review tracking data (useful for testing)
  Future<void> resetReviewTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOpenCount);
    await prefs.remove(_keyEventCount);
    await prefs.remove(_keyFirstOpenDate);
    await prefs.remove(_keyLastRequestDate);
    await prefs.remove(_keyNeverAskAgain);
  }
}

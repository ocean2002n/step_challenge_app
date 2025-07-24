import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('step_challenge_deep_links');
  static const String _appStoreUrl = 'https://apps.apple.com/app/step-challenge/id123456789';
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.stepchallenge.app';
  
  StreamController<String>? _linkStreamController;
  Stream<String>? _linkStream;

  Stream<String> get linkStream {
    _linkStreamController ??= StreamController<String>.broadcast();
    _linkStream ??= _linkStreamController!.stream;
    return _linkStream!;
  }

  // Initialize deep link handling
  Future<void> initialize() async {
    try {
      // Listen for incoming links when app is already running
      _channel.setMethodCallHandler(_handleMethodCall);
      
      // Get initial link when app is launched from deep link
      try {
        final String? initialLink = await _channel.invokeMethod('getInitialLink');
        if (initialLink != null) {
          _linkStreamController?.add(initialLink);
        }
      } catch (e) {
        debugPrint('Native deep link not available, using fallback: $e');
        // This is expected when native implementation is not available
      }
    } catch (e) {
      debugPrint('Error initializing deep link service: $e');
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNewLink':
        final String link = call.arguments;
        _linkStreamController?.add(link);
        break;
    }
  }

  // Parse invite code from deep link or universal link
  String? parseInviteCodeFromLink(String link) {
    try {
      final uri = Uri.parse(link);
      
      // Handle stepchallenge:// scheme
      if (uri.scheme == 'stepchallenge') {
        return uri.queryParameters['code'];
      }
      
      // Handle https:// universal links
      if (uri.scheme == 'https' && uri.host == 'stepchallenge.app') {
        return uri.queryParameters['code'];
      }
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
    }
    return null;
  }

  // Open app store for user without app installed
  Future<void> openAppStore() async {
    try {
      String storeUrl;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        storeUrl = _appStoreUrl;
      } else {
        storeUrl = _playStoreUrl;
      }
      
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening app store: $e');
    }
  }

  // Generate universal link with app store fallback
  String generateUniversalLink(String inviteCode) {
    return 'https://stepchallenge.app/invite?code=$inviteCode';
  }

  // Generate deep link for direct app opening
  String generateDeepLink(String inviteCode) {
    return 'stepchallenge://invite?code=$inviteCode';
  }

  void dispose() {
    _linkStreamController?.close();
  }
}
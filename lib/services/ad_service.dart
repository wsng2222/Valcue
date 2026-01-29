import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service for managing interstitial ads (test ads only)
/// 
/// This service handles preloading and showing test interstitial ads.
/// Uses Google's official test ad unit IDs only - no real ad IDs.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  bool _isLoading = false;

  // Google's official test ad unit IDs
  static const String _androidTestAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

  /// Get the appropriate test ad unit ID based on platform
  String get _adUnitId {
    if (Platform.isAndroid) {
      return _androidTestAdUnitId;
    } else if (Platform.isIOS) {
      return _iosTestAdUnitId;
    } else {
      // Fallback to Android test ID for other platforms
      return _androidTestAdUnitId;
    }
  }

  /// Check if an ad is ready to be shown
  bool get isAdReady => _isAdReady && _interstitialAd != null;

  /// Preload an interstitial ad
  /// This should be called early (e.g., in app initialization or screen initState)
  void loadAd() {
    // Prevent multiple simultaneous loads
    if (_isLoading || _isAdReady) {
      debugPrint('AdService: Skipping load - isLoading: $_isLoading, isAdReady: $_isAdReady');
      return;
    }

    try {
      _isLoading = true;
      _isAdReady = false;
      debugPrint('AdService: Loading ad with unit ID: $_adUnitId');

      InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('AdService: Ad loaded successfully!');
          _interstitialAd = ad;
          _isAdReady = true;
          _isLoading = false;
          // Don't set callbacks here - they will be set in showAd()
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdService: Ad failed to load: ${error.code} - ${error.message}');
          // Ad failed to load - this is expected sometimes
          // Just reset state and allow workout to proceed without ad
          _interstitialAd = null;
          _isAdReady = false;
          _isLoading = false;
          // Don't retry immediately to avoid spam
        },
      ),
    );
    } catch (e) {
      debugPrint('AdService: Exception while loading ad: $e');
      // If ad loading fails completely, just reset state
      // App should continue to work without ads
      _interstitialAd = null;
      _isAdReady = false;
      _isLoading = false;
    }
  }

  /// Show the interstitial ad if ready
  /// 
  /// Returns true if ad was shown, false if ad was not ready or failed to show.
  /// The [onAdClosed] callback is called when the ad is dismissed or fails to show.
  bool showAd({VoidCallback? onAdClosed}) {
    debugPrint('AdService: showAd called - isAdReady: $isAdReady, _interstitialAd: ${_interstitialAd != null}');
    
    if (!isAdReady || _interstitialAd == null) {
      debugPrint('AdService: Ad not ready, proceeding without ad');
      // Ad not ready, call callback immediately to proceed with workout
      onAdClosed?.call();
      return false;
    }

    try {
      final ad = _interstitialAd;
      if (ad != null) {
        debugPrint('AdService: Attempting to show ad');
        
        // Store the callback to ensure it's called
        final callback = onAdClosed;
        
        // Set callback for when ad is closed - MUST be set before show()
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            debugPrint('AdService: Ad dismissed in showAd - calling onAdClosed');
            ad.dispose();
            _interstitialAd = null;
            _isAdReady = false;
            // Call the callback to navigate to workout
            if (callback != null) {
              callback();
            }
            // Preload next ad
            loadAd();
          },
          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
            debugPrint('AdService: Ad failed to show in showAd: ${error.message} - calling onAdClosed');
            ad.dispose();
            _interstitialAd = null;
            _isAdReady = false;
            // Call the callback to navigate to workout even if ad failed
            if (callback != null) {
              callback();
            }
            // Preload next ad
            loadAd();
          },
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            debugPrint('AdService: Ad showed in showAd');
          },
        );
        
        // Show the ad
        ad.show();
        debugPrint('AdService: ad.show() called');
        return true;
      }
    } catch (e) {
      debugPrint('AdService: Exception while showing ad: $e');
      // If anything goes wrong, ensure workout can proceed
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdReady = false;
    }

    // If we get here, ad wasn't shown - proceed with workout
    debugPrint('AdService: Ad was not shown, proceeding without ad');
    onAdClosed?.call();
    return false;
  }

  /// Dispose of the current ad (if any)
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _isLoading = false;
  }
}


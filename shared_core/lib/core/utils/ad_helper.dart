import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-4382706056055226/3868639610';
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-4382706056055226/1774830873';
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOOGLE MOBILE ADS (HOW-TO DEMO)
// ─────────────────────────────────────────────────────────────────────────────

/*
/// 1. BANNER ADS
/// Simply place `CustomBannerAd()` anywhere in your UI. It automatically handles 
/// loading and sizing. Below is an example of placing it at the bottom of a screen.
class DemoBannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner Ad Example')),
      body: const Center(
        child: Text('Content goes here...'),
      ),
      // Placed at the bottom inside safe navigation area:
      bottomNavigationBar: const CustomBannerAd(),
    );
  }
}

/// 2. INTERSTITIAL ADS (FULL SCREEN)
/// Pre-load the ad as early as possible so it is instantly ready when you need it.
/// Usually, you load it inside your `initState`.
class DemoInterstitialScreen extends StatefulWidget {
  @override
  State<DemoInterstitialScreen> createState() => _DemoInterstitialScreenState();
}

class _DemoInterstitialScreenState extends State<DemoInterstitialScreen> {
  @override
  void initState() {
    super.initState();
    // 1. Preload the interstitial ad natively:
    sl<AdManager>().loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 2. Show the ad to the user instantly (E.g. upon submitting a form, or reading an article)
            sl<AdManager>().showInterstitialAd();
          },
          child: const Text('Show Interstitial Ad'),
        ),
      ),
    );
  }
}
*/

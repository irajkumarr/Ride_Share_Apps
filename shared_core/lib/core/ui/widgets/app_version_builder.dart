// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';

// class AppVersionBuilder extends StatefulWidget {
//   final TextStyle? style;

//   const AppVersionBuilder({super.key, this.style});

//   @override
//   State<AppVersionBuilder> createState() => _AppVersionBuilderState();
// }

// class _AppVersionBuilderState extends State<AppVersionBuilder> {
//   String version = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     final deviceInfo = DeviceInfoPlugin();
//     String infoText = '';
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfo.androidInfo;
//         infoText = 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfo.iosInfo;
//         infoText = '${iosInfo.systemName} ${iosInfo.systemVersion}';
//       } else {
//         infoText = 'v1.0.0';
//       }
//     } catch (_) {
//       infoText = 'v1.0.0';
//     }

//     if (mounted) {
//       setState(() {
//         version = infoText;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       version.isEmpty ? '' : 'Version: $version',
//       style: widget.style ?? Theme.of(context).textTheme.bodySmall,
//       textAlign: TextAlign.center,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionBuilder extends StatefulWidget {
  final TextStyle? style;

  const AppVersionBuilder({super.key, this.style});

  @override
  State<AppVersionBuilder> createState() => _AppVersionBuilderState();
}

class _AppVersionBuilderState extends State<AppVersionBuilder> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final versionName = packageInfo.version;
      // final buildNumber = packageInfo.buildNumber;

      if (mounted) {
        setState(() {
          version = versionName;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          version = '1.0.0';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      version.isEmpty ? '' : 'v$version',
      style: widget.style ?? Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}

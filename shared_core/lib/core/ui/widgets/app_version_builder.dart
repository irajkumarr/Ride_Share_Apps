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
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version; // already clean
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      version.isEmpty ? '' : 'Version: $version',
      style: widget.style ?? Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}

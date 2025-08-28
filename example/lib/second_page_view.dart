import 'package:flutter/material.dart';
import 'package:screenshot_guard/screenshot_guard.dart';

class SecondPageView extends StatefulWidget {
  const SecondPageView({super.key});

  @override
  State<SecondPageView> createState() => _SecondPageViewState();
}

class _SecondPageViewState extends State<SecondPageView> {
  final _screenshotGuardPlugin = ScreenshotGuard();

  @override
  void initState() {
    super.initState();
    _screenshotGuardPlugin.enableSecureFlag(enable: false);
  }

  @override
  void dispose() {
    _screenshotGuardPlugin.enableSecureFlag(enable: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true, title: const Text('Second Page')),
      body: const Center(child: Text('This is the second page that allows screenshots.')),
    );
  }
}

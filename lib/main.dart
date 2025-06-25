import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'police_map_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency SOS',
      debugShowCheckedModeBanner: false,
      home: RadarHomePage(),
    );
  }
}

class RadarHomePage extends StatelessWidget {
  final double imageSize = 150;

  void _launchDialer() async {
    final Uri uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Dialer could not be launched");
    }
  }

  void _handleRadarTap(BuildContext context) {
    _launchDialer(); // open dialer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoliceMapScreen()),
    ); // show map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _handleRadarTap(context),
          child: Image.asset(
            'assets/radar.png',
            width: imageSize,
            height: imageSize,
          ),
        ),
      ),
    );
  }
}

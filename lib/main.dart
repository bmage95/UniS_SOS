import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'police_map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony/telephony.dart';

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
  final Telephony telephony = Telephony.instance;

  final List<String> emergencyContacts = [
    '+919811403774',
    '+919404738170'
  ];

  void _launchDialer() async {
    final Uri uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Dialer could not be launched");
    }
  }

  Future<void> _sendEmergencySMS() async {
    final bool? smsPermission = await telephony.requestSmsPermissions;

    if (!smsPermission!) {
      print("❌ SMS permission not granted");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final message =
          "🚨 Emergency!\nLat: ${position.latitude}, Long: ${position.longitude}";

      for (final number in emergencyContacts) {
        await telephony.sendSms(to: number, message: message);
      }

      print("✅ SMS sent to emergency contacts.");
    } catch (e) {
      print("⚠️ Error sending SMS: $e");
    }
  }

  void _handleRadarTap(BuildContext context) {
    _launchDialer(); // 1. Open dialer
    _sendEmergencySMS(); // 2. Send auto SMS
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PoliceMapScreen()),
    ); // 3. Show police station map
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

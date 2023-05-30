import 'dart:convert';
import 'dart:io' as io;
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swift_face_liveness/amplify_configuration.dart';
import 'package:flutter_swift_face_liveness/face_liveness_session_screen.dart';
import 'package:flutter_swift_face_liveness/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  static const authPlatformChannel = MethodChannel('com.example.flutterSwiftFaceLiveness/auth');
  static const navPlatformChannel =
      MethodChannel('com.example.flutterSwiftFaceLiveness/navigation');
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (await Permission.camera.request().isGranted) {
          safePrint('Camera permission granted');
        }
      } catch (e) {
        debugPrint('Camera permission request failed: $e');
      }
    });
  }

  Future<void> _configureAmplify() async {
    try {
      final api = AmplifyAPI();
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugins([api, auth]);
      await Amplify.configure(amplifyConfig);
      if (io.Platform.isIOS) {
        try {
          final configureNativeAmplifyResult = await MainApp.authPlatformChannel.invokeMethod(
            'configureNativeAmplify',
            {'amplify_config': amplifyConfig},
          );
          safePrint('Configure native Amplify result: $configureNativeAmplifyResult');
        } catch (e, stack) {
          safePrint('Configure native Amplify error: $e, $stack');
        }
      }
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomeScreen.routeName: (ctx) => const HomeScreen(),
        LivenessDetectionScreen.routeName: (ctx) => const LivenessDetectionScreen(),
      },
      home: const HomeScreen(),
    );
  }
}

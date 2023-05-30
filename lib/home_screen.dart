import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'face_liveness_session_screen.dart';
import 'main.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _openFaceLivenessSession,
              child: const Text('Open via Platform Channels'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LivenessDetectionScreen.routeName);
              },
              child: const Text('Open via Platform Views'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFaceLivenessSession() async {
    try {
      try {
        await Amplify.Auth.signOut();
      } catch (e) {}
      final signInResult = await Amplify.Auth.signIn(
        username: '',
        password: '',
      );
      if (signInResult.isSignedIn) {
        safePrint('User is signed in');
      }
      final authSession = await Amplify.Auth.getPlugin(
        AmplifyAuthCognito.pluginKey,
      ).fetchAuthSession();
      final sessionCredentials = authSession.credentialsResult.value.toJson();
      safePrint(sessionCredentials);

      final String setFaceLivenessCredentialsResult =
          await MainApp.authPlatformChannel.invokeMethod(
        'setFaceLivenessCredentials',
        sessionCredentials,
      );
      debugPrint('setFaceLivenessCredentialsResult: $setFaceLivenessCredentialsResult');

      final request = Amplify.API.post(
        '/users/faceLiveness',
        body: HttpPayload.json({
          'userId': authSession.userSubResult.value,
        }),
      );
      final response = await request.response;
      final decodedResponse = json.decode(response.decodeBody()) as Map<String, dynamic>;
      final sessionId = decodedResponse["SessionId"];

      await MainApp.authPlatformChannel.invokeMethod(
        'setFaceLivenessSessionId',
        {'session_id': sessionId},
      );
      await MainApp.navPlatformChannel.invokeMethod('startLivenesDetection');
    } catch (e) {
      safePrint('An error occurred opening face liveness session: $e');
    }
  }
}

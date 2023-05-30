import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class LivenessDetectionScreen extends StatefulWidget {
  static const String routeName = '/liveness-detection';

  const LivenessDetectionScreen({super.key});

  @override
  State<LivenessDetectionScreen> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  Future<Map<String, dynamic>> _getFaceLivenessData() async {
    try {
      try {
        await Amplify.Auth.signOut();
      } catch (e) {}
      final signInResult = await Amplify.Auth.signIn(
        username: '',
        password: '',
      );
      if (signInResult.isSignedIn) {
        final authSession = await Amplify.Auth.getPlugin(
          AmplifyAuthCognito.pluginKey,
        ).fetchAuthSession();
        final sessionCredentials = authSession.credentialsResult.value.toJson();
        safePrint(sessionCredentials);

        // final String authResult = await MyApp.authPlatformChannel.invokeMethod(
        //   'setFaceLivenessCredentials',
        //   sessionCredentials,
        // );
        // debugPrint('Auth result: $authResult ');

        final request = Amplify.API.post(
          '/users/faceLiveness',
          body: HttpPayload.json({
            'userId': authSession.userSubResult.value,
          }),
        );
        final response = await request.response;
        final decodedResponse = json.decode(response.decodeBody()) as Map<String, dynamic>;
        final sessionId = decodedResponse["SessionId"];

        sessionCredentials.addAll({
          'session_id': sessionId,
        });
        // emit(state.copyWith(sessionId: sessionId));
        // await MyApp.authPlatformChannel.invokeMethod(
        //   'setFaceLivenessSessionId',
        //   {'session_id': sessionId},
        // );
        // await MyApp.navPlatformChannel.invokeMethod('startLivenesDetection');
        return sessionCredentials;
      }
      throw Exception('User is not signed in');
    } catch (e) {
      safePrint('START FACE LIVENESS SESSION EXCEPTION: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder(
          future: _getFaceLivenessData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If we got an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );

                // if we got our data
              } else if (snapshot.hasData) {
                // Extracting data from snapshot object
                debugPrint('========= SNAPSHOT HAS DATA =========');
                final data = snapshot.data as Map<String, dynamic>;
                debugPrint(data.toString());
                return UiKitView(
                  viewType: '@views/face-liveness-native-view',
                  layoutDirection: TextDirection.ltr,
                  creationParams: data,
                  gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                    Factory(
                      EagerGestureRecognizer.new,
                    ),
                  },
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: (id) {
                    debugPrint("========= ON PLATFORM VIEW CREATED $id ==========");
                  },
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

# flutter_swift_face_liveness

## Steps to configure

1. On the amplify_configuration.dart file replace the needed ids and the api part of the json string could be removed, i used it to create the liveness session through API gateway and get a session id. Lines 62-70 are used to create the session and get the session id.
2. On the home_screen.dart file, replace username and password on \_openFaceLivenessSession function.
3. On the face_liveness_session_screen.dart file, replace username and password on \_getFaceLivenessData function. Lines 42-50 are used to create the session and get the session id.

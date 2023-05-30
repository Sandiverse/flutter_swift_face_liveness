import Amplify
import AWSCognitoAuthPlugin
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var isAmplifyConfigured = false
    var faceLivenessSessionId: String?
    var customAWSCredentials: CustomAWSCredentials?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      let authChannel = FlutterMethodChannel(name: "com.example.flutterSwiftFaceLiveness/auth",
                                             binaryMessenger: controller.binaryMessenger)
      let navigationChannel = FlutterMethodChannel(name: "com.example.flutterSwiftFaceLiveness/navigation",
                                                   binaryMessenger: controller.binaryMessenger)
      navigationChannel.setMethodCallHandler {
                  (call: FlutterMethodCall, result: FlutterResult) in
                  switch call.method {
                  case "startLivenesDetection":
                      guard let sessionId = self.faceLivenessSessionId else {
                          result(FlutterError(code: "NOT_FOUND", message: "Face Liveness session ID is null", details: nil))
                          return
                      }
                      guard let awsCredentials = self.customAWSCredentials else {
                          result(FlutterError(code: "NOT_FOUND", message: "AWS Credentials are null", details: nil))
                          return
                      }
      //                let uiView = UIView()
      //                uiView.backgroundColor = UIColor.black
                      let faceLivenessController = FaceLivenessDetectionController(sessionId: sessionId,
                                                                                   awsCredentials: awsCredentials)
      //                uiView.addSubview(faceLivenessController.view)
                      controller.present(faceLivenessController,
                                                 animated: true,
                                                 completion: nil)
                  // if let window = UIApplication.shared.windows.first {
                  //     window.rootViewController = faceLivenessController
                  //     window.makeKeyAndVisible()
                  // }
                  default:
                      result(FlutterMethodNotImplemented)
                  }
              }
      authChannel.setMethodCallHandler {
                  (call: FlutterMethodCall, result: @escaping FlutterResult) in
                  // This method is invoked on the UI thread.
                  switch call.method {
                  case "configureNativeAmplify":
                      if let arguments = call.arguments as? [String: Any] {
                          if self.isAmplifyConfigured {
                              result("Amplify is already configured")
                              return
                          }
                          guard let amplifyConfigJsonString = arguments["amplify_config"] as? String else {
                              result(FlutterError(code: "NOT_FOUND", message: "Amplify configuration is null", details: nil))
                              return
                          }
                          do {
                              if let amplifyConfigJsonData = amplifyConfigJsonString.data(using: .utf8) {
                                  let amplifyConfiguration = try JSONDecoder().decode(AmplifyConfiguration.self, from: amplifyConfigJsonData)
      //                            print(amplifyConfigJsonData)
                                  print(amplifyConfiguration)
                                  try Amplify.add(plugin: AWSCognitoAuthPlugin())
                                  try Amplify.configure(amplifyConfiguration)
                                  self.isAmplifyConfigured = true
                                  result("Amplify configured successfully")
                              } else {
                                  result(FlutterError(code: "FAILED", message: "Failed to convert Amplify configuration JSON string to data", details: nil))
                              }
                          } catch {
                              result(FlutterError(code: "FAILED", message: "Failed to configure Amplify: \(error.localizedDescription)", details: error))
                          }
                      }
//                  case "startNativeUserSession":
//                      self.signIn(flutterResult: result)
                  // Amplify.Auth.signOut { signOutResult in
                  //     guard let convertedSignOutResult = signOutResult as? AWSCognitoSignOutResult
                  //     else {
                  //         print("Signout failed")
                  //         result(FlutterError(code: "FAILED", message: "Signout failed", details: nil))
                  //         return
                  //     }
                  //     print("Local signout successful: \(convertedSignOutResult.signedOutLocally)")
                  //     switch convertedSignOutResult {
                  //     case .complete:
                  //         print("Signed out successfully")
                  //         Amplify.Auth.signIn(
                  //             username: "",
                  //             password: ""
                  //         ) { signInResult in
                  //             switch signInResult {
                  //             case let .success(signInResult):
                  //                 if signInResult.isSignedIn {
                  //                     print("Sign in succeeded")
                  //                     result("User native session started successfully")
                  //                 }
                  //             case let .failure(error):
                  //                 if let authError = error as? AuthError {
                  //                     print("Sign in failed \(authError)")
                  //                     result(FlutterError(code: "FAILED", message: "Signin failed: \(authError)", details: authError))
                  //                 } else {
                  //                     print("Unexpected error: \(error)")
                  //                     result(FlutterError(code: "FAILED", message: "Signin failed: \(error)", details: error))
                  //                 }
                  //             }
                  //         }
                  //     case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
                  //         result(FlutterError(code: "FAILED", message: "Signout failed: partial signout", details: nil))
                  //     case let .failed(error):
                  //         result(FlutterError(code: "FAILED", message: "Signout failed: \(error)", details: error))
                  //     }
                  // }
                  case "setFaceLivenessSessionId":
                      if let arguments = call.arguments as? [String: Any] {
                          let sessionId = arguments["session_id"] as? String
                          self.faceLivenessSessionId = sessionId
                          result("Face liveness session ID \(sessionId) was set successfully")
                      }
                  case "setFaceLivenessCredentials":
                      if let arguments = call.arguments as? [String: Any] {
                          let secretAccessKey = arguments["secret_access_key"] as? String
                          let accessKeyId = arguments["access_key_id"] as? String
                          let sessionToken = arguments["token"] as? String
                          let expiration = arguments["expiration"] as? String

                          var expirationAsDate: Date? = nil
                          if let expiration = expiration {
                              let format = DateFormatter()
                              format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                              format.timeZone = TimeZone(identifier: "UTC")
                              expirationAsDate = format.date(from: expiration)
                          }

                          self.customAWSCredentials = CustomAWSCredentials(
                              secretAccessKey: secretAccessKey,
                              sessionToken: sessionToken,
                              accessKeyId: accessKeyId,
                              expiration: expirationAsDate
                          )
                          result("AWS Credentials \(secretAccessKey), \(sessionToken), \(accessKeyId), \(expiration) were set successfully")
                      }
                  default:
                      result(FlutterMethodNotImplemented)
                  }
              }
      GeneratedPluginRegistrant.register(with: self)
      
      // This is to register the Swift Face Liveness Detection platform view
      weak var registrar = self.registrar(forPlugin: "com.example.flutterSwiftFaceLiveness/platform-views")

              let factory = FLFaceLivenessViewFactory(messenger: registrar!.messenger())
              registrar!.register(
                  factory,
                  withId: "@views/face-liveness-native-view")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

//
//  FaceLivenessDetection.swift
//  Runner
//
//  Created by Sandy Oswaldo Valdez Gaitan on 9/5/23.
//

import Amplify
import AWSCognitoAuthPlugin
import FaceLiveness
import SwiftUI

struct FaceLivenessDetectionView: View {
//    @StateObject private var viewModel = FaceLivenessDetectionViewModel()
    var sessionId: String?
    var awsCredentials: CustomAWSCredentials?

    var body: some View {
        if let livenessSessionId = sessionId,
           let credentials = awsCredentials,
           let accessKeyId = credentials.accessKeyId,
           let secretAccessKey = credentials.secretAccessKey,
           let sessionToken = credentials.sessionToken,
           let expiration = credentials.expiration
//        if self.viewModel.isLoading, !self.viewModel.error.isEmpty, !self.viewModel.isSignedIn
        {
//            Text("Empty View")
//                .font(.largeTitle)
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .edgesIgnoringSafeArea(.all)
//                .onAppear {
//                    Task {
//                        await self.viewModel.signIn(username: "sandy.ovg@gmail.com", password: "Test123@")
//                    }
//                }
//        } else if let livenessSessionId = sessionId {
//            EmptyView()
            FaceLivenessDetectorView(
                sessionID: livenessSessionId,
                credentialsProvider: FlutterAWSCredentialsProvider(credentials: credentials),
                region: "us-east-1",
                disableStartView: true,
                isPresented: .constant(true),
                onCompletion: { result in
                    switch result {
                    case .success:
                        print("Face liveness session success")
                    case let .failure(error):
                        print("Face liveness session error: \(error)")
                    default:
                        print("Face liveness session default")
                    }
                }
            )
        } else {
            Text("Liveness session not started")
                .font(.largeTitle)
                .foregroundColor(.white)
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
        }
    }

    init(sessionId: String?, awsCredentials: CustomAWSCredentials?) {
        self.sessionId = sessionId
        self.awsCredentials = awsCredentials
    }
}

class FaceLivenessDetectionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isSignedIn = false
    @Published var error = ""

    func signIn(username: String, password: String) async {
        self.isLoading = true

        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // Sign Out completed fully and without errors.
            print("Signed out successfully")
            do {
                let signInResult = try await Amplify.Auth.signIn(
                    username: username,
                    password: password
                )
                if signInResult.isSignedIn {
                    print("Sign in succeeded")
                    self.isSignedIn = signInResult.isSignedIn
                    self.isLoading = false
                }
            } catch let error as AuthError {
                print("Sign in failed \(error)")
                self.error = "Sign in failed \(error)"
                self.isLoading = false
            } catch {
                print("Unexpected error: \(error)")
            }

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // Sign Out completed with some errors. User is signed out of the device.

            if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))")
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                print("GlobalSignOut error  \(String(describing: globalSignOutError))")
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                print("Revoke token error  \(String(describing: revokeTokenError))")
            }

        case let .failed(error):
            // Sign Out failed with an exception, leaving the user signed in.
            print("SignOut failed with \(error)")
        }

//        return Amplify.Publisher.create {
//            try await Amplify.Auth.signIn(
//                username: username,
//                password: password
//            )
//        }
//        .receive(on: DispatchQueue.main)
//        .sink {
//            if case let .failure(authError) = $0 {
//                print("Sign in failed \(authError)")
//                self.error = "Sign in failed \(authError)"
//                self.isLoading = false
//            }
//            print("Unexpected error: \(error)")
//        }
//        receiveValue: { signInResult in
//            if signInResult.isSignedIn {
//                print("Sign in succeeded")
//                self.isSignedIn = signInResult.isSignedIn
//                self.isLoading = false
//            }
//        }
    }
}

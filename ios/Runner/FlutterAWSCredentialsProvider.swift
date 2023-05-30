//
//  FlutterAWSCredentialsProvider.swift
//  Runner
//
//  Created by Sandy Oswaldo Valdez Gaitan on 9/5/23.
//
import Amplify
import AWSPluginsCore

struct FlutterAWSCredentialsProvider: AWSCredentialsProvider {
    private let credentials: CustomAWSCredentials

    init(credentials: CustomAWSCredentials) {
        self.credentials = credentials
    }

    func fetchAWSCredentials() async throws -> AWSCredentials {
        guard let secretAccessKey = credentials.secretAccessKey,
              let accessKeyId = credentials.accessKeyId,
              let sessionToken = credentials.sessionToken,
              let expiration = credentials.expiration
        else {
            throw FlutterAWSCredentialsError(
                errorDescription: "Fetch AWS Credentials failed with null aws credentials",
                recoverySuggestion: "Make sure the parameters of Custom AWS Credentials are setup correctly",
                error: NSError(domain: "io.uniio.pay", code: 400, userInfo: nil)
            )
        }
        let awsCredentials = FlutterAWSCredentials(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            sessionToken: sessionToken,
            expiration: expiration
        )
        print(awsCredentials.accessKeyId)
        print(awsCredentials.secretAccessKey)
        print(awsCredentials.sessionToken)
        print(awsCredentials.expiration)
        return awsCredentials
    }
}

struct FlutterAWSCredentials: AWSCredentials, AWSTemporaryCredentials {
    let accessKeyId: String
    let secretAccessKey: String
    let sessionToken: String
    let expiration: Date

    init(accessKeyId: String, secretAccessKey: String, sessionToken: String, expiration: Date) {
        self.accessKeyId = accessKeyId
        self.secretAccessKey = secretAccessKey
        self.sessionToken = sessionToken
        self.expiration = expiration
    }
}

final class FlutterAWSCredentialsError: AmplifyError {
    let errorDescription: ErrorDescription
    let recoverySuggestion: RecoverySuggestion
    let underlyingError: Error?

    var debugDescription: String {
        let underlyingErrorString = underlyingError?.localizedDescription ?? "Unknown"
        return """
        FlutterAWSCredentialsError(
            errorDescription: \(errorDescription),
            recoverySuggestion: \(recoverySuggestion),
            underlyingError: \(underlyingErrorString)
        )
        """
    }

    required init(errorDescription: ErrorDescription, recoverySuggestion: RecoverySuggestion, error: Error) {
        self.errorDescription = errorDescription
        self.recoverySuggestion = recoverySuggestion
        self.underlyingError = error
    }
}

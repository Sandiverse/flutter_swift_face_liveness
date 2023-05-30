//
//  FLFaceLivenessView.swift
//  Runner
//
//  Created by Sandy Oswaldo Valdez Gaitan on 18/5/23.
//

import Flutter
import SwiftUI
import UIKit

struct FaceLivenessRepresentable: UIViewRepresentable {
    var sessionId: String?
    var awsCredentials: CustomAWSCredentials?

    func makeUIView(context: Context) -> UIView {
        // Create and return your SwiftUI view wrapped in a UIView
        let myView = FaceLivenessDetectionView(sessionId: sessionId,
                                               awsCredentials: awsCredentials)
        let hostingController = UIHostingController(rootView: myView)
        let containerView = UIView()
        containerView.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }

    init(sessionId: String?, awsCredentials: CustomAWSCredentials?) {
        self.sessionId = sessionId
        self.awsCredentials = awsCredentials
    }
}

class FLFaceLivenessView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView(frame: frame)
        super.init()
        _view.backgroundColor = UIColor.clear
        if let arguments = args as? [String: Any],
           let sessionId = arguments["session_id"] as? String,
           let secretAccessKey = arguments["secret_access_key"] as? String,
           let accessKeyId = arguments["access_key_id"] as? String,
           let sessionToken = arguments["token"] as? String,
           let expiration = arguments["expiration"] as? String
        {
            debugPrint(sessionId)
            debugPrint(secretAccessKey, accessKeyId, sessionToken, expiration)

            var expirationAsDate: Date? = nil
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            format.timeZone = TimeZone(identifier: "UTC")
            expirationAsDate = format.date(from: expiration)

            let awsCredentials = CustomAWSCredentials(
                secretAccessKey: secretAccessKey,
                sessionToken: sessionToken,
                accessKeyId: accessKeyId,
                expiration: expirationAsDate
            )
            let faceLivenessView = FaceLivenessDetectionView(sessionId: sessionId,
                                                             awsCredentials: awsCredentials)
            let childView = UIHostingController(rootView: faceLivenessView)

            childView.view.frame = _view.frame
            childView.view.bounds = _view.bounds
            childView.view.backgroundColor = UIColor.clear
            childView.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            debugPrint("IF")
            _view.addSubview(childView.view)
//            childView.didMove(toParent: _view.inputViewController)
//            _view.bringSubviewToFront(childView.view)
//            createNativeView(view: _view)
        } else {
            debugPrint("Else")
            createNativeView(view: _view)
        }
        // iOS views can be created here
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView) {
        _view.backgroundColor = UIColor.blue
        let nativeLabel = UILabel()
        nativeLabel.text = "Native text from iOS"
        nativeLabel.textColor = UIColor.white
        nativeLabel.textAlignment = .center
        nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
        _view.addSubview(nativeLabel)
    }
}

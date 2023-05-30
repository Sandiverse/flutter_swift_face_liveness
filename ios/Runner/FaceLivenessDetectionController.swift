//
//  FaceLivenessDetectionController.swift
//  Runner
//
//  Created by Sandy Oswaldo Valdez Gaitan on 9/5/23.
//

import Foundation
import SwiftUI

class FaceLivenessDetectionController: UIHostingController<FaceLivenessDetectionView> {
    var sessionId: String?
    var awsCredentials: CustomAWSCredentials?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sessionId = nil
        self.awsCredentials = nil
        rootView = FaceLivenessDetectionView(
            sessionId: sessionId,
            awsCredentials: awsCredentials
        )
    }

    init(sessionId: String, awsCredentials: CustomAWSCredentials) {
        self.sessionId = sessionId
        self.awsCredentials = awsCredentials
        super.init(
            rootView: FaceLivenessDetectionView(
                sessionId: sessionId,
                awsCredentials: awsCredentials
            )
        )
    }
}

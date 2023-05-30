import Foundation

class CustomAWSCredentials: NSObject, NSCoding {
    let secretAccessKey: String?
    let sessionToken: String?
    let accessKeyId: String?
    let expiration: Date?

    init(secretAccessKey: String?, sessionToken: String?, accessKeyId: String?, expiration: Date?) {
        self.secretAccessKey = secretAccessKey
        self.sessionToken = sessionToken
        self.accessKeyId = accessKeyId
        self.expiration = expiration
    }

    func encode(with coder: NSCoder) {
        coder.encode(secretAccessKey, forKey: "secretAccessKey")
        coder.encode(sessionToken, forKey: "sessionToken")
        coder.encode(accessKeyId, forKey: "accessKeyId")
        coder.encode(expiration, forKey: "expiration")
    }

    required convenience init?(coder: NSCoder) {
        let secretAccessKey = coder.decodeObject(forKey: "secretAccessKey") as? String
        let sessionToken = coder.decodeObject(forKey: "sessionToken") as? String
        let accessKeyId = coder.decodeObject(forKey: "accessKeyId") as? String
        let expiration = coder.decodeObject(forKey: "expiration") as? Date

        self.init(secretAccessKey: secretAccessKey, sessionToken: sessionToken, accessKeyId: accessKeyId, expiration: expiration)
    }
}

extension NSCoder {
    func decodeDate(forKey key: String) -> Date? {
        return decodeObject(forKey: key) as? Date
    }

    func encodeDate(_ value: Date?, forKey key: String) {
        if let value = value {
            encode(value, forKey: key)
        } else {
            encode(nil, forKey: key)
        }
    }
}

//
//  NightscoutAPIService.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKit
import Combine

private let nightscoutLabel = "Nightscout"

public class NightscoutAPIService: ServiceAuthentication {
    public var title = "Nightscout API"

    public var credentialValues: [String?] = []

    public var isAuthorized = false

    private(set) var client: NightscoutAPIClient?

    var secret: String? { credentialValues[1] }

    var ulr: URL? {
        guard let urlString = credentialValues[0] else {
            return nil
        }
        return URL(string: urlString)
    }

    public func verify(_ completion: @escaping (Bool, Error?) -> Void) {
        guard let client = client else {
            completion(false, nil)
            return
        }

        _ = client.checkStatus()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    completion(true, nil)
                case let .failure(error):
                    completion(false, error)
                }
            }, receiveValue: { _ in })
    }

    public func reset() {
        isAuthorized = false
        client = nil
    }

    public init(url: URL?, secret: String?) {
        credentialValues = [
            url?.absoluteString,
            secret
        ]

        isAuthorized = true
        client = NightscoutAPIClient(url: url?.absoluteString, secret: secret)
    }

}

extension KeychainManager {
    func setNightscoutURL(_ url: URL?, secret: String?) throws {
        let credentials: InternetCredentials?

        if let url = url, let secret = secret {
            credentials = InternetCredentials(username: "1", password: secret, url: url)
        } else {
            credentials = nil
        }

        try replaceInternetCredentials(credentials, forLabel: nightscoutLabel)
    }

    func getNightscoutCredentials() -> (secret: String, url: URL)? {
        do {
            let credentials = try getInternetCredentials(label: nightscoutLabel)
            return (secret: credentials.password, url: credentials.url)
        } catch {
            return nil
        }
    }
}

extension NightscoutAPIService {
    public convenience init(keychainManager: KeychainManager = KeychainManager()) {
        if let (secret, url) = keychainManager.getNightscoutCredentials() {
            self.init(url: url, secret: secret)
        } else {
            self.init(url: nil, secret: nil)
        }
    }
}

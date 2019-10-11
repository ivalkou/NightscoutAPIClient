//
//  NightscoutAPIService.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKit
import Combine

public class NightscoutAPIService: ServiceAuthentication {
    public var title = "Nightscout API"

    public var credentialValues: [String?] = []

    public var isAuthorized = false

    private(set) var client: NightscoutAPIClient?

    var ulr: String? { credentialValues[1] }

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

    public init(url: URL, secret: String?) {
        credentialValues = [
            secret,
            url.absoluteString
        ]

        isAuthorized = true
        client = NightscoutAPIClient(url: url.absoluteString, secret: secret)
    }

}

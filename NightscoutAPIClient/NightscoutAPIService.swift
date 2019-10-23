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
    public var credentialValues: [String?]

    public let title = LocalizedString("Nightscout API", comment: "The title of the Dexcom Share service")

    public init(url: URL?) {
        credentialValues = [url?.absoluteString]

        if let url = url {
            isAuthorized = true
            client = NightscoutAPIClient(url: url.absoluteString)
        }
    }

    private(set) var client: NightscoutAPIClient?

    var ulr: URL? {
        guard let urlString = credentialValues[0] else {
            return nil
        }
        return URL(string: urlString)
    }

    public var isAuthorized = false

    private var requestReceiver: Cancellable?

    public func verify(_ completion: @escaping (Bool, Error?) -> Void) {
        guard let client = client else {
            completion(false, nil)
            return
        }

        requestReceiver?.cancel()
        requestReceiver = client.fetchLast(1)
            .sink(receiveCompletion: { finish in
                switch finish {
                case .finished: break
                case let .failure(error):
                    completion(false, error)
                }
            }, receiveValue: { glucose in
                completion(!glucose.isEmpty, nil)
            })
    }

    public func reset() {
        isAuthorized = false
        client = nil
        requestReceiver?.cancel()
    }
}

extension KeychainManager {
    private enum Config {
        static let nightscoutCgmLabel = "NightscoutCGM"
        static let nightscoutCgmSecret = ""
    }

    func setNightscoutCgmURL(_ url: URL?) {
        do {
            let credentials: InternetCredentials?

            if let url = url {
                credentials = InternetCredentials(username: Config.nightscoutCgmLabel, password: Config.nightscoutCgmSecret, url: url)
            } else {
                credentials = nil
            }

            try replaceInternetCredentials(credentials, forAccount: Config.nightscoutCgmLabel)
        } catch {}
    }

    func getNightscoutCgmURL() -> URL? {
        do {
            let credentials = try getInternetCredentials(account: Config.nightscoutCgmLabel)
            return credentials.url
        } catch {
            return nil
        }
    }
}

extension NightscoutAPIService {
    public convenience init(keychainManager: KeychainManager = KeychainManager()) {
        self.init(url: keychainManager.getNightscoutCgmURL())
    }
}

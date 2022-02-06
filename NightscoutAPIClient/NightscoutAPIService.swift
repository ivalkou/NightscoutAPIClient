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

    public let title = LocalizedString("Nightscout Remote CGM", comment: "The title of the Nightscout service")

    public init(url: URL?, apiSecret: String?) {
        credentialValues = [url?.absoluteString, apiSecret]

        if let url = url {
            isAuthorized = true
            client = NightscoutAPIClient(url: url, apiSecret: apiSecret)
        }
    }

    private(set) var client: NightscoutAPIClient?

    public var url: URL? {
        guard let urlString = credentialValues[0] else {
            return nil
        }
        return URL(string: urlString)
    }
    
    public var apiSecret: String? {
        guard let apiSecret = credentialValues[1] else {
            return nil
        }
        return apiSecret
    }

    public var isAuthorized = false

    private var requestReceiver: Cancellable?

    public func verify(_ completion: @escaping (Bool, Error?) -> Void) {
        guard let url = url else {
            completion(false, nil)
            return
        }

        let client = NightscoutAPIClient(url: url, apiSecret: apiSecret)
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

        self.client = client
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

    func setNightscoutCgmCredentials(_ url: URL?, apiSecret: String?) {
        do {
            let credentials: InternetCredentials?

            if let url = url, let apiSecret = apiSecret {
                credentials = InternetCredentials(username: Config.nightscoutCgmLabel, password: apiSecret, url: url)
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
    
    func getNightscoutAPISecret() -> String? {
        do {
            let credentials = try getInternetCredentials(account: Config.nightscoutCgmLabel)
            return credentials.password
        } catch {
            return nil
        }
    }
}

extension NightscoutAPIService {
    public convenience init(keychainManager: KeychainManager = KeychainManager()) {
        self.init(url: keychainManager.getNightscoutCgmURL(), apiSecret: keychainManager.getNightscoutAPISecret())
    }
}

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
    
    private(set) var client: NightscoutAPIClient?
    private var requestReceiver: Cancellable?
    
    public init(url: URL?, apiSecret: String?) {
        credentialValues = [url?.absoluteString, apiSecret]

        if let url = url {
            isAuthorized = true
            client = NightscoutAPIClient(url: url, apiSecret: apiSecret)
        }
    }
    
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
    
    public func checkServiceStatus(_ completion: @escaping (Result<Void, NightScoutAPIServiceError>) -> Void) {
        
        guard let url = url else {
            completion(.failure(.missingURL))
            return
        }

        //Not using client property in case called by ServiceAuthentication framework
        //as it only gets set after first validation
        let client = NightscoutAPIClient(url: url, apiSecret: apiSecret)
        requestReceiver?.cancel()
        requestReceiver = client.fetchLast(1)
            .sink(receiveCompletion: { finish in
                switch finish {
                case .finished: break
                case let .failure(error):
                    completion(.failure(.apiError(error)))
                }
            }, receiveValue: { glucose in
                if glucose.isEmpty {
                    completion(.failure(NightScoutAPIServiceError.emptyGlucose))
                } else {
                    completion(.success(()))
                }

            })

        self.client = client
    }
    
    
    // MARK: - ServiceAuthentication conformance
    
    public let title = LocalizedString("Nightscout Remote CGM", comment: "The title of the Nightscout service")
    public var credentialValues: [String?]
    public var isAuthorized = false
    
    public func verify(_ completion: @escaping (Bool, Error?) -> Void) {
        checkServiceStatus { result in
            switch result {
            case .success():
                completion(true, nil)
            case .failure(let err):
                completion(false, err)
            }
        }
    }

    public func reset() {
        isAuthorized = false
        client = nil
        requestReceiver?.cancel()
    }

    
    public enum NightScoutAPIServiceError: LocalizedError {
        case emptyGlucose
        case missingURL
        case apiError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .emptyGlucose:
                return "No recent glucose values available."
            case .missingURL:
                return "Service is not setup."
            case .apiError(let error):
                return error.localizedDescription
            }
        }
    }
}

extension KeychainManager {
    private enum Config {
        static let nightscoutCgmLabel = "NightscoutCGM"
        static let nightscoutCgmEmptySecret = "" //Signify no secret with empty string
    }

    func setNightscoutCgmCredentials(_ url: URL?, apiSecret: String?) {
        do {
            let credentials: InternetCredentials?

            if let url = url {
                credentials = InternetCredentials(username: Config.nightscoutCgmLabel, password: apiSecret ?? Config.nightscoutCgmEmptySecret, url: url)
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
            guard credentials.password != Config.nightscoutCgmEmptySecret else {
                return nil
            }
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

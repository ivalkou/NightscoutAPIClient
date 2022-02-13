//
//  NightscoutAPIClient.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import Foundation
import Combine
import CommonCrypto

final class NightscoutAPIClient {
    let url: URL
    let apiSecret: String?
    
    private enum Config {
        static let entriesPath = "/api/v1/entries.json"
        static let retryCount = 5
    }

    init(url: URL, apiSecret: String?) {
        self.url = url
        self.apiSecret = apiSecret
    }

    enum Error: LocalizedError {
        case badStatusCode
        case missingURL
    }

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()

    func fetchLast(_ count: Int) -> AnyPublisher<[BloodGlucose], Swift.Error> {
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.port = url.port
        components.path = Config.entriesPath
        components.queryItems = [URLQueryItem(name: "count", value: "\(count)")]

        var request = URLRequest(url: components.url!)
        request.allowsConstrainedNetworkAccess = false
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let apiSecretSHA1 = apiSecret?.sha1() {
            request.setValue(apiSecretSHA1, forHTTPHeaderField: "api-secret")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
        .retry(Config.retryCount)
        .tryMap { output in
            guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw Error.badStatusCode
            }
            return output.data
        }
        .decode(type: [BloodGlucose].self, decoder: decoder)
        .map { $0.filter { $0.isStateValid } }
        .eraseToAnyPublisher()
    }
    
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

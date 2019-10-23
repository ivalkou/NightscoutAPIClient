//
//  NightscoutAPIClient.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import Foundation
import Combine

final class NightscoutAPIClient {
    let url: URL

    private enum Config {
        static let entriesPath = "/api/v1/entries.json"
        static let retryCount = 5
    }

    init(url: URL) {
        self.url = url
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
        components.path = Config.entriesPath
        components.queryItems = [URLQueryItem(name: "count", value: "\(count)")]

        var request = URLRequest(url: components.url!)
        request.allowsConstrainedNetworkAccess = false
        
        return URLSession.shared.dataTaskPublisher(for: request)
        .retry(Config.retryCount)
        .tryMap { output in
            guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw Error.badStatusCode
            }
            return output.data
        }
        .decode(type: [BloodGlucose].self, decoder: decoder)
        .eraseToAnyPublisher()
    }
    
}

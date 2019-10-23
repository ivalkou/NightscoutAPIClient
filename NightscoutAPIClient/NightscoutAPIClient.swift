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
    let url: String?

    private enum Config {
        static let apiPath = "/api/v1"
        static let retryCount = 5
    }

    init(url: String?) {
        self.url = url
    }

    enum Error: LocalizedError {
        case badStatusCode
        case missingURL
    }

    func fetchLast(_ count: Int) -> AnyPublisher<[BloodGlucose], Swift.Error> {
        guard let url = url else {
            return Fail(error: Error.missingURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: URL(string: url + Config.apiPath + "/entries.json?count=\(count)")!)
        request.allowsConstrainedNetworkAccess = false
        return URLSession.shared.dataTaskPublisher(for: request)
        .retry(Config.retryCount)
        .tryMap { output in
            guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw Error.badStatusCode
            }
            return output.data
        }
        .decode(type: [BloodGlucose].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
    
}

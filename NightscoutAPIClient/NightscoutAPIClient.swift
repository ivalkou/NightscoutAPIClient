//
//  NightscoutAPIClient.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import Foundation
import Combine

struct Status: Decodable, Equatable {
    var status: String
    static let ok = Status(status: "ok")
}

final class NightscoutAPIClient {
    let secret: String?
    let url: String?

    private enum Config {
        static let apiPath = "/api/v1"
        static let retryCount = 5
    }

    init(url: String?, secret: String?) {
        self.url = url
        self.secret = secret
    }

    enum Error: LocalizedError {
        case statusCode
        case unknownStatus
        case missingURL
    }

    func checkStatus() -> AnyPublisher<Never, Swift.Error> {
        guard let url = url else {
            return Fail(error: Error.missingURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: URL(string: url + Config.apiPath + "/status.json")!)
        request.allowsConstrainedNetworkAccess = false
        return URLSession.shared.dataTaskPublisher(for: request)
            .retry(Config.retryCount)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw Error.statusCode
                }
                return output.data
            }
            .decode(type: Status.self, decoder: JSONDecoder())
            .tryMap { value in
                if value != .ok { throw Error.unknownStatus }
            }
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
    
}

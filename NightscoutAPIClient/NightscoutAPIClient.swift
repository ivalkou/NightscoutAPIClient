//
//  NightscoutAPIClient.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import Foundation
import NightscoutUploadKit
import LoopKit
import HealthKit

final class NightscoutAPIClient {
    let url: URL
    let apiSecret: String

    init(url: URL, apiSecret: String) {
        self.url = url
        self.apiSecret = apiSecret
    }
    
    public func fetchRecent(minutes: Int = 60, completion: @escaping (Result<[GlucoseEntry], Swift.Error>) -> Void) {
        
        let client = NightscoutUploader(siteURL: url, APISecret: apiSecret)
        
        let intervalLength: TimeInterval = TimeInterval(60 * minutes)
        let maxCount = (minutes / 5) * 2 // Assume 1 entry delivered every 5 minutes. Include multiplier in case mulitple glucose sources.
        let interval = DateInterval(start: Date().addingTimeInterval(-intervalLength), duration: intervalLength)
        client.fetchGlucose(dateInterval: interval, maxCount: maxCount) { result in
            switch result {
            case .success(let entries):
                completion(.success(entries))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension GlucoseEntry: GlucoseValue {
    public var startDate: Date { date }
    public var quantity: HKQuantity { .init(unit: .milligramsPerDeciliter, doubleValue: sgv) }
}

extension GlucoseEntry: GlucoseDisplayable {
    
    public var isStateValid: Bool { sgv >= 39}
    public var trendType: GlucoseTrend? {
        guard let trend = trend else { return nil }
        return GlucoseTrend(rawValue: trend)
    }
    public var isLocal: Bool { false }
    
    // TODO Placeholder. This functionality will come with LOOP-1311
    public var glucoseRangeCategory: GlucoseRangeCategory? {
        return nil
    }
    
    public var trendRate: HKQuantity? {
        return nil
    }
}

extension HKUnit {
    static let milligramsPerDeciliter: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    }()
}

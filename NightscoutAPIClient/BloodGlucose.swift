//
//  BloodGlucose.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import HealthKit
import LoopKit

public struct BloodGlucose: Codable {
    public enum Direction: String, Codable {
        case tripleUp = "TripleUp"
        case doubleUp = "DoubleUp"
        case singleUp = "SingleUp"
        case fortyFiveUp = "FortyFiveUp"
        case flat = "Flat"
        case fortyFiveDown = "FortyFiveDown"
        case singleDown = "SingleDown"
        case doubleDown = "DoubleDown"
        case tripleDown = "TripleDown"
        case none = "NONE"
        case notComputable = "NOT COMPUTABLE"
        case rateOutOfRange = "RATE OUT OF RANGE"

        var trend: GlucoseTrend? {
            switch self {
            case .tripleUp: return .upUpUp
            case .doubleUp: return .upUp
            case .singleUp, .fortyFiveUp: return .up
            case .flat: return .flat
            case .singleDown, .fortyFiveDown: return .down
            case .doubleDown: return .downDown
            case .tripleDown: return .downDownDown
            default: return nil
            }
        }
    }

    public var sgv: Int?
    public let direction: Direction?
    public let date: Date
    public let filtered: Double?
    public let noise: Int?

    public var glucose: Int { sgv ?? 0 }
    
}

extension BloodGlucose: GlucoseValue {
    public var startDate: Date { date }
    public var quantity: HKQuantity { .init(unit: .milligramsPerDeciliter, doubleValue: Double(glucose)) }
}

extension BloodGlucose: GlucoseDisplayable {
    
    public var isStateValid: Bool { glucose >= 39 && noise ?? 1 != 4 }
    public var trendType: GlucoseTrend? { direction?.trend }
    public var isLocal: Bool { false }
    
    // TODO Placeholder. This functionality will come with LOOP-1311
    public var glucoseRangeCategory: GlucoseRangeCategory? {
        return nil
    }
    
    public var trendRate: HKQuantity? {
        return nil
    }
}

extension GlucoseDisplayable {
    public var stateDescription: String {
        if isStateValid {
            return LocalizedString("OK", comment: "Sensor state description for the valid state")
        } else {
            return LocalizedString("Needs Attention", comment: "Sensor state description for the non-valid state")
        }
    }
}

extension HKUnit {
    static let milligramsPerDeciliter: HKUnit = {
        HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    }()
}

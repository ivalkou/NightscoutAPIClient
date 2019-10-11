//
//  NightscoutAPIManager.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKit
import HealthKit

public class NightscoutAPIManager: CGMManager {
    public static var localizedTitle = "Nightscout API"

    public let delegate = WeakSynchronizedDelegate<CGMManagerDelegate>()

    public var delegateQueue: DispatchQueue! {
        get { delegate.queue }
        set { delegate.queue = newValue }
    }

    public var cgmManagerDelegate: CGMManagerDelegate? {
        get { delegate.delegate }
        set { delegate.delegate = newValue }
    }

    public private(set) var latestBackfill: BloodGlucose?

    public let providesBLEHeartbeat = false

    public var managedDataInterval: TimeInterval?

    public var shouldSyncToRemoteService = false

    public var sensorState: SensorDisplayable? { latestBackfill }

    public var device: HKDevice? = nil

    public static var managerIdentifier = "NightscoutAPIClient"

    public var rawState: CGMManager.RawStateValue { [:] }

    public var debugDescription: String {
        "## NightscoutAPIManager\nlatestBackfill: \(String(describing: latestBackfill))\n"
    }

    private let keychain = KeychainManager()

    public init() {

    }

    public convenience required init?(rawState: CGMManager.RawStateValue) {
        self.init()
    }

    public func fetchNewDataIfNeeded(_ completion: @escaping (CGMResult) -> Void) {
        let startDate = self.delegate.call { (delegate) -> Date? in
            return delegate?.startDateToFilterNewData(for: self)?.addingTimeInterval(TimeInterval(minutes: 1))
        }
        
    }
}

//
//  NightscoutAPIManager.swift
//  NightscoutAPIClient
//
//  Created by Ivan Valkou on 10.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKit
import HealthKit
import Combine

public class NightscoutAPIManager: CGMManager {
    public enum CGMError: Error {
        case tooFlatData
    }

    private enum Config {
        static var shouldSyncKey = "NightscoutAPIClient.shouldSync"
    }

    public static var managerIdentifier = "NightscoutAPIClient"

    public init() {
        nightscoutService = NightscoutAPIService(keychainManager: keychain)
        updateTimer = DispatchTimer(timeInterval: 10, queue: processQueue)
        scheduleUpdateTimer()
    }

    public convenience required init?(rawState: CGMManager.RawStateValue) {
        self.init()
        shouldSyncToRemoteService = rawState[Config.shouldSyncKey] as? Bool ?? false
    }

    public var rawState: CGMManager.RawStateValue { [Config.shouldSyncKey: shouldSyncToRemoteService] }

    private let keychain = KeychainManager()

    public var nightscoutService: NightscoutAPIService {
        didSet {
            keychain.setNightscoutCgmURL(nightscoutService.url)
        }
    }

    public static var localizedTitle = LocalizedString("Nightscout CGM", comment: "Title for the CGMManager option")

    public let delegate = WeakSynchronizedDelegate<CGMManagerDelegate>()

    public var delegateQueue: DispatchQueue! {
        get { delegate.queue }
        set { delegate.queue = newValue }
    }

    public var cgmManagerDelegate: CGMManagerDelegate? {
        get { delegate.delegate }
        set { delegate.delegate = newValue }
    }

    public let providesBLEHeartbeat = false

    public var managedDataInterval: TimeInterval?

    public var shouldSyncToRemoteService = false

    public private(set) var latestBackfill: BloodGlucose?

    public var sensorState: SensorDisplayable? { latestBackfill }

    private var requestReceiver: Cancellable?

    private let processQueue = DispatchQueue(label: "NightscoutAPIManager.processQueue")

    private var isFetching = false

    public func fetchNewDataIfNeeded(_ completion: @escaping (CGMResult) -> Void) {
        guard let nightscoutClient = nightscoutService.client, !isFetching else {
            completion(.noData)
            return
        }

        if let latestGlucose = latestBackfill, latestGlucose.startDate.timeIntervalSinceNow > -TimeInterval(minutes: 4.5) {
            completion(.noData)
            return
        }

        processQueue.async {
            self.isFetching = true
            self.requestReceiver = nightscoutClient.fetchLast(12)
            .sink(receiveCompletion: { finish in
                switch finish {
                case .finished: break
                case let .failure(error):
                    completion(.error(error))
                }
            }, receiveValue: { [weak self] glucose in
                guard !glucose.isEmpty, let self = self else {
                    completion(.noData)
                    return
                }

                let tooFlat = Set(
                    glucose.filterDateRange(Date(timeIntervalSinceNow: -60 * 20), nil)
                        .filter { $0.isStateValid }
                        .map { $0.filtered ?? 0 }
                ).count == 1

                guard !tooFlat else {
                    completion(.error(CGMError.tooFlatData))
                    return
                }

                let startDate = self.delegate.call { (delegate) -> Date? in
                    return delegate?.startDateToFilterNewData(for: self)?.addingTimeInterval(TimeInterval(minutes: 1))
                }
                let newGlucose = glucose.filterDateRange(startDate, nil)
                let newSamples = newGlucose.filter({ $0.isStateValid }).map {
                    return NewGlucoseSample(date: $0.startDate, quantity: $0.quantity, isDisplayOnly: false, syncIdentifier: "\(Int($0.startDate.timeIntervalSince1970))", device: self.device)
                }

                self.latestBackfill = newGlucose.first
                self.isFetching = false

                self.delegateQueue.async {
                    if newSamples.count > 0 {
                        completion(.newData(newSamples))
                    } else {
                        completion(.noData)
                    }
                }
            })
        }


    }

    public var device: HKDevice? = nil

    public var debugDescription: String {
        "## NightscoutAPIManager\nlatestBackfill: \(String(describing: latestBackfill))\n"
    }

    public var appURL: URL? {
        guard let url = nightscoutService.url else { return nil }
        switch url.absoluteString {
        case "http://127.0.0.1:1979":
            return URL(string: "spikeapp://")
        case "http://127.0.0.1:17580":
            return URL(string: "diabox://")
        default:
            return url
        }
    }

    private let updateTimer: DispatchTimer

    private func scheduleUpdateTimer() {
        updateTimer.suspend()
        updateTimer.eventHandler = { [weak self] in
            guard let self = self else { return }
            self.fetchNewDataIfNeeded { result in
                guard case .newData = result else { return }
                self.delegate.notify { delegate in
                    delegate?.cgmManager(self, didUpdateWith: result)
                }
            }
        }
        updateTimer.resume()
    }
}

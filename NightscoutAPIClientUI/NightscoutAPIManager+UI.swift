//
//  NightscoutAPIManager+UI.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKitUI
import HealthKit
import NightscoutAPIClient

extension NightscoutAPIManager: CGMManagerUI {
    public static func setupViewController() -> (UIViewController & CGMManagerSetupViewController & CompletionNotifying)? {
        NightscoutAPISetupViewController()
    }

    public func settingsViewController(for glucoseUnit: HKUnit) -> (UIViewController & CompletionNotifying) {
        NightscoutAPISettingsViewController(cgmManager: self, glucoseUnit: glucoseUnit)
    }

    public var smallImage: UIImage? { nil }
}

//
//  NightscoutAPIManager+UI.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKitUI
import LoopKit
import HealthKit
import NightscoutAPIClient
import SwiftUI

extension NightscoutAPIManager: CGMManagerUI {
    public static func setupViewController(glucoseTintColor: Color, guidanceColors: GuidanceColors) -> (UIViewController & CGMManagerSetupViewController & CompletionNotifying)? {
        NightscoutAPISetupViewController()
    }
    
    public func settingsViewController(for glucoseUnit: HKUnit, glucoseTintColor: Color, guidanceColors: GuidanceColors) -> (UIViewController & CompletionNotifying) {
        NightscoutAPISettingsViewController(cgmManager: self, glucoseUnit: glucoseUnit)
    }

    public var smallImage: UIImage? { nil }
    
    // TODO Placeholder. This functionality will come with LOOP-1311
    public var cgmStatusHighlight: DeviceStatusHighlight? {
        return nil
    }
    
    // TODO Placeholder. This functionality will come with LOOP-1311
    public var cgmLifecycleProgress: DeviceLifecycleProgress? {
        return nil
    }
}

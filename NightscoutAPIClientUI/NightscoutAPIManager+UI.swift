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

extension NightscoutAPIManager: CGMManagerUI {
    
    // TODO Placeholder.
    public static var onboardingImage: UIImage? {
        return UIImage(named: "nightscout", in: Bundle(for: NightscoutAPISettingsViewController.self), compatibleWith: nil)!
    }
    
    public static func setupViewController(bluetoothProvider: BluetoothProvider, displayGlucoseUnitObservable: DisplayGlucoseUnitObservable, colorPalette: LoopUIColorPalette, allowDebugFeatures: Bool) -> SetupUIResult<CGMManagerViewController, CGMManagerUI> {
        return .userInteractionRequired(NightscoutAPISetupViewController())
    }
    
    public func settingsViewController(bluetoothProvider: BluetoothProvider, displayGlucoseUnitObservable: DisplayGlucoseUnitObservable, colorPalette: LoopUIColorPalette, allowDebugFeatures: Bool) -> CGMManagerViewController {
        let settings = NightscoutAPISettingsViewController(cgmManager: self, glucoseUnit: displayGlucoseUnitObservable)
        let nav = CGMManagerSettingsNavigationViewController(rootViewController: settings)
        return nav
    }
    
    public var smallImage: UIImage? {
        return UIImage(named: "nightscout", in: Bundle(for: NightscoutAPISettingsViewController.self), compatibleWith: nil)!
    }
    
    // TODO Placeholder.
    public var cgmStatusHighlight: DeviceStatusHighlight? {
        return nil
    }

    // TODO Placeholder.
    public var cgmStatusBadge: DeviceStatusBadge? {
        return nil
    }

    // TODO Placeholder.
    public var cgmLifecycleProgress: DeviceLifecycleProgress? {
        return nil
    }
}

//
//  NightscoutAPIClientPlugin.swift
//  NightscoutAPIClientPlugin
//
//  Created by Bill Gestrich on 8/18/21.
//  Copyright © 2021 Ivan Valkou. All rights reserved.
//

import os.log
import LoopKitUI
import NightscoutAPIClient
import NightscoutAPIClientUI

class NightscoutAPIClientPlugin: NSObject, CGMManagerUIPlugin {
    private let log = OSLog(category: "NightscoutAPIClientPlugin")
    
    public var cgmManagerType: CGMManagerUI.Type? {
        NightscoutAPIManager.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}

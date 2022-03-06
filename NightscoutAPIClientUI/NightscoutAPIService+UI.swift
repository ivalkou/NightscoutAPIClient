//
//  NightscoutAPIService+UI.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import LoopKitUI
import NightscoutAPIClient

extension NightscoutAPIService: ServiceAuthenticationUI {
    public var credentialFormFields: [ServiceCredential] {
        [
            ServiceCredential(
                title: LocalizedString("URL", comment: "The title of the Nightscout API server URL credential"),
                isSecret: false,
                keyboardType: .URL
            ),
            ServiceCredential(
                title: LocalizedString("API Secret", comment: "The title of the Nightscout API secret credential"),
                isSecret: true,
                keyboardType: .default
            )
        ]
    }
    
    public var credentialFormFieldHelperMessage: String? {
        return nil
    }
}

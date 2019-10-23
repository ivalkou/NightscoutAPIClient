//
//  NightscoutAPISetupViewController.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import UIKit
import HealthKit
import LoopKit
import LoopKitUI
import NightscoutAPIClient

final class NightscoutAPISetupViewController: UINavigationController, CGMManagerSetupViewController, CompletionNotifying {
    public var setupDelegate: CGMManagerSetupViewControllerDelegate?
    
    weak var completionDelegate: CompletionDelegate?

    let cgmManager = NightscoutAPIManager()

    init() {
        let authVC = AuthenticationViewController(authentication: cgmManager.nightscoutService)
        super.init(rootViewController: authVC)

        authVC.authenticationObserver = { [weak self] (service) in
            self?.cgmManager.nightscoutService = service
        }
        authVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        authVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cancel() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }

    @objc private func save() {
        setupDelegate?.cgmManagerSetupViewController(self, didSetUpCGMManager: cgmManager)
        completionDelegate?.completionNotifyingDidComplete(self)
    }

}

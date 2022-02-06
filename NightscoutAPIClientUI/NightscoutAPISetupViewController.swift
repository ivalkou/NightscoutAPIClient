//
//  NightscoutAPISetupViewController.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 21.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import UIKit
import SwiftUI
import HealthKit
import LoopKit
import LoopKitUI
import NightscoutAPIClient
import Combine

final class NightscoutAPISetupViewController: UINavigationController, CompletionNotifying, CGMManagerOnboarding {
    
    weak var cgmManagerOnboardingDelegate: CGMManagerOnboardingDelegate?
    weak var completionDelegate: CompletionDelegate?

    let cgmManager = NightscoutAPIManager()
    private var lifetime: AnyCancellable?
    let disclaimerViewModel: DisclaimerViewModel
    
    init() {
        
        self.disclaimerViewModel = DisclaimerViewModel(
            url: cgmManager.nightscoutService.url?.absoluteString ?? ""
        )
        let disclaimerVC = NightscoutAPIDisclaimerViewController(cgmManager: cgmManager, disclaimerViewModel: disclaimerViewModel)
        
        super.init(rootViewController: disclaimerVC)
        
        self.subscribeOnDisclaimerChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cancel() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }

    @objc private func save() {
        cgmManagerOnboardingDelegate?.cgmManagerOnboarding(didCreateCGMManager: cgmManager)
        cgmManagerOnboardingDelegate?.cgmManagerOnboarding(didOnboardCGMManager: cgmManager)
        completionDelegate?.completionNotifyingDidComplete(self)
    }
    
    private func showAuthenticationViewController(){
        let authVC = AuthenticationViewController(authentication: cgmManager.nightscoutService)
        authVC.authenticationObserver = { [weak self] (service) in
            authVC.navigationItem.rightBarButtonItem?.isEnabled = service.isAuthorized
            self?.cgmManager.nightscoutService = service
        }
        
        authVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        authVC.navigationItem.rightBarButtonItem?.isEnabled = authVC.authentication.url != nil
        self.pushViewController(authVC, animated: true)
    }
    
    private func dismissSetup(){
        self.cgmManager.notifyDelegateOfDeletion {
            DispatchQueue.main.async {
                self.completionDelegate?.completionNotifyingDidComplete(self)
                self.dismiss(animated: true)
            }
        }
    }
    
    private func subscribeOnDisclaimerChanges() {
        let onContinue = disclaimerViewModel.onContinue
            .sink { [weak self] in
                guard let self = self else { return }
                self.showAuthenticationViewController()
            }
        let onCancel = disclaimerViewModel.onCancel
            .sink { [weak self] in
                guard let self = self else { return }
                self.dismissSetup()
            }
        lifetime = AnyCancellable {
            onContinue.cancel()
            onCancel.cancel()
        }
    }

}

final class NightscoutAPIDisclaimerViewController: UIHostingController<DisclaimerView> {
    
    let cgmManager: NightscoutAPIManager
    private var viewModel: DisclaimerViewModel
    
    public init(cgmManager: NightscoutAPIManager, disclaimerViewModel: DisclaimerViewModel) {
        self.cgmManager = cgmManager
        self.viewModel = disclaimerViewModel
        let view = DisclaimerView(viewModel: self.viewModel)
        super.init(rootView: view)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

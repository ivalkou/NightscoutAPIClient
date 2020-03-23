//
//  SettingsView.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 18.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import SwiftUI
import Combine

private let frameworkBundle = Bundle(for: SettingsViewModel.self)

final class SettingsViewModel: ObservableObject {
    let url: String
    var upload: Bool {
        didSet { onUpload.send(upload) }
    }

    var filter: Bool {
        didSet { onFilter.send(filter) }
    }

    let onDelete = PassthroughSubject<Void, Never>()
    let onClose = PassthroughSubject<Void, Never>()
    let onUpload = PassthroughSubject<Bool, Never>()
    let onFilter = PassthroughSubject<Bool, Never>()

    init(url: String, upload: Bool, filter: Bool) {
        self.url = url
        self.upload = upload
        self.filter = filter
    }
}

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public var body: some View {
        NavigationView {
            Form {
                Section(
                    footer: Text("Select Upload option if you want the application to upload BG to Nightscout.", bundle: frameworkBundle)
                ) {
                    Text(viewModel.url)
                    Toggle(isOn: $viewModel.upload) {
                        Text("Upload to remote service", bundle: frameworkBundle)
                    }
                }

                Section(
                    footer: Text("Use Kalman filter to smooth out a sensor noise.", bundle: frameworkBundle)
                ) {
                    Toggle(isOn: $viewModel.filter) {
                        Text("Use glucose filter", bundle: frameworkBundle)
                    }
                }

                Section {
                    Button(action: {
                        self.viewModel.onDelete.send()
                    }) {
                        Text("Delete CGM", bundle: frameworkBundle).foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle(Text("Nightscout CGM", bundle: frameworkBundle))
            .navigationBarItems(
                leading: Button(action: {
                    self.viewModel.onClose.send()
                }, label: {
                    Text("Close", bundle: frameworkBundle)
                })
            )
        }
        
    }

    private func verifyUrl (urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(url: "https://cgm.example.com", upload: false, filter: false)).environment(\.colorScheme, .dark)
    }
}

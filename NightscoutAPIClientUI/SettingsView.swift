//
//  SettingsView.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 18.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    let url: String
    var upload: Bool {
        didSet { onUpload.send(upload) }
    }

    let onDelete = PassthroughSubject<Void, Never>()
    let onClose = PassthroughSubject<Void, Never>()
    let onUpload = PassthroughSubject<Bool, Never>()

    init(url: String, upload: Bool) {
        self.url = url
        self.upload = upload
    }
}

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    public var body: some View {
        NavigationView {
            Form {
                Section(
                    footer: Text("Select Sync option if you are using a source other than a remote service.")
                ) {
                    Text(viewModel.url)
                    Toggle(isOn: $viewModel.upload) {
                        Text("Sync to remote service")
                    }
                }

                Section {
                    Button(action: {
                        self.viewModel.onDelete.send()
                    }) {
                        Text("Delete CGM").foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Nightscout CGM")
            .navigationBarItems(
                leading: Button("Close") { self.viewModel.onClose.send() })
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
        SettingsView(viewModel: SettingsViewModel(url: "https://cgm.example.com", upload: true)).environment(\.colorScheme, .dark)
    }
}

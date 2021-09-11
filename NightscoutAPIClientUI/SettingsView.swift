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
    @State private var showingDeletionSheet = false
    
    public var body: some View {
        VStack {
            Spacer()
            Text("Nightscout")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image("nightscout", bundle: frameworkBundle)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
            Form {
                Section(
                    footer: Text("Select Upload option if you want the application to upload BG to Nightscout.", bundle: frameworkBundle)
                ) {
                    Text(viewModel.url)
                    Toggle(isOn: $viewModel.upload) {
                        Text("Upload to remote service", bundle: frameworkBundle)
                    }
                }
                
                //Kalman filter disabled for Loop dev integration with
                //understanding this type of filtering could instead be done at the data
                //generation side of the CGM.
//                Section(
//                    footer: Text("Use Kalman filter to smooth out a sensor noise.", bundle: frameworkBundle)
//                ) {
//                    Toggle(isOn: $viewModel.filter) {
//                        Text("Use glucose filter", bundle: frameworkBundle)
//                    }
//                }
                
                Section {
                    HStack {
                        Spacer()
                        deleteCGMButton
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle(Text("CGM Settings", bundle: frameworkBundle))
        .navigationBarItems(
            trailing: Button(action: {
                self.viewModel.onClose.send()
            }, label: {
                Text("Done", bundle: frameworkBundle)
            })
        )
    }

    private func verifyUrl (urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    private var deleteCGMButton: some View {
        Button(action: {
            showingDeletionSheet = true
        }, label: {
            Text("Delete CGM", bundle: frameworkBundle).foregroundColor(.red)
        }).actionSheet(isPresented: $showingDeletionSheet) {
            ActionSheet(
                title: Text("Are you sure you want to delete this CGM?"),
                buttons: [
                    .destructive(Text("Delete CGM")) {
                        self.viewModel.onDelete.send()
                    },
                    .cancel(),
                ]
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(url: "https://cgm.example.com", upload: false, filter: false)).environment(\.colorScheme, .dark)
    }
}

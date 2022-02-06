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
    let onDelete = PassthroughSubject<Void, Never>()
    let onClose = PassthroughSubject<Void, Never>()

    init(url: String) {
        self.url = url
    }
}

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingDeletionSheet = false
    
    public var body: some View {
        VStack {
            Spacer()
            Text(LocalizedString("Nightscout Remote CGM", comment: "Title for the CGMManager option"))
                .font(.title)
                .fontWeight(.semibold)
            Image("nightscout", bundle: frameworkBundle)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
            Form {
                Section {
                    Text(viewModel.url)
                }
                Section {
                    HStack {
                        Spacer()
                        deleteCGMButton
                        Spacer()
                    }
                }
            }
            Spacer()
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
        SettingsView(viewModel: SettingsViewModel(url: "https://cgm.example.com")).environment(\.colorScheme, .dark)
    }
}

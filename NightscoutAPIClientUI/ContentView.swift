//
//  ContentView.swift
//  NightscoutAPIClientUI
//
//  Created by Ivan Valkou on 18.10.2019.
//  Copyright © 2019 Ivan Valkou. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var url = ""
    @State var upload = false

    var body: some View {
        NavigationView {
            Form {
                Section(
                    footer: Text("Select Sync option if you are using a source other than a remote service.")
                ) {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)

                    Toggle(isOn: $upload) {
                        Text("Sync to remote service")
                    }

                }
                Section(
                    footer: Text("Check connection and save the URL")
                ) {
                    Button("Add source") {
                        print("Add source tapped!")
                    }
                    .disabled(url.isEmpty)
                }

            }
            .navigationBarTitle("Nightscout API")
            .navigationBarItems(
                leading:
                    Button("Close") {
                        print("Close tapped!")
                    },
                trailing:
                    Button("Save") {
                        print("Save tapped!")
                    }

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .dark)
    }
}

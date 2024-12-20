//
//  SamplePopupApp.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/25.
//

import SwiftUI

@main
struct SamplePopupApp: App {
	@UIApplicationDelegateAdaptor var delegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
				.preferredColorScheme(.light)
        }
    }
}

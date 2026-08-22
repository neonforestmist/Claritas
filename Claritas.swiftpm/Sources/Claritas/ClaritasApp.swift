import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct ClaritasApp: App {
    @State private var manager = FoundationManager()
    @State private var navManager = NavManager()
    var body: some Scene {
        WindowGroup("Claritas") {
            AppRootView()
                .environment(manager)
                .environment(navManager)
#if canImport(UIKit)
                .onAppear {
                    // Ensure the host window uses the app name on macOS-hosted iOS runs.
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .forEach { $0.title = "Claritas" }
                }
#endif
        }
    }
}

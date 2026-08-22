import SwiftUI

struct AppRootView: View {
    @Environment(NavManager.self) private var navManager
    @State private var isShowingOnboarding = true

    var body: some View {
        Group {
            if isShowingOnboarding {
                OnboardingView {
                    navManager.selectedTab = MyTabs.allCases.first ?? .page1
                    isShowingOnboarding = false
                }
            } else {
                StartTab()
            }
        }
    }
}

#Preview {
    AppRootView()
        .environment(NavManager())
        .environment(FoundationManager())
}

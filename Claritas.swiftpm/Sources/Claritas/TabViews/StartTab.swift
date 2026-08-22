import SwiftUI

enum MyTabs: String, CaseIterable, View {
    case page1 = "Basics"
    case page2 = "Architecture"
    case page3 = "Scenarios"
    case settings = "Settings"

    var id: Self { self }
    var symbol: String {
        switch self {
        case .page1:
            return "xmark.triangle.circle.square.fill"
        case .page2:
            return "cpu"
        case .page3:
            return "theatermasks.fill"
        case .settings:
            return "gearshape.fill"
        }
    }

    var body: some View {
        switch self {
        case .page1:
            Basics()
        case .page2:
            ArchitectureListView()
        case .page3:
            Scenarios()
        case .settings:
            SettingsView()
        }
    }
}


struct StartTab: View {
    @Environment(NavManager.self) var navManager
    var body: some View {
        @Bindable var navManager = navManager
        TabView(selection: $navManager.selectedTab) {
            ForEach(MyTabs.allCases.indices, id: \.self) { index in
                let tab = MyTabs.allCases[index]
                Tab(
                    tab.rawValue,
                    systemImage: tab.symbol,
                    value: tab) {
                        tab
                    }
            }
        }
    }
}

#Preview {
    StartTab()
        .environment(NavManager())
        .environment(FoundationManager())
}

import SwiftUI

@Observable
class NavManager {
    var selectedTab = MyTabs.allCases.first!
}

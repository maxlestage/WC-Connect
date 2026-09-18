import SwiftUI

struct WatchRootView: View {
    var body: some View {
        TabView {
            WatchTimerView()
            WatchHistoryView()
            WatchStatsView()
        }
        .tabViewStyle(.verticalPage)
    }
}

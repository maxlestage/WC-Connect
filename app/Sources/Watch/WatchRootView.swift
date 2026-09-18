import SwiftUI

struct WatchRootView: View {
    var body: some View {
        TabView {
            WatchTimerView()
            WatchBreathingView()
            WatchHistoryView()
            WatchStatsView()
        }
        .tabViewStyle(.verticalPage)
    }
}

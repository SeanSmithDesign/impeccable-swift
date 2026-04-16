import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Build1ChatConversationView()
                .tabItem {
                    Label("Build 1", systemImage: "1.circle")
                }

            Build2ChatConversationView()
                .tabItem {
                    Label("Build 2", systemImage: "2.circle")
                }

            Build3ChatConversationView()
                .tabItem {
                    Label("Build 3", systemImage: "3.circle")
                }

            Build4ChatConversationView()
                .tabItem {
                    Label("Build 4", systemImage: "4.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}

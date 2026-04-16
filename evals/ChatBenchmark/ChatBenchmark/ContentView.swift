import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Build 1", systemImage: "1.circle") {
                Build1ChatConversationView()
            }
            Tab("Build 2", systemImage: "2.circle") {
                Build2ChatConversationView()
            }
            Tab("Build 3", systemImage: "3.circle") {
                Build3ChatConversationView()
            }
            Tab("Build 4", systemImage: "4.circle") {
                Build4ChatConversationView()
            }
        }
    }
}

#Preview {
    ContentView()
}

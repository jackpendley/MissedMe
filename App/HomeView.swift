import SwiftUI

struct HomeView: View {

    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.circle")
                }
            ConnectionsPage()
                .tabItem {
                    Label("Connections", systemImage: "person.3.fill")
                }
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.3.fill")
                }
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}

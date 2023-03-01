import SwiftUI

@main
struct TodoListApp: App {
    
    /*
     MVVM Architecture
     Model - Data point
     View - UI
     ViewModel - Class manages model for view
     */
    
    /*
     TODO
     Enhanced haptics
     Settings which work
     Left edge swipe
     Fix bug-- Exit List when last task item is removed
     */
    
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    @StateObject var settings: SettingsStore = SettingsStore()
    
    static let edges = EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    static let minTaskLength = 12
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ListView()
            }
            .environmentObject(listViewModel)
            .environmentObject(settings)
        }
    }
}

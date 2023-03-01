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

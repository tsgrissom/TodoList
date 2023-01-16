import SwiftUI

@main
struct TodoListApp: App {
    
    /*
     MVVM Architecture
     Model - Data point
     View - UI, 1st to tackle
     ViewModel - Class manages model for view
     */
    
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
            .environmentObject(listViewModel)
        }
    }
}

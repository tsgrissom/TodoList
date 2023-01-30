import SwiftUI

@main
struct TodoListApp: App {
    
    /*
     MVVM Architecture
     Model - Data point
     View - UI, 1st to tackle
     ViewModel - Class manages model for view
     */
    
    /*
     TODO
     Enhanced haptics
     Settings which work
     Left edge swipe
     */
    
    @StateObject var listViewModel: ListViewModel = ListViewModel()
    
    static let edges = EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    static let minTaskLength = 12
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
            .environmentObject(listViewModel)
        }
    }
}

struct Previews_TodoListApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

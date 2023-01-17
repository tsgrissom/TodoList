import SwiftUI

struct ListView: View {
   
    @EnvironmentObject var listViewModel: ListViewModel
    
    var body: some View {
        foregroundLayer
        .navigationTitle("Tasks")
        .navigationBarItems(
            leading:
                NavigationLink(
                    destination: AddView(),
                    label: { Image(systemName: "plus")
                }),
            trailing:
                EditButton().foregroundColor(.accentColor)
        )
    }
    
    private var foregroundLayer: some View {
        VStack {
            ZStack {
                if (isEmpty()) {
                    NoItemsView()
                } else {
                    List {
                        ForEach(listViewModel.items) { item in
                            ListRowView(item: item)
                        }
                        .onDelete(perform: listViewModel.deleteItem)
                        .onMove(perform: listViewModel.moveItem)
                    }
                }
                
                if listViewModel.items.count < 4 {
                    Spacer()
                    
                    NavigationLink(
                        destination: AddView(),
                        label: {
                            Text("Begin Composing")
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                                .transition(.move(edge: .leading))
                        }
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                NavigationLink(destination: SettingsView(), label: {
                    Image(systemName: "gear")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                        .offset(x: -160, y: 300)
                })
            }
        }
    }
    
    func isEmpty() -> Bool {
        return listViewModel.items.isEmpty
    }
    
    func hasAnyCompleted() -> Bool {
        if (isEmpty()) {
            return false
        }
        
        for item in listViewModel.items {
            if (item.isCompleted) {
                return true;
            }
        }
        
        return false
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
        }
        .environmentObject(ListViewModel())
    }
}



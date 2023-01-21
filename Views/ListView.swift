import SwiftUI

struct ListView: View {
   
    @EnvironmentObject var listViewModel: ListViewModel
    
    var body: some View {
        foregroundLayer
        .navigationTitle("Tasks")
        .navigationBarItems(
            leading:
                NavigationLink(destination: SettingsView(), label: {
                    Image(systemName: "gear")
                }),
            trailing:
                EditButton()
                .foregroundColor(.accentColor)
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
                                .contextMenu(menuItems: {
                                    Button(action: {
                                        
                                    }) {
                                        Label("Share task", systemImage: "square.and.arrow.up")
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        Label("Duplicate task", systemImage: "doc.on.doc.fill")
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        Label("Edit task", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    }
                                    Button(action: {
                                        
                                    }) {
                                        Label("Delete task", systemImage: "trash.fill")
                                            .foregroundColor(.red)
                                    }
                                })
                        }
                        .onDelete(perform: listViewModel.deleteItem)
                        .onMove(perform: listViewModel.moveItem)
                    }
                }
                
                if listViewModel.items.count < 2 {
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
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                simpleVibration(feedback: .success)
                            }
                    )
                }
                
                Spacer()
                
                if listViewModel.items.count >= 2 {
                    HStack {
                        Spacer()
                        
                        NavigationLink(
                            destination: AddView(),
                            label: {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 50, height: 50)
                                    .overlay(content: {
                                        Image(systemName: "plus")
                                            .imageScale(.large)
                                            .foregroundColor(.white)
                                })
                        })
                        .offset(x: -15, y: 300)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    simpleVibration(feedback: .success)
                                }
                        )
                    }
                }
            }
        }
    }
    
    func simpleVibration(feedback: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedback)
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



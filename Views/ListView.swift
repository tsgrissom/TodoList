import SwiftUI

struct ListView: View {
   
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State var isAnimated: Bool = false
    
    var body: some View {
        let count = listViewModel.items.count
        let title = count == 0 ? "Tasks" : "Tasks (\(count))"
        
        return VStack {
            ZStack {
                foregroundLayer
                    .navigationTitle(title)
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
    
    func duplicateTask(item: ItemModel) {
        if let idx = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
            listViewModel.items.insert(
                ItemModel(title: item.title, isCompleted: item.isCompleted),
                at: idx)
        }
    }
    
    func deleteTask(item: ItemModel) {
        if let idx = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
            listViewModel.items.remove(at: idx)
        }
    }
}

// MARK: Preview

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
        }
        .environmentObject(ListViewModel())
    }
}

// MARK: Components

extension ListView {
    private var foregroundLayer: some View {
        VStack {
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
                                    duplicateTask(item: item)
                                }) {
                                    Label("Duplicate task", systemImage: "doc.on.doc.fill")
                                }
                                NavigationLink(destination: EditView(item: item)) {
                                    Label("Edit task", systemImage: "rectangle.and.pencil.and.ellipsis")
                                }
                                Button(action: {
                                    deleteTask(item: item)
                                }) {
                                    Label("Delete task", systemImage: "trash.fill")
                                }
                                .foregroundColor(.red)
                            })
                    }
                    .onDelete(perform: listViewModel.deleteItem)
                    .onMove(perform: listViewModel.moveItem)
                }
            }
            
            if listViewModel.items.count < 1 {
                Spacer(); onboardingButton; Spacer()
            } else {
                HStack {
                    Spacer()
                    
                    quickAddButton
                }
            }
        }
    }
    
    private var onboardingButton: some View {
        VStack {
            Text("Ready to get started? ⬇️")
                .font(.caption)
            NavigationLink(
                destination: AddView(),
                label: {
                    Text("Begin Composing")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: 200)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .transition(.move(edge: .leading))
                }
            )
            .padding(.horizontal)
            .padding(.bottom, 50)
            .padding(.top, 10)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        simpleVibration(feedback: .success)
                    }
            )
        }
        .offset(y: isAnimated ? -200 : 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.linear) {
                    isAnimated = true
                }
            }
        }
    }
    
    private var quickAddButton: some View {
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
        .offset(x: -5)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    simpleVibration(feedback: .success)
                }
        )
    }
}

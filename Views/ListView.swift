import SwiftUI

struct ListView: View {
   
    @EnvironmentObject var listViewModel: ListViewModel
    
    @State var animateButtonSlide: Bool = false
    
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
                            })
                        ,
                        trailing: EditButton().foregroundColor(.accentColor)
                    )
                }
        }
    }
    
    // MARK: Functions
    
    /*
     Checks if the tasks array is empty
     */
    private func isEmpty() -> Bool {
        return listViewModel.items.isEmpty
    }
    
    /*
     Checks if any of the tasks are checked off
     */
    private func hasAnyCompleted() -> Bool {
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
    
    /*
     Duplicates the provided task, inserting it in front of the duplicated element in the array
     */
    private func duplicateTask(item: ItemModel) {
        if let idx = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
            listViewModel.items.insert(
                ItemModel(title: item.title, isCompleted: item.isCompleted),
                at: idx)
            listViewModel.saveItems()
        }
    }
    
    /*
     Deletes the provided task
     */
    private func deleteTask(item: ItemModel) {
        if let idx = listViewModel.items.firstIndex(where: { $0.id == item.id }) {
            listViewModel.items.remove(at: idx)
            listViewModel.saveItems()
        }
    }
}

// MARK: Components

extension ListView {
    
    private var foregroundLayer: some View {
        VStack {
            if isEmpty() {
                NoItemsView()
            } else {
                List {
                    ForEach(listViewModel.items) { item in
                        ListRowView(item: item)
                            .contextMenu(menuItems: {
                                cmShareButton(item: item)
                                cmCopyButton(item: item)
                                cmDuplicateButton(item: item)
                                cmDeleteButton(item: item)
                            })
                            .swipeActions(edge: .leading, content: {
                                Button(item.isCompleted ? "Incompleted" : "Completed", action: {
                                    listViewModel.updateItem(item: item)
                                })
                                .tint(item.isCompleted ? .red : .green)
                            })
                    }
                    .onDelete(perform: listViewModel.deleteItem)
                    .onMove(perform: listViewModel.moveItem)
                }
            }
            
            if listViewModel.items.count < 1 {
                Spacer()
                onboardingButton
                Spacer()
            } else {
                Spacer()
                HStack {
                    Spacer()
                    quickAddButton
                }
            }
        }
    }
    
    private func cmCopyButton(item: ItemModel) -> some View {
        Button(action: {
            UIPasteboard.general.string = item.title
            Haptics.withImpact(style: .light)
        }, label: {
            Label("Copy", systemImage: "clipboard")
        })
    }
    
    private func cmDuplicateButton(item: ItemModel) -> some View {
        Button(action: {
            withAnimation(.linear) {
                duplicateTask(item: item)
            }
            Haptics.withSimpleFeedback()
        }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
    }
    
    private func cmShareButton(item: ItemModel) -> some View {
        Button(action: {
            // Offer a share sheet for the provided ItemModel
        }, label: {
            Label("Share", systemImage: "square.and.arrow.up")
        })
    }
    
    private func cmDeleteButton(item: ItemModel) -> some View {
        Button(role: .destructive, action: {
            withAnimation(.linear) {
                deleteTask(item: item)
            }
            Haptics.withSimpleFeedback()
        }) {
            Label("Delete task", systemImage: "trash.fill")
        }
    }
    
    private var onboardingButton: some View {
        VStack {
            Text("Ready to get started? ⬇️")
                .font(.caption)
            NavigationLink(
                destination: AddView(),
                label: {
                    beginComposingButton
                }
            )
            .padding(.horizontal)
            .padding(.bottom, 50)
            .padding(.top, 10)
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        Haptics.withSimpleFeedback()
                    }
            )
        }
        .offset(y: animateButtonSlide ? -200 : 0)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    animateButtonSlide = true
                }
            }
        }
    }
    
    private var beginComposingButton: some View {
        Text("Begin Composing")
            .foregroundColor(.white)
            .font(.headline)
            .frame(height: 55)
            .frame(maxWidth: 200)
            .background(Color.accentColor)
            .cornerRadius(10)
            .transition(.move(edge: .leading))
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
        .offset(x: -10)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    Haptics.withImpact(style: .light)
                }
        )
    }
}

// MARK: Preview

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView()
        }
        .environmentObject(ListViewModel())
    }
}

import SwiftUI

struct ListView: View {
   
    let noItemsBlob = "Looking to organize your life? Taskmaster can help with that. Press the big purple button above to begin composing your first task."
    var viewTitle: String { // Computed variable creates a nice title for the todo list based on # of items in list
        /*
         Creates a nice title for the todo list based on how many items are in the list
         =0 tasks - "No Tasks"
         =1 task - "1 Task"
         >1 task - "x Tasks"
         */
        let count = listViewModel.items.count
        var titleNoun: String = "Task"
        if count > 1 { // Plurality fix for 0 tasks ("No Tasks") & > 1 task
            titleNoun += "s"
        }
        return count == 0 ? "No Tasks" : "\(count) \(titleNoun)"
    }
    
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var settings: SettingsStore
    
    @State var animateButtonSlide: Bool = false
    
    var body: some View {
        let height = UIScreen.main.bounds.height
        
        return VStack {
            ZStack {
                foregroundLayer
                    .navigationTitle(viewTitle)
                    .navigationBarTitleDisplayMode(.inline)
                
                HStack {
                    Spacer()
                    quickAddButton
                        .padding(.trailing, 25)
                        .padding(.top, height - 140)
                }
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
        return listViewModel.items.contains { $0.isCompleted }
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
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        
        return VStack {
            if listViewModel.items.count < 1 {
                Spacer()
                onboardingSection
            }
            
            if isEmpty() {
                Text(noItemsBlob)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, isPhone ? 30 : 300)
                    .offset(y: animateButtonSlide ? -400 : -300)
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
                                onSwipeLeadingEdge(item: item)
                            })
                    }
                    .onDelete(perform: listViewModel.deleteItem)
                    .onMove(perform: listViewModel.moveItem)
                }
            }
        }
        .navigationBarItems(
            leading: NavigationLink(destination: SettingsView(), label: { Image(systemName: "gear")}),
            trailing: isEmpty() ? nil : EditButton().foregroundColor(.accentColor))
    }
    
    private func shouldUseHaptics() -> Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    private func onSwipeLeadingEdge(item: ItemModel) -> some View {
        Button(item.isCompleted ? "Undo Complete" : "Complete") {
            listViewModel.updateItem(item: item)
        }
        .tint(item.isCompleted ? .red : .green)
    }
    
    private func cmCopyButton(item: ItemModel) -> some View {
        Button(action: {
            UIPasteboard.general.string = item.title
            Haptics.withImpact(playOut: shouldUseHaptics(), .light)
        }) {
            Label("Copy", systemImage: "clipboard")
        }
    }
    
    private func cmDuplicateButton(item: ItemModel) -> some View {
        Button(action: {
            withAnimation(.linear) {
                duplicateTask(item: item)
            }
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
        }) {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
    }
    
    private func cmShareButton(item: ItemModel) -> some View {
        Button(action: {
            // TODO Offer a share sheet for the provided ItemModel
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
    
    private func cmDeleteButton(item: ItemModel) -> some View {
        Button(role: .destructive, action: {
            withAnimation(.linear) {
                deleteTask(item: item)
            }
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
        }) {
            Label("Delete task", systemImage: "trash.fill")
        }
    }
    
    private var onboardingSection: some View {
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
                        Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
                    }
            )
        }
        .offset(y: animateButtonSlide ? -400 : -300)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    animateButtonSlide = true
                }
            }
        }
    }
    
    private var beginComposingButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor)
                .frame(height: 55)
                .frame(maxWidth: 200)
                .shadow(radius: 25, y: 15)
            Text("Begin Composing")
                .foregroundColor(.white)
                .font(.headline)
                .transition(.move(edge: .leading))
        }
    }
    
    private var quickAddButton: some View {
        NavigationLink(
            destination: AddView(),
            label: {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(Color.accentColor)
        })
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    Haptics.withImpact(playOut: shouldUseHaptics(), .light)
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
        .environmentObject(SettingsStore())
    }
}

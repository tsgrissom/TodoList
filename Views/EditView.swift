import SwiftUI

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    let item: ItemModel
    let originalText: String
    let disabledBtnBgColor = Color.gray.opacity(0.45)
    let minLength: Int = 12
    
    // MARK: Stateful Vars
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertFgColor: Color = .white
    @State var alertBgColor: Color = .red
    @State var isAlertVisible: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var clearBtnAnimated: Bool = false
    @State var clearBtnBgColor: Color = .red
    @State var clearBtnSymbol: String = "trash.fill"
    @State var clearBtnWidth: Double = .infinity
    @State var restoreBtnBgColor: Color = .yellow
    @State var restoreBtnSymbol: String = "square.on.square"
    
    @FocusState var isFocused: Bool
    
    // MARK: Init
    
    init(item: ItemModel) {
        self.item = item
        self.originalText = item.title
        
        textFieldText = originalText
    }
    
    // MARK: Body Start
    
    var body: some View {
        ScrollView {
            formLayer
            
            Spacer()
            
            if isAlertVisible {
                alertBoxLayer
            }
            
            Spacer()
        }
        .padding(TodoListApp.edges)
        .navigationTitle("Editing Task")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                isFocused = true
            }
        }
    }
    
    // MARK: Event Functions
    
    func onSaveButtonPress() {
        guard textFieldText.count >= minLength else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            withSimpleFeedback(type: .warning)
            flashAlert(
                text: isAlertVisible
                ? "Task is too short. Please enter at least \(minLength) characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least \(minLength) characters in length 📏"
            )
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3,
                execute: {
                    saveBtnBgColor = Color.accentColor
                    saveBtnSymbol = "checkmark"
                }
            )
            
            return
        }
        
        let i = ItemModel(id: item.id, title: textFieldText, isCompleted: item.isCompleted)
        
        saveBtnBgColor = .green
        saveBtnSymbol = "plus"
        
        clearBtnWidth = 0
        
        withSimpleFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            listViewModel.updateItem(item: i)
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func onClearButtonPress() {
        guard !textFieldText.isEmpty else {
            clearBtnSymbol = "xmark"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                clearBtnSymbol = "trash.fill"
            }
            
            withSimpleFeedback(type: .warning)
            
            return
        }
        
        // Otherwise, text field is not empty, clear it, play fx
        
        textFieldText = ""
        clearBtnBgColor = .green
        
        withAnimation(.easeIn) {
            clearBtnAnimated = true
        }
        
        withSimpleFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn) {
                clearBtnBgColor = .red
                clearBtnAnimated = false
            }
        }
    }
    
    func onRestoreButtonPress() {
        let success = !textFieldText.isEmpty
        textFieldText = originalText
        if success {
            withSimpleFeedback()
        }
    }
    
    // MARK: Functions
    
    private func getTrimmedText() -> String {
        return textFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func isTextPrepared() -> Bool {
        return textFieldText.count >= minLength
    }
    
    private func withSimpleFeedback(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    private func withImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1) {
        UIImpactFeedbackGenerator(style: style)
            .impactOccurred(intensity: intensity)
    }
    
    func flashAlert(text: String, bgColor: Color = Color.red, fgColor: Color = Color.white, duration: Double = 15.0) {
        alertTitle = text
        alertBgColor = bgColor
        alertFgColor = fgColor
        
        // In case the alert is already visible, hide it, and slide it back in after 1/2 a second
        guard !isAlertVisible else {
            isAlertVisible = false
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5,
                execute: {
                    showAlert(duration: duration)
                }
            )
            
            return
        }
        
        showAlert(duration: duration)
    }
    
    private func showAlert(duration: Double = 15.0) {
        withAnimation(.linear(duration: 0.2), {
            isAlertVisible = true
        })
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: {
                withAnimation(.linear, {
                    isAlertVisible = false
                })
            }
        )
    }
}

// MARK: Layers + Components

extension EditView {
    
    private var formLayer: some View {
        VStack {
            HStack {
                TextField(originalText, text: $textFieldText)
                    .padding(.horizontal)
                    .frame(height: 45)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .focused($isFocused)
            }
            
            controlButtonRow
        }
    }
    
    private var controlButtonRow: some View {
        let isEqualToOriginal = getTrimmedText() == originalText
        
        return VStack {
            HStack {
                Button(action: onSaveButtonPress) {
                    Image(systemName: saveBtnSymbol)
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isEqualToOriginal ? disabledBtnBgColor : saveBtnBgColor)
                        .cornerRadius(10)
                }
                Spacer()
                Button(action: onClearButtonPress) {
                    Image(systemName: clearBtnSymbol)
                        .rotationEffect(.degrees(clearBtnAnimated ? 180 : 0))
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(clearBtnBgColor)
                        .cornerRadius(10)
                }
            }
            HStack {
                Button(action: onRestoreButtonPress) {
                    Text("Restore original text")
                    Image(systemName: restoreBtnSymbol)
                }
                .fontWeight(.bold)
                .padding(.leading)
                .padding(.top)
                .foregroundColor(restoreBtnBgColor)
                .frame(height: 20)
                Spacer()
            }
        }
    }
    
    private var alertBoxLayer: some View {
        HStack {
            Text(alertTitle)
                .padding(15)
                .foregroundColor(alertFgColor)
        }
        .frame(maxWidth: .infinity)
        .background(alertBgColor)
        .cornerRadius(10)
        .foregroundColor(alertFgColor)
        .padding(.top, 10)
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2), {
                isAlertVisible = false
            })
        }
    }
}

// MARK: Preview

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(item: ItemModel(
                title: "Lorem ipsum dolor...",
                isCompleted: false
            ))
        }
        .environmentObject(ListViewModel())
    }
}

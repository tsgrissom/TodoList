import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    // MARK: Constants
    
    let disabledBtnBg = Color.gray.opacity(0.45)
    let minLength: Int = 12
    
    // MARK: Stateful Vars
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertBgColor: Color = .red
    @State var alertFgColor: Color = .white
    @State var isAlertVisible: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var clearBtnBgColor: Color = .red
    @State var clearBtnSymbol: String = "trash.fill"
    @State var clearBtnWidth: Double = .infinity
    @State var clearBtnSuccessAnimated: Bool = false
    @State var clearBtnFailAnimated: Bool = false
    
    @FocusState var isFocused: Bool
    
    // MARK: Body Start
    
    var body: some View {
        ScrollView {
            formLayer
            
            Spacer()
            
            if isAlertVisible {
                alertBoxLayer
            }
            
            if textFieldText.count >= 1 {
                taskPreviewBoxLayer
            }
            
            Spacer()
        }
        .padding(TodoListApp.edges)
        .navigationTitle("Composing a Task")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                isFocused = true
            }
        }
    }
    
    // MARK: Event Functions
    
    func onSaveButtonPress() {
        // If save is clicked, but less than 3 characters are in the text field
        guard isTextPrepared() else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            flashAlert(
                text: isAlertVisible
                ? "Task is too short. Please enter at least \(minLength) characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least \(minLength) characters in length 📏"
            )
            withSimpleFeedback(feedback: .warning)
            
            if !isFocused {
                isFocused = true
            }
            
            // 3s later, restore the button's color & symbol
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.5,
                execute: {
                    saveBtnBgColor = Color.accentColor
                    saveBtnSymbol = "checkmark"
                }
            )
            
            return
        }
        
        // Otherwise, save is successful
        
        if isFocused {
            isFocused = false
        }
        
        saveBtnBgColor = .green
        saveBtnSymbol = "plus"
        
        withAnimation(.easeInOut) {
            clearBtnWidth = 0
        }
        
        withSimpleFeedback()
        
        listViewModel.addItem(title: textFieldText)
        
        // Short delay to visually display animation before transitioning back to list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func onClearButtonPress() {
        // Capture future btn result, which is an inversion of if the str is empty
        let success: Bool = !textFieldText.isEmpty
        
        if success {
            withSimpleFeedback()
            flashAlert(
                text: "Text field cleared",
                bgColor: .accentColor,
                duration: 2.0
            )
            withAnimation(.easeOut(duration: 0.75)) {
                clearBtnSuccessAnimated = true
            }
        } else {
            withSimpleFeedback(feedback: .warning)
            withAnimation(.easeInOut) {
                clearBtnFailAnimated = true
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.4,
                execute: {
                    withAnimation(.easeInOut) {
                        clearBtnFailAnimated = false
                    }
                }
            )
        }
        
        // Animate button color transition + change symbol
        withAnimation(.linear, {
            clearBtnBgColor = success ? .green : .red
        })
        
        textFieldText = ""
        
        // Reset btn attributes w/ animation after 1s
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1,
            execute: {
                withAnimation(.linear, {
                    clearBtnBgColor = .red
                })
                withAnimation(.easeIn) {
                    clearBtnSuccessAnimated = false
                }
        })
    }
    
    // MARK: Functions
    
    func withSimpleFeedback(feedback: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedback)
    }
    
    func isTextPrepared() -> Bool {
        return textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).count >= minLength
    }
    
    func flashAlert(
        text: String, bgColor: Color = Color.red,
        fgColor: Color = Color.white, duration: Double = 15.0
    ) {
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

extension AddView {
    private var formLayer: some View {
        VStack {
            textFieldRow
            ctrlButtonRow
        }
    }
    
    private var textFieldRow: some View {
        HStack {
            TextField("Type something here...", text: $textFieldText)
                .focused($isFocused)
                .padding(.horizontal)
                .frame(height: 45)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
    
    private var ctrlButtonRow: some View {
        HStack {
            Button(
                action: onSaveButtonPress,
                label: {
                Image(systemName: saveBtnSymbol)
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(isTextPrepared() ? saveBtnBgColor : disabledBtnBg)
                    .cornerRadius(10)
            })
            Spacer()
            Button(action: onClearButtonPress, label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(clearBtnBgColor)
                    .frame(height: 55)
                    .frame(maxWidth: clearBtnWidth)
                    .overlay {
                        Image(systemName: clearBtnSymbol)
                            .rotationEffect(.degrees(clearBtnSuccessAnimated ? 180 : 0))
                            .offset(x: clearBtnFailAnimated ? -5 : 0)
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
            })
        }
    }
    
    private var taskPreviewBoxLayer: some View {
        VStack {
            HStack {
                Text("Task Preview: ")
                    .font(.title2)
                Image(systemName: isTextPrepared() ? "checkmark" : "xmark")
                    .foregroundColor(isTextPrepared() ? .green : .red)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("\(textFieldText)")
                    .padding(.leading, 1)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(5)
        .transition(.move(edge: .leading))
    }
    
    private var alertBoxLayer: some View {
        HStack {
            Text(alertTitle)
                .padding(15)
                .foregroundColor(alertFgColor)
        }
        .frame(maxWidth: .infinity)
        .background(alertBgColor)
        .cornerRadius(5)
        .foregroundColor(alertFgColor)
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2), {
                isAlertVisible = false
            })
        }
    }
}

// MARK: Preview

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddView()
        }
        .environmentObject(ListViewModel())
    }
}

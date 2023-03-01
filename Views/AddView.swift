import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var settings: SettingsStore
    
    // MARK: Stateful Vars
    
    @State var alertBoxTitle: String = ""
    @State var alertBoxBgColor: Color = .red
    @State var alertBoxFgColor: Color = .white
    @State var alertBoxVisible: Bool = false
    @State var clearBtnBgColor: Color = .red
    @State var clearBtnSymbol: String = "trash.fill"
    @State var clearBtnWidth: Double = .infinity
    @State var clearBtnSuccessAnimated: Bool = false
    @State var clearBtnFailAnimated: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    
    @State var textFieldText: String = ""
    @FocusState var isFocused: Bool
    
    // MARK: Body Start
    
    var body: some View {
        let padding: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20
        
        return ScrollView {
            VStack {
                textFieldRow
                controlButtonRow
                
                Spacer()
                
                if alertBoxVisible {
                    alertBoxLayer
                }
                
                if textFieldText.count >= 1 {
                    taskPreviewBoxLayer
                }
                
                Spacer()
            }
            .padding(padding)
        }
        .navigationTitle("Composing a Task")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                isFocused = true
            }
        }
    }
    
    private func shouldUseHaptics() -> Bool {
        $settings.shouldUseHaptics.wrappedValue
    }
    
    // MARK: Event Functions
    
    func onSaveButtonPress() {
        // If save is clicked, but less than 3 characters are in the text field
        guard isTextPrepared() else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            flashAlert(
                text: alertBoxVisible
                ? "Task is too short. Please enter at least \(TodoListApp.minTaskLength) characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least \(TodoListApp.minTaskLength) characters in length 📏"
            )
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics(), .warning)
            
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
        
        Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
        
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
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics())
            flashAlert(
                text: "Text field cleared",
                bgColor: .accentColor,
                duration: 2.0
            )
            withAnimation(.easeOut(duration: 0.75)) {
                clearBtnSuccessAnimated = true
            }
        } else {
            Haptics.withSimpleFeedback(playOut: shouldUseHaptics(), .warning)
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
    
    func isTextPrepared() -> Bool {
        return textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).count >= TodoListApp.minTaskLength
    }
    
    func flashAlert(
        text: String, bgColor: Color = Color.red,
        fgColor: Color = Color.white, duration: Double = 15.0
    ) {
        alertBoxTitle = text
        alertBoxBgColor = bgColor
        alertBoxFgColor = fgColor
    
        // In case the alert is already visible, hide it, and slide it back in after 1/2 a second
        guard !alertBoxVisible else {
            alertBoxVisible = false
            
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
            alertBoxVisible = true
        })
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: {
                withAnimation(.linear, {
                    alertBoxVisible = false
                })
            }
        )
    }
}

// MARK: Layers + Components

extension AddView {
    private var textFieldRow: some View {
        HStack {
            TextField("Type something here...", text: $textFieldText)
                .focused($isFocused)
                .padding(.horizontal)
                .frame(height: 45)
                .background(Color("TextFieldColor").gradient)
                .cornerRadius(10)
        }
    }
    
    private var controlButtonRow: some View {
        HStack {
            Button(
                action: onSaveButtonPress,
                label: {
                Image(systemName: saveBtnSymbol)
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(isTextPrepared() ? saveBtnBgColor : Color.gray.opacity(0.45))
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
            Text(alertBoxTitle)
                .padding(15)
                .foregroundColor(alertBoxFgColor)
        }
        .frame(maxWidth: .infinity)
        .background(alertBoxBgColor)
        .cornerRadius(5)
        .foregroundColor(alertBoxFgColor)
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2), {
                alertBoxVisible = false
            })
        }
    }
}

// MARK: Preview

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddView()
        }
        .environmentObject(ListViewModel())
    }
}

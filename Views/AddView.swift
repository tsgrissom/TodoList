import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    let lightRed = Color.red.opacity(0.8)
    let disabledBtnBg = Color.gray.opacity(0.7)
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertBgColor: Color = .red
    @State var alertFgColor: Color = .white
    @State var isAlertVisible: Bool = false
    @State var saveBtnBg: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var clearBtnBg: Color = .red
    @State var clearBtnSymbol: String = "trash.fill"
    @State var clearBtnWidth: Double = .infinity
    
    // MARK: Layers
    
    var body: some View {
        ScrollView {
            formLayer
            
            Spacer()
            
            if isAlertVisible {
                alertBoxLayer
            }
            
            Spacer()
        }
        .padding(14)
        .navigationTitle("Composing a Task")
    }
    
    // MARK: Functions
    
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
    
    func simpleVibration(feedback: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedback)
    }
    
    func isTextPrepared() -> Bool {
        return textFieldText.count >= 3
    }
    
    func saveBtnPressed() {
        // If save is clicked, but less than 3 characters are in the text field
        guard isTextPrepared() else {
            saveBtnBg = .red
            saveBtnSymbol = "xmark"
            
            flashAlert(
                text: isAlertVisible
                ? "Task is too short. Please enter at least 3 characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least 3 characters in length 📏"
            )
            simpleVibration(feedback: .warning)
            
            // 3s later, restore the button's color & symbol
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3,
                execute: {
                    saveBtnBg = Color.accentColor
                    saveBtnSymbol = "checkmark"
                }
            )
            
            return
        }
        
        // Otherwise, save is successful
        
        saveBtnBg = .green
        saveBtnSymbol = "plus"
        
        clearBtnWidth = 0
        
        simpleVibration(feedback: .success)
        
        listViewModel.addItem(title: textFieldText)
        
        // Short delay to visually display animation before transitioning back to list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func clearBtnPressed() {
        // Capture future btn result, which is an inversion of if the str is empty
        let success: Bool = !textFieldText.isEmpty
        
        textFieldText = ""
        
        if success {
            simpleVibration(feedback: .success)
            flashAlert(
                text: "Text field cleared",
                bgColor: .accentColor,
                duration: 4.0
            )
        } else {
            simpleVibration(feedback: .warning)
        }
        
        // Animate button color transition + change symbol
        withAnimation(.linear, {
            clearBtnBg = success ? .green : .red
        })
        
        clearBtnSymbol = success ? "checkmark" : "xmark"
        
        // Reset btn attributes w/ animation after 1s
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3,
            execute: {
                withAnimation(.linear, {
                    clearBtnBg = .red
                })
                
                clearBtnSymbol = "trash.fill"
        })
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

// MARK: Components

extension AddView {
    private var formLayer: some View {
        VStack {
            HStack {
                TextField("Type something here...", text: $textFieldText)
                    .padding(.horizontal)
                    .frame(height: 45)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            HStack {
                Button(
                    action: saveBtnPressed,
                    label: {
                    Image(systemName: saveBtnSymbol)
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isTextPrepared() ? saveBtnBg : disabledBtnBg)
                        .cornerRadius(10)
                })
                Spacer()
                Button(action: clearBtnPressed, label: {
                    Image(systemName: clearBtnSymbol)
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .frame(height: 55)
                        .frame(maxWidth: clearBtnWidth)
                        .background(!textFieldText.isEmpty ? clearBtnBg : disabledBtnBg)
                        .cornerRadius(10)
                })
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
        .padding(.bottom, 10)
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation(.linear(duration: 0.1), {
                isAlertVisible = false
            })
        }
    }
}

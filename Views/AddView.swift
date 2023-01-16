import SwiftUI

struct AddView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    let lightRed = Color.red.opacity(0.8)
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertBgColor: Color = .red
    @State var alertFgColor: Color = .white
    @State var alertVisible: Bool = false
    @State var leftBtnColor: Color = .accentColor
    @State var rightBtnColor: Color = .red
    @State var leftBtnSymbol: String = "checkmark"
    @State var rightBtnSymbol: String = "trash.fill"
    @State var rightBtnWidth: Double = .infinity
    
    // MARK: Layers
    
    var body: some View {
        VStack {
            TextField("Type something here...", text: $textFieldText)
                .padding(.horizontal)
                .frame(height: 45)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            
            buttonLayer
            
            Spacer()
            
            if alertVisible {
                alertBoxLayer
            }
            
            Spacer()
        }
        .padding(14)
        .navigationTitle("Composing a Task")
    }
    
    private var buttonLayer: some View {
        HStack {
            Button(
                action: saveBtnPressed,
                label: {
                Image(systemName: leftBtnSymbol)
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(isTextPrepared() ? leftBtnColor : Color.gray)
                    .cornerRadius(10)
            })
            Spacer()
            Button(action: clearBtnPressed, label: {
                Image(systemName: rightBtnSymbol)
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: rightBtnWidth)
                    .background(!textFieldText.isEmpty ? rightBtnColor : Color.gray)
                    .cornerRadius(10)
            })
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
        .overlay(alignment: .trailing, content: {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 35, height: 35)
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .foregroundColor(.black)
                Circle()
                    .stroke(lineWidth: 1)
                    .fill(.black)
                    .frame(width: 35, height: 35)
            }
            .offset(x: 5, y: -35)
            .onTapGesture {
                withAnimation(.linear(duration: 0.1), {
                    alertVisible = false
                })
            }
        })
        .transition(.move(edge: .bottom))
    }
    
    // MARK: Functions
    
    func isTextPrepared() -> Bool {
        return textFieldText.count >= 3
    }
    
    func saveBtnPressed() {
        guard textFieldText.count > 3 else {
            leftBtnColor = .red
            leftBtnSymbol = "xmark"
            
            flashAlert(
                text: alertVisible
                ? "Task is too short. Please enter at least 3 characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least 3 characters in length 📏"
            )
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 3,
                execute: {
                    leftBtnColor = Color.accentColor
                    leftBtnSymbol = "checkmark"
                }
            )
            
            return
        }
        
        leftBtnColor = .green
        leftBtnSymbol = "plus"
        
        rightBtnWidth = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            listViewModel.addItem(title: textFieldText)
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func clearBtnPressed() {
        // Capture future btn result, which is an inversion of if the str is empty
        let success: Bool = !textFieldText.isEmpty
        
        textFieldText = ""
        
        if success {
            flashAlert(
                text: "Text field cleared",
                bgColor: .accentColor,
                duration: 4.0
            )
        }
        
        // Animate button color transition + change symbol
        withAnimation(.linear, {
            rightBtnColor = success ? .green : .red
        })
        
        rightBtnSymbol = success ? "checkmark" : "xmark"
        
        // Reset btn attributes w/ animation after 1s
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 3,
            execute: {
                withAnimation(.linear, {
                    rightBtnColor = .red
                })
                
                rightBtnSymbol = "trash.fill"
        })
    }
    
    func flashAlert(text: String, bgColor: Color = Color.red, fgColor: Color = Color.white, duration: Double = 15.0) {
        alertTitle = text
        alertBgColor = bgColor
        alertFgColor = fgColor
    
        // In case the alert is already visible, hide it, and slide it back in after 1/2 a second
        guard !alertVisible else {
            alertVisible = false
            
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
            alertVisible = true
        })
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: {
                withAnimation(.linear, {
                    alertVisible = false
                })
            }
        )
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

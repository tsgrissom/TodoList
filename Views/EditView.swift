import SwiftUI

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    @FocusState var isFocused: Bool
    
    let item: ItemModel
    let originalText: String
    let disabledBtnBgColor = Color.gray.opacity(0.45)
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertFgColor: Color = .white
    @State var alertBgColor: Color = .red
    @State var isAlertVisible: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var resetBtnAnimated: Bool = false
    @State var resetBtnBgColor: Color = .yellow
    @State var resetBtnSymbol: String = "square.fill.on.square.fill"
    @State var resetBtnWidth: Double = .infinity
    
    init(item: ItemModel) {
        self.item = item
        self.originalText = item.title
        
        textFieldText = originalText
    }
    
    var body: some View {
        ScrollView {
            formLayer
            
            Spacer()
            
            if isAlertVisible {
                alertBoxLayer
            }
            
            Spacer()
        }
        .navigationTitle("Editing Task")
        .padding()
    }
    
    func saveBtnPressed() {
        guard textFieldText.count >= 12 else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            flashAlert(
                text: isAlertVisible
                ? "Task is too short. Please enter at least 12 characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least 12 characters in length 📏"
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
        
        resetBtnWidth = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            listViewModel.updateItem(item: i)
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func undoBtnPressed() {
        /*
          Calculate new undo button
          Empty text = Yellow button which copies the placeholder text into the text field
          Some text = Red button which empties the text field
         */
        if textFieldText.isEmpty {
            textFieldText = originalText
            withAnimation(.linear) {
                resetBtnBgColor = .red
            }
            resetBtnSymbol = "trash.fill"
        } else {
            textFieldText = ""
            withAnimation(.linear) {
                resetBtnBgColor = .yellow
            }
            resetBtnSymbol = "square.fill.on.square.fill"
        }
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
    
    private func getTrimmedText() -> String {
        return textFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

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
        
        return HStack {
            Button(
                action: saveBtnPressed,
                label: {
                Image(systemName: saveBtnSymbol)
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(isEqualToOriginal ? disabledBtnBgColor : saveBtnBgColor)
                    .cornerRadius(10)
            })
            Spacer()
            Button(action: undoBtnPressed, label: {
                Image(systemName: resetBtnSymbol)
                    .rotationEffect(.degrees(resetBtnAnimated ? 360 : 0))
                    
                    .foregroundColor(.white)
                    .imageScale(.large)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(resetBtnBgColor)
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
        .transition(.move(edge: .bottom))
        .onTapGesture {
            withAnimation(.linear(duration: 0.1), {
                isAlertVisible = false
            })
        }
    }
}

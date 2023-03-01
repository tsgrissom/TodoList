import SwiftUI

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    // MARK: Constants
    
    let item: ItemModel, originalText: String
    
    // MARK: Stateful Vars

    @State var showAlert: Bool = false
    @State var alertBoxTitle: String = ""
    @State var alertBoxBgColor: Color = .red
    @State var alertBoxFgColor: Color = .white
    @State var alertBoxVisible: Bool = false
    @State var clearBtnAnimated: Bool = false
    @State var clearBtnBgColor: Color = .red
    @State var clearBtnSymbol: String = "trash.fill"
    @State var clearBtnWidth: Double = .infinity
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var restoreBtnBgColor: Color = .yellow
    @State var restoreBtnSymbol: String = "square.on.square"
    
    @State var textFieldText: String = ""
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
            VStack {
                restoreButtonLayer
                .padding(.vertical, 9)
                
                formLayer
                controlButtonRow
                
                Spacer()
                
                if alertBoxVisible {
                    alertBoxLayer
                        .padding(.top, 10)
                        .transition(.move(edge: .leading))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2), {
                                alertBoxVisible = false
                            })
                        }
                    Spacer()
                }
            }
            .padding(TodoListApp.edges)
            .navigationTitle("Editing Task")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    isFocused = true
                }
            }
        }
    }
    
    // MARK: Event Functions
    
    func onSaveButtonPress() {
        let minLength = TodoListApp.minTaskLength
        
        guard textFieldText.count >= minLength else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            Haptics.withSimpleFeedback(type: .warning)
            flashAlert(
                text: alertBoxVisible
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
        
        saveBtnBgColor = .green
        saveBtnSymbol = "plus"
        
        clearBtnWidth = 0
        
        Haptics.withSimpleFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            listViewModel.updateItem(item: ItemModel(id: item.id, title: textFieldText, isCompleted: item.isCompleted))
            presentationMode.wrappedValue.dismiss()
        })
    }
    
    func onClearButtonPress() {
        guard !textFieldText.isEmpty else {
            clearBtnSymbol = "xmark"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                clearBtnSymbol = "trash.fill"
            }
            
            Haptics.withSimpleFeedback(type: .warning)
            
            return
        }
        
        // Otherwise, text field is not empty, clear it, play fx
        
        textFieldText = ""
        clearBtnBgColor = .green
        
        withAnimation(.easeIn) {
            clearBtnAnimated = true
        }
        
        Haptics.withSimpleFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeIn) {
                clearBtnBgColor = .red
                clearBtnAnimated = false
            }
        }
    }
    
    func onRestoreButtonPress() {
        if !textFieldText.isEmpty {
            Haptics.withSimpleFeedback(type: .warning)
            restoreBtnSymbol = "xmark"
        } else {
            textFieldText = originalText
            Haptics.withSimpleFeedback()
            restoreBtnSymbol = "arrow.down"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            restoreBtnSymbol = "square.on.square"
        }
    }
    
    // MARK: Functions
    
    func getRestoreConfirmAlert() -> Alert {
        Alert(
            title: Text("Clear what you've written?"),
            message: Text("This action cannot be undone"),
            primaryButton: .destructive(Text("Confirm"), action: {
                textFieldText = originalText
                Haptics.withSimpleFeedback()
            }),
            secondaryButton: .cancel()
        )
    }
    
    func getTrimmedText() -> String {
        return textFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isTextPrepared() -> Bool {
        return getTrimmedText().count >= TodoListApp.minTaskLength
    }
    
    func flashAlert(text: String, bgColor: Color = Color.red, fgColor: Color = Color.white, duration: Double = 15.0) {
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

extension EditView {
    private var formLayer: some View {
        HStack {
            TextField(originalText, text: $textFieldText)
                .padding(.horizontal)
                .frame(height: 45)
                .background(Color("TextFieldColor").gradient)
                .cornerRadius(10)
                .focused($isFocused)
        }
    }
    
    private var restoreButtonLayer: some View {
        VStack {
            HStack {
                Button(action: onRestoreButtonPress) {
                    Text("Restore original text")
                        .fontWeight(.bold)
                    Image(systemName: restoreBtnSymbol)
                }
                .buttonStyle(.bordered)
                .tint(restoreBtnBgColor)
                .frame(height: 20)
                Spacer()
            }
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
                        .background(isEqualToOriginal ? Color.gray.opacity(0.45) : saveBtnBgColor)
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
        }
    }
    
    private var alertBoxLayer: some View {
        HStack {
            Text(alertBoxTitle)
                .padding(15)
                .foregroundColor(alertBoxFgColor)
        }
        .frame(maxWidth: .infinity)
        .background(alertBoxBgColor)
        .cornerRadius(10)
        .foregroundColor(alertBoxFgColor)
    }
}

// MARK: Preview

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditView(item: ItemModel(
                title: "Lorem ipsum dolor...",
                isCompleted: false
            ))
        }
        .environmentObject(ListViewModel())
    }
}

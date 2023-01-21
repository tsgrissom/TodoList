//
//  EditView.swift
//  TodoList
//
//  Created by Tyler Grissom on 1/14/23.
//

import SwiftUI

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var listViewModel: ListViewModel
    
    let item: ItemModel
    var originalText: String = "Original text"
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertFgColor: Color = .white
    @State var alertBgColor: Color = .red
    @State var isAlertVisible: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var resetBtnAnimated: Bool = false
    @State var resetBtnBgColor: Color = .red
    @State var resetBtnSymbol: String = "arrow.clockwise"
    @State var resetBtnWidth: Double = .infinity
    
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
    
    private var formLayer: some View {
        VStack {
            HStack {
                TextField(originalText, text: $textFieldText)
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
                        .background(saveBtnBgColor)
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
    
    func saveBtnPressed() {
        guard textFieldText.count > 3 else {
            saveBtnBgColor = .red
            saveBtnSymbol = "xmark"
            
            flashAlert(
                text: isAlertVisible
                ? "Task is too short. Please enter at least 3 characters." // Provide second text if they click-spam for UX
                : "Tasks must be at least 3 characters in length 📏"
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

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditView(item: ItemModel(title: "Lorem ipsum dolor...", isCompleted: false))
        }
        .environmentObject(ListViewModel())
    }
}
                

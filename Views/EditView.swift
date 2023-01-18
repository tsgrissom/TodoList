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
    let originalText: String = "Original text"
    
    @State var textFieldText: String = ""
    @State var alertTitle: String = ""
    @State var alertFgColor: Color = .white
    @State var alertBgColor: Color = .red
    @State var alertVisible: Bool = false
    @State var saveBtnBgColor: Color = .accentColor
    @State var saveBtnSymbol: String = "checkmark"
    @State var resetBtnAnimated: Bool = false
    @State var resetBtnBgColor: Color = .red
    @State var resetBtnSymbol: String = "arrow.clockwise"
    
    var body: some View {
        ScrollView {
            formLayer
            
            Spacer()
            
            if alertVisible {
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
                        .background(saveBtnBgColor)
                        .cornerRadius(10)
                })
                Spacer()
                Button(action: undoBtnPressed, label: {
                    Image(systemName: resetBtnSymbol)
                        .rotationEffect(.degrees(resetBtnAnimated ? 180 : 0))
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
    
    func saveBtnPressed() {
        guard textFieldText.count > 3 else {
            
            return
        }
        
        
    }
    
    func undoBtnPressed() {
        withAnimation(.linear(duration: 0.5), {
            resetBtnAnimated.toggle()
        })
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
                

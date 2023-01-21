//
//  ListRowView.swift
//  TodoList
//
//  Created by Tyler Grissom on 1/10/23.
//

import SwiftUI

struct ListRowView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listViewModel: ListViewModel
    
    let item: ItemModel
    
    var body: some View {
        HStack {
            let checkboxFgColor: Color = colorScheme == .dark ? .white : .black
            Image(systemName: item.isCompleted ? "checkmark.circle" : "circle")
                .foregroundColor(item.isCompleted ? .accentColor : checkboxFgColor)
                .onTapGesture {
                    listViewModel.updateItem(item: item)
                    simpleVibration(feedback: .success)
                }
            NavigationLink(destination: EditView(item: item)) {
                Text(item.title)
            }
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, 8)
    }
    
    func simpleVibration(feedback: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(feedback)
    }
    
    func isDarkMode() -> Bool {
        colorScheme == .dark
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var item1 = ItemModel(title: "First item!", isCompleted: false)
    static var item2 = ItemModel(title: "Second item.", isCompleted: true)
    
    static var previews: some View {
        Group {
            ListRowView(item: item1)
            ListRowView(item: item2)
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(ListViewModel())
    }
}

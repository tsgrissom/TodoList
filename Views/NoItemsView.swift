//
//  EmptyListView.swift
//  TodoList
//
//  Created by Tyler Grissom on 1/10/23.
//

import SwiftUI

struct NoItemsView: View {
    
    let title: String = "No tasks yet..."
    let blob: String = "Looking to organize your life? Taskmaster can help with that. Press the big purple button below to begin composing your first task."
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                Text(blob)
                    .padding(.bottom, 20)
            }
            .multilineTextAlignment(.center)
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NoItemsView()
                .navigationTitle("Taskmaster")
        }
    }
}

import SwiftUI

/*
 Subview of ListView which contains the layout for each individual task item, represented as a row of a List
 */
struct ListRowView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var listViewModel: ListViewModel
    
    let item: ItemModel
    
    var body: some View {
        HStack {
            let checkboxFgColor: Color = colorScheme == .dark ? .white : .black
            let checkboxSymbol = item.isCompleted ? "checkmark.circle" : "circle"
            Image(systemName: checkboxSymbol)
                .foregroundColor(item.isCompleted ? .accentColor : checkboxFgColor)
                .onTapGesture {
                    listViewModel.updateItem(item: item)
                    Haptics.withSimpleFeedback()
                }
            NavigationLink(destination: EditView(item: item)) {
                Text(item.title)
            }
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, 8)
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

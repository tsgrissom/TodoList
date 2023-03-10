import SwiftUI

/*
 Subview of ListView which contains the layout for each individual task item, represented as a row of a List
 */
struct ListRowView: View {
    
    @Environment(\.colorScheme) var systemColorScheme
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var settings: SettingsStore
    
    let item: ItemModel
    
    var body: some View {
        HStack {
            let checkboxFgColor: Color = systemColorScheme == .dark ? .white : .black
            let checkboxSymbol = item.isCompleted ? "checkmark.circle" : "circle"
            Image(systemName: checkboxSymbol)
                .foregroundColor(item.isCompleted ? .accentColor : checkboxFgColor)
                .onTapGesture {
                    listViewModel.updateItem(item: item)
                    Haptics.withSimpleFeedback(playOut: $settings.shouldUseHaptics.wrappedValue)
                }
            NavigationLink(destination: EditView(item: item)) {
                Text(item.title)
            }
            Spacer()
        }
        .font(.title2)
        .padding(.vertical, 8)
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

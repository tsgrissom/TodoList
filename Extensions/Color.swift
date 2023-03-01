import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    
    init?(named name: String) {
        guard let color = UIColor(named: name) else {
            return nil
        }
        
        self.init(color)
    }
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let danger = Color("DangerColor")
    let textFieldColor = Color("TextFieldColor")
}

import Foundation
import SwiftUI

extension Color {
    init?(named name: String) {
        guard let color = UIColor(named: name) else {
            return nil
        }
        
        self.init(color)
    }
}

public enum ThemeBackground: String, CaseIterable {
    case dark
    case system
    case light
}

public enum ThemeAccent: String, CaseIterable {
    case purple
    case blue
}

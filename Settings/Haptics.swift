import Foundation
import SwiftUI

final class Haptics {
    static func withSimpleFeedback(playOut: Bool = true, _ type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        if playOut {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
    
    static func withImpact(playOut: Bool = true, _ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1) {
        if playOut {
            UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
        }
    }
}

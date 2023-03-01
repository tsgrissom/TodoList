import Foundation
import Combine

final class SettingsStore: ObservableObject {
    
    private enum Keys {
        static let debugEnabled = "DebugEnabled"
        static let alphabetizeList = "AlphabetizeList"
        static let useHaptics = "UseHaptics"
        static let openSettingsOnLeftEdgeSlide = "OpenSettingsOnLeftEdgeSlide"
        static let autoDeleteTaskOnCheckoff = "AutoDeleteTaskOnCheckoff"
        static let themeBg = "ThemeBackground"
        static let themeAccent = "ThemeAccent"
    }
    
    private let cancellable: Cancellable
    private let defaults: UserDefaults
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        defaults.register(defaults: [
            Keys.debugEnabled: false,
            Keys.alphabetizeList: true,
            Keys.useHaptics: true,
            Keys.openSettingsOnLeftEdgeSlide: true,
            Keys.autoDeleteTaskOnCheckoff: false,
            Keys.themeBg: ThemeBackground.system.rawValue,
            Keys.themeAccent: ThemeAccent.purple.rawValue
        ])
        
        cancellable = NotificationCenter.default
            .publisher(for:  UserDefaults.didChangeNotification)
            .map { _ in () }
            .subscribe(objectWillChange)
    }
    
    var isDebugEnabled: Bool {
        set { defaults.set(newValue, forKey: Keys.debugEnabled) }
        get { defaults.bool(forKey: Keys.debugEnabled) }
    }
    
    var shouldAlphabetizeList: Bool {
        set { defaults.set(newValue, forKey: Keys.alphabetizeList) }
        get { defaults.bool(forKey: Keys.alphabetizeList) }
    }
    
    var shouldUseHaptics: Bool {
        set { defaults.set(newValue, forKey: Keys.useHaptics) }
        get { defaults.bool(forKey: Keys.useHaptics) }
    }
    
    var shouldOpenSettingsOnLeftEdgeSlide: Bool {
        set { defaults.set(newValue, forKey: Keys.openSettingsOnLeftEdgeSlide) }
        get { defaults.bool(forKey: Keys.openSettingsOnLeftEdgeSlide) }
    }
    
    var shouldAutoDeleteTaskOnCheckoff: Bool {
        set { defaults.set(newValue, forKey: Keys.autoDeleteTaskOnCheckoff) }
        get { defaults.bool(forKey: Keys.autoDeleteTaskOnCheckoff) }
    }
    
    var themeBg: ThemeBackground {
        get {
            return defaults.string(forKey: Keys.themeBg)
                .flatMap { ThemeBackground(rawValue: $0) } ?? .system
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.themeBg)
        }
    }
    
    var themeAccent: ThemeAccent {
        get {
            return defaults.string(forKey: Keys.themeAccent)
                .flatMap { ThemeAccent(rawValue: $0) } ?? .purple
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Keys.themeAccent)
        }
    }
}

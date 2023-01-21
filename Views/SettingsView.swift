import SwiftUI

struct SettingsView: View {
    
    @State var shouldForceDarkMode: Bool = false
    @State var isDebugEnabled: Bool = false
    @State var shouldAlphabetize: Bool = true
    @State var shouldAutoDeleteTaskOnCheckoff: Bool = false
    @State var appTheme: String = "default"
    
    var body: some View {
        NavigationView {
            contentLayer
        }
    }
    
    var contentLayer: some View {
        VStack {
            List {
                Section("Customize preferences") {
                    Toggle(isOn: $shouldForceDarkMode, label: {
                        Text("Force dark-mode")
                    })
                    Toggle(isOn: $isDebugEnabled, label: {
                        Text("Debug enabled")
                    })
                    Picker("App theme", selection: $appTheme, content: {
                        Text("Default (purple)").tag("default")
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                    })
                }
                
                Section("Customize the list behavior") {
                    Toggle(isOn: $shouldAlphabetize, label: {
                        Text("Alphabetize task items")
                    })
                    Toggle(isOn: $shouldAutoDeleteTaskOnCheckoff, label: {
                        Text("Auto-delete task on check-off")
                    })
                }
            }
            .tint(.accentColor)
            .padding(.top, 2)
            Spacer()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

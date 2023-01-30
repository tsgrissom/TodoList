import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    // MARK: Stateful Vars
    
    @State var showAlert: Bool = false
    @State var isDebugEnabled: Bool = UserDefaults.standard.bool(forKey: "DebugEnabled")
    @State var shouldAlphabetize: Bool = UserDefaults.standard.bool(forKey: "AlphabetizeList")
    @State var shouldUseHaptics: Bool = UserDefaults.standard.bool(forKey: "UseHaptics")
    @State var shouldOpenSettingsOnSlideFromLeftEdge: Bool = UserDefaults.standard.bool(forKey: "OpenSettingsOnSlideFromLeftEdge")
    @State var shouldAutoDeleteTaskOnCheckoff: Bool = UserDefaults.standard.bool(forKey: "AutoDeleteTaskOnCheckoff")
    @State var appTheme: String = UserDefaults.standard.string(forKey: "Theme") ?? "Default"
    
    // MARK: Body Start
    
    var body: some View {
        NavigationView {
            contentLayer
        }
    }
    
    // MARK: Functions
    
    func getClearConfirmAlert() -> Alert {
        Alert(
            title: Text("Clear your tasks?"),
            message: Text("\(listViewModel.items.count) tasks will be cleared (cannot be undone)"),
            primaryButton: .destructive(Text("Confirm"), action: {
                listViewModel.items = [ItemModel]()
            }),
            secondaryButton: .cancel()
        )
    }
}

// MARK: Layers + Components

extension SettingsView {
    var contentLayer: some View {
        VStack {
            List {
                listPreferencesSection
                listBehaviorSection
                listMiscSection
            }
            .tint(.accentColor)
            Spacer()
        }
        .padding(TodoListApp.edges)
        .navigationTitle("Settings")
    }
    
    var listPreferencesSection: some View {
        Section("Application preferences") {
            Picker("App theme", selection: $appTheme, content: {
                Text("Default (purple)").tag("default")
                Text("Dark").tag("dark")
                Text("Light").tag("light")
            })
            Toggle(isOn: $shouldUseHaptics, label: {
                Text("Use haptic feedback (iPhone)")
            })
            Toggle(isOn: $shouldOpenSettingsOnSlideFromLeftEdge, label: {
                Text("Swipe from left edge opens settings")
            })
            Toggle(isOn: $isDebugEnabled, label: {
                Text("Debug enabled")
            })
        }
    }
    
    var listBehaviorSection: some View {
        Section("Customize list behavior") {
            Toggle(isOn: $shouldAlphabetize, label: {
                Text("Alphabetize task items")
            })
            Toggle(isOn: $shouldAutoDeleteTaskOnCheckoff, label: {
                Text("Auto-delete task on check-off")
            })
        }
    }
    
    var listMiscSection: some View {
        Section("Miscellaneous") {
            HStack {
                Button(action: {
                    showAlert.toggle()
                }) {
                    Text("Clear tasks")
                }
                .buttonStyle(.bordered)
                .background(.red)
                .cornerRadius(5)
                .foregroundColor(.white)
                .padding(2)
                .alert(isPresented: $showAlert, content: getClearConfirmAlert)
            }
        }
    }
}

// MARK: Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ListViewModel())
    }
}

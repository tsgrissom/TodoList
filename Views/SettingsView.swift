import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var settings: SettingsStore
    
    // MARK: Stateful Vars
    
    @State var showAlert: Bool = false
    
    // MARK: Body Start
    
    var body: some View {
        VStack {
            List {
                listPreferencesSection
                listBehaviorSection
                listMiscSection
            }
            .tint(.accentColor)
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Settings")
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
    
    func getEmptyListAlert() -> Alert {
        Alert(title: Text("There's no tasks to dismiss!"))
    }
}

// MARK: Layers + Components

extension SettingsView {
    var listPreferencesSection: some View {
        Section("Application preferences") {
            Picker("Background", selection: $settings.themeBg, content: {
                Text("System").tag(ThemeBackground.system)
                Text("Dark").tag(ThemeBackground.dark)
                Text("Light").tag(ThemeBackground.light)
            })
            Picker("Accent", selection: $settings.themeAccent) {
                Text("Default (Purple)").tag(ThemeAccent.purple)
                Text("iOS (Blue)").tag(ThemeAccent.blue)
            }
            Toggle(isOn: $settings.shouldUseHaptics, label: {
                Text("Use haptic feedback (iPhone)")
            })
            Toggle(isOn: $settings.shouldOpenSettingsOnLeftEdgeSlide, label: {
                Text("Swipe from left edge opens settings")
            })
            Toggle(isOn: $settings.isDebugEnabled, label: {
                Text("Debug enabled")
            })
        }
    }
    
    var listBehaviorSection: some View {
        Section("Customize list behavior") {
            Toggle(isOn: $settings.shouldAlphabetizeList, label: {
                Text("Alphabetize task items")
            })
            Toggle(isOn: $settings.shouldAutoDeleteTaskOnCheckoff, label: {
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
                .background(Color("Danger"))
                .cornerRadius(5)
                .foregroundColor(.white)
                .padding(2)
                .alert(isPresented: $showAlert, content: listViewModel.items.isEmpty ? getEmptyListAlert : getClearConfirmAlert)
            }
        }
    }
}

// MARK: Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .environmentObject(ListViewModel())
        }
    }
}

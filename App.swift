//  Started by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import SwiftUI
import AppKit
import SafariServices

enum AlertType: Int {
    case installed
    case deleted
}

struct InstallButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(Font.system(size: 14, weight: .regular))
            .foregroundColor(configuration.isPressed ? Color.black.opacity(0.5) : Color.black)
            .frame(width: 213, height: 35)
            .background(Color(red: 0.97, green: 0.77, blue: 0.33))
            .cornerRadius(35 / 2)
    }
    
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        PFMoveToApplicationsFolderIfNecessary()
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}

@main
struct Window: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.scenePhase) private var scenePhase
    @State var localizedError: String?
    @State var browsers: [Browser] = []
    @State var showAlert: AlertType? = nil
    @State var isEnabledForSafari = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("Background")
                
                VStack {
                    VStack {
                        Spacer().frame(height: 32.0)
                        Image("logo")
                            .frame(width: 120.0)
                        Spacer().frame(height: 24.0)
                        Text("Lightning buzz for your Browser")
                            .font(Font.system(size: 24.0, weight: .bold))
                        Spacer().frame(height: 4.0)
                        Text("Alby brings Bitcoin payments to the web with in-browser payments and identity, all with your own wallet.\n Install Alby for you browser and use Alby directly in your browser.")
                            .font(Font.system(size: 14.0, weight: .regular))
                            .foregroundColor(Color.primary.opacity(0.7))
                        
                        
                    }.multilineTextAlignment(.center)
                       
                    Spacer().frame(height: 16.0)
                    
                    HStack(spacing: 40.0) {
                        ForEach(browsers) {
                            view(for: $0)
                        }
                    }
                    
                    VStack {
                        VStack {
                            Spacer().frame(height: 16.0)
                            Text("(You can close this app after installation, but keep it in you Applications folder.)")
                                .font(Font.system(size: 12.0, weight: .regular))
                                .foregroundColor(Color.primary.opacity(0.6))
                        }}
                    Spacer().frame(height: 60.0)
                }
            }
            .navigationTitle("Alby")
            .frame(width: (CGFloat(columns) * 213.0) + (CGFloat(columns - 1) * 40.0) + 78.0, height: 570.0)
            .alert(isPresented: .constant(localizedError?.isEmpty == false)) {
                Alert(title: Text(localizedError!))
            }
            .alert(isPresented: .constant(showAlert != nil)) {
                Alert(title: Text(showAlert == .installed ? "Alby is configured successfully. Now let’s add it to your browser" : "Companion App Deleted"))
            }
            .onAppear {
                seek()
            }
        }
        .onChange(of: scenePhase) { _ in
            checkIfIsEnabledForSafari()
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button {
                    seek()
                } label: {
                    Text("Refresh")
                }
                .keyboardShortcut("R", modifiers: [.command])
            }
        }
    }

    private func seek() {
        // browsers = [Browser(id: "com.apple.Safari", appSupportFolder: nil, chrome: nil)] + Browser.installed
        browsers = Browser.installed
        // checkIfIsEnabledForSafari()
    }

    private var columns: Int {
        browsers.count < 3 ? 3 : browsers.count
    }

    private func checkIfIsEnabledForSafari() {
        Task {
            do {
                isEnabledForSafari = try await SFSafariExtensionManager.stateOfSafariExtension(withIdentifier: safariExtensionBundleIdentifier).isEnabled
            } catch {
                localizedError = error.localizedDescription
                isEnabledForSafari = false
            }
        }
    }

    var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.green)
            .font(.largeTitle.bold())
    }

    @ViewBuilder
    func view(for browser: Browser) -> some View {
        VStack(spacing: 16.0) {
            ZStack {
                Color(red: 1.00, green: 0.98, blue: 0.93)
                
                if let icon = browser.icon {
                    ZStack {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 150.0, height: 150.0)
                        if let installed = browser.companionInstalled {
                            if installed { checkmark }
                        } else {
                            if isEnabledForSafari {
                                checkmark
                            }
                        }
                    }
                }
            }
            .frame(width: 213.0, height: 213.0)
            .cornerRadius(16.0)
            
            Button {
                if browser.chrome == nil {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: safariExtensionBundleIdentifier) { error in
                        guard let error = error else {
                            return
                        }
                        localizedError = error.localizedDescription
                    }
                } else {
                    installOrRemoveCompanion(for: browser)
                }
            } label: {
                if let installed = browser.companionInstalled {
                    if installed {
                        Text("Remove")
                    } else {
                        Text("Install")
                    }
                } else {
                    if isEnabledForSafari {
                        Text("Disable")
                    } else {
                        Text("Enable")
                    }
                }
            }
            .buttonStyle(InstallButtonStyle())
        }
    }

    private func installOrRemoveCompanion(for browser: Browser) {
        guard let installed = browser.companionInstalled else {
            return
        }
        if installed {
            // Remove JSON
            do {
                try browser.remove()
                showAlert = installed ? nil : .deleted
            } catch {
                localizedError = error.localizedDescription
            }
        } else {
            // Install
            do {
                // Copy JSON
                try browser.install()
                showAlert = installed ? .installed : nil
                // Install Extension
                if let url = URL(string: "https://getalby.com/install/")?.appendingPathComponent(browser.id),
                   let application = browser.application {
                    NSWorkspace.shared.open([url], withApplicationAt: application, configuration: NSWorkspace.OpenConfiguration())
                }
            } catch {
                localizedError = error.localizedDescription
            }
        }
        seek()
    }
}

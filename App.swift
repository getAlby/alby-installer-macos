//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import SwiftUI
import AppKit

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
    }
}

@main
struct Window: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.scenePhase) private var scenePhase
    @State var localizedError: String?
    @State var loaded = false
    @State var browsers: [Browser] = []
    @State var showAlert: AlertType? = nil

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(red: 1.00, green: 0.99, blue: 0.98)
                
                VStack {
                    VStack {
                        Spacer().frame(height: 32.0)
                        Image("logo")
                            .frame(width: 120.0)
                        Spacer().frame(height: 24.0)
                        Text("Lightning buzz for your Browser")
                            .font(Font.system(size: 24.0, weight: .bold))
                            .foregroundColor(Color.black)
                        Spacer().frame(height: 4.0)
                        Text("Alby brings Bitcoin to the web with in-browser payments and identity, no account required.")
                            .font(Font.system(size: 14.0, weight: .regular))
                            .foregroundColor(Color.black.opacity(0.7))
                    }.multilineTextAlignment(.center)
                       
                    Spacer().frame(height: 16.0)
                    
                    HStack(spacing: 40.0) {
                        if loaded {
                            if browsers.isEmpty {
                                VStack {
                                    Spacer()
                                    Text("No supported Browser found")
                                    Button("Try again", action: seek)
                                    Spacer()
                                }
                            }
                            ForEach(browsers) {
                                view(for: $0)
                            }
                        } else {
                            Text("Seeking Browsers...")
                                .font(.largeTitle)
                        }
                    }
                    
                    Spacer().frame(height: 60.0)
                }
            }
            .preferredColorScheme(.light)
            .navigationTitle("Alby Installer")
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
    }

    private var columns: Int {
        browsers.count < 3 ? 3 : browsers.count
    }

    private func seek() {
        browsers = Browser.installed
        loaded = true
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
                        if browser.companionInstalled {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .font(.largeTitle.bold())
                        }
                    }
                }
            }
            .frame(width: 213.0, height: 213.0)
            .cornerRadius(16.0)
            
            Button {
                if browser.companionInstalled {
                    // Remove JSON
                    do {
                        try browser.remove()
                        showAlert = !browser.companionInstalled ? .deleted : nil
                    } catch {
                        localizedError = error.localizedDescription
                    }
                } else {
                    // Install
                    do {
                        // Copy JSON
                        try browser.install()
                        showAlert = browser.companionInstalled ? .installed : nil
                        // Install Extension
                        if let url = URL(string: "https://getalby.com/install/")?.appendingPathComponent(browser.id),
                           let application = browser.application {
                            NSWorkspace.shared.open([url], withApplicationAt: application, configuration: NSWorkspace.OpenConfiguration())
                        }
                    } catch {
                        localizedError = error.localizedDescription
                    }
                }
            } label: {
                if browser.companionInstalled {
                    Text("Remove")
                } else {
                    Text("Install")
                }
            }
            .buttonStyle(InstallButtonStyle())
        }
    }
}

struct Browser: Identifiable {
    let id: String
    let appSupportFolder: String
    let chrome: Bool

    var json: String? {
        guard let bundle = Bundle.main.resourcePath else {
            return nil
        }
        // https://github.com/getAlby/alby-companion-rs/releases
        return """
            {
            "name": "alby",
            "description": "Alby native messaging to connect to nodes behind Tor",
            "path": "\(bundle)/alby",
            "type": "stdio",
            "allowed_\(chrome ? "origins" : "extensions")": ["\(chrome ? "chrome-extension://iokeahhehimjnekafflcihljlcjccdbe/" : "extension@getalby.com")"]
            }
            """
    }

    static var all: [Browser] {
        [Browser(id: "org.mozilla.firefox", appSupportFolder: "Mozilla", chrome: false),
         Browser(id: "com.google.Chrome", appSupportFolder: "Google/Chrome", chrome: true),
         Browser(id: "org.chromium.Chromium", appSupportFolder: "Chromium", chrome: true)]
    }

    static var installed: [Browser] {
        all.filter { $0.path != nil }
    }

    var path: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    }

    private var nativeMessagingURL: URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = appSupportURL.appendingPathComponent(appSupportFolder).appendingPathComponent("NativeMessagingHosts")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        return url
    }

    var albyJsonURL: URL {
        nativeMessagingURL.appendingPathComponent("alby").appendingPathExtension("json")
    }

    var companionInstalled: Bool {
        FileManager.default.fileExists(atPath: albyJsonURL.path)
    }

    var exists: Bool {
        FileManager.default.fileExists(atPath: nativeMessagingURL.path)
    }

    func install() throws {
        try json?.write(to: albyJsonURL, atomically: true, encoding: .ascii)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(at: albyJsonURL)
    }

    var application: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    }

    var icon: NSImage? {
        if let url = application {
            if let image = Bundle(url: url)?.resourceURL?.appendingPathComponent(chrome ? "app" : "firefox").appendingPathExtension("icns") {
                return NSImage(contentsOf: image)
            }
        }
        return nil
    }
}

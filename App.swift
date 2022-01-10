//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import SwiftUI

enum AlertType: Int {
    case installed
    case deleted
}

@main
struct Window: App {
    @State var localizedError: String?
    @State var loaded = false
    @State var browsers: [Browser] = []
    @State var showAlert: AlertType? = nil

    var body: some Scene {
        WindowGroup {
            HStack(alignment: .bottom) {
                if loaded {
                    if browsers.count > 0 {
                        VStack(alignment: .leading) {
                            EmptyView()
                                .frame(width: 128, height: 128)
                            Text("Install Alby:")
                        }
                        .padding(.leading)
                        .font(.title)
                    } else {
                        VStack {
                            Text("No supported Browser found")
                            Button("Try again", action: seek)
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
            .alert(isPresented: .constant(localizedError?.isEmpty == false)) {
                Alert(title: Text(localizedError!))
            }
            .alert(isPresented: .constant(showAlert != nil)) {
                Alert(title: Text("Companion App " + (showAlert == .installed ? "Installed" : "Deleted")))
            }
            .frame(width: CGFloat((browsers.count * 128) + 280), height: 240)
            .onAppear {
                seek()
            }
        }
    }

    private func seek() {
        browsers = Browser.installed
        loaded = true
    }

    @ViewBuilder
    func view(for browser: Browser) -> some View {
        VStack {
            if let icon = browser.icon {
                ZStack {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 128, height: 128)
                    if browser.companionInstalled {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.largeTitle.bold())
                    }
                }
            }
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

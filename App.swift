//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import SwiftUI

@main
struct Window: App {
    @State var localizedError: String?
    @State var loaded = false
    @State var browsers: [Browser] = []

    var body: some Scene {
        WindowGroup {
            HStack(alignment: .bottom) {
                if loaded {
                    VStack(alignment: .leading) {
                        EmptyView()
                            .frame(width: 128, height: 128)
                        Label("Install the extension", systemImage: "1.circle")
                        Label("Install the companion", systemImage: "2.circle")
                    }
                    .padding(.leading)
                    .font(.title)
                    ForEach(browsers) {
                        view(for: $0)
                    }
                    Spacer()
                } else {
                    Text("Seeking Browsers...")
                        .font(.largeTitle)
                }
            }
            .alert(isPresented: .constant(localizedError?.isEmpty == false)) {
                Alert(title: Text(localizedError!))
            }
            .frame(width: CGFloat((browsers.count * 128) + 270), height: 240)
            .onAppear {
                browsers = Browser.installed
                loaded = true
            }
        }
    }

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
            Button("Install") { // Extension (Also green check mark?!)
                do {
                    if let url = URL(string: "https://getalby.com/install/")?.appendingPathComponent(browser.id),
                    let application = browser.application {
                        NSWorkspace.shared.open([url], withApplicationAt: application, configuration: NSWorkspace.OpenConfiguration())
                        try browser.installOrRemove()
                    }
                } catch {
                    localizedError = error.localizedDescription
                }
            }
            Button {
                do {
                    try browser.installOrRemove()
                } catch {
                    localizedError = error.localizedDescription
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
        return """
            {
            "name": "alby",
            "description": "Alby native messaging to connect to nodes behind Tor",
            "path": "\(bundle)/alby",
            "type": "stdio",
            "allowed_\(chrome ? "origins" : "extensions")": [ "extension@getalby.com" ]
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

    func installOrRemove() throws {
        if companionInstalled {
            try FileManager.default.removeItem(at: albyJsonURL)
        } else {
            try json?.write(to: albyJsonURL, atomically: true, encoding: .ascii)
        }
    }

    var application: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    }

    var icon: NSImage? {
        if let url = application, let bundle = Bundle(url: url)?.resourcePath,
           let files = try? FileManager.default.contentsOfDirectory(atPath: bundle) {
            for file in files {
                if file.hasSuffix("icns") {
                    if let image = Bundle(url: url)?.resourceURL?.appendingPathComponent(file) {
                        return NSImage(contentsOf: image)
                    }
                }
            }
        }
        return nil
    }
}

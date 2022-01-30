import AppKit

let safariExtensionBundleIdentifier = "com.getalby.Alby.macOS"

struct Browser: Identifiable {
    let id: String
    let appSupportFolder: String?
    let chrome: Bool?

    var json: String? {
        guard let bundle = Bundle.main.resourcePath, let chrome = chrome else {
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
         Browser(id: "org.chromium.Chromium", appSupportFolder: "Chromium", chrome: true),
         Browser(id: "com.vivaldi.Vivaldi", appSupportFolder: "Vivaldi", chrome: true)]
    }

    static var installed: [Browser] {
        all.filter { $0.path != nil }
    }

    var path: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    }

    private var nativeMessagingURL: URL? {
        guard let appSupportFolder = appSupportFolder else {
            return nil
        }
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = appSupportURL.appendingPathComponent(appSupportFolder).appendingPathComponent("NativeMessagingHosts")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        return url
    }

    var albyJsonURL: URL? {
        nativeMessagingURL?.appendingPathComponent("alby").appendingPathExtension("json")
    }

    var companionInstalled: Bool? {
        guard let albyJsonURL = albyJsonURL else {
            return nil
        }
        return FileManager.default.fileExists(atPath: albyJsonURL.path)
    }

    var exists: Bool {
        guard let nativeMessagingURL = nativeMessagingURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: nativeMessagingURL.path)
    }

    func install() throws {
        guard let albyJsonURL = albyJsonURL else {
            return
        }
        try json?.write(to: albyJsonURL, atomically: true, encoding: .ascii)
    }

    func remove() throws {
        guard let albyJsonURL = albyJsonURL else {
            return
        }
        try FileManager.default.removeItem(at: albyJsonURL)
    }

    var application: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: id)
    }

    var icon: NSImage? {
        var icon: String {
            guard let chrome = chrome else {
                return "AppIcon" // Safari
            }
            return chrome ? "app" : "firefox"
        }
        if let url = application {
            if let image = Bundle(url: url)?.resourceURL?.appendingPathComponent(icon).appendingPathExtension("icns") {
                return NSImage(contentsOf: image)
            }
        }
        return nil
    }
}

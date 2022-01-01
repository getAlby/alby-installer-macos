//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import SwiftUI

@main
struct Window: App {
    private var alby = Alby()
    @State var localizedError: String?
    @State var loaded = false

    var body: some Scene {
        WindowGroup {
            Group {
                if loaded {
                    Button("Install JSON") {
                        do {
                            try alby.install()
                        } catch {
                            localizedError = error.localizedDescription
                        }
                    }
                } else {
                    Text("Seeking Browsers...")
                }
            }
            .alert(isPresented: .constant(localizedError?.isEmpty == false)) {
                Alert(title: Text(localizedError!))
            }
            .frame(width: 640, height: 480)
            .onAppear {
                loaded = alby.seek()
            }
        }
    }
}

struct Alby {
    private let fm = FileManager.default

    private let json = """
    {
    "name": "alby",
    "description": "Alby native messaging to connect to nodes behind Tor",
    "path": "./target/release/alby",
    "type": "stdio",
    "allowed_extensions": [ "extension@getalby.com" ]
    }
    """

    var nativeMessagingURL: URL {
        appSupportURL.appendingPathComponent("Mozilla/NativeMessagingHosts")
    }

    var albyJsonURL: URL {
        nativeMessagingURL.appendingPathComponent("alby").appendingPathExtension("json")
    }

    private var appSupportURL: URL {
        fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }

    func seek() -> Bool {
        fm.fileExists(atPath: nativeMessagingURL.path)
    }

    func install() throws {
        try json.write(to: albyJsonURL, atomically: true, encoding: .ascii)
    }
}

// TODO: List
// - Get the App Icons from the system or Bundle them (easier)?
// - Where do we copy the Extension itself? alby-1.1.0-fx.zip? Is is smart to build it, or should we rather download it (smarter) and put a copy then in the right folder.
//     --> I need the URL where I can download it. https://addons.mozilla.org/firefox/downloads/file/3887973/alby_bitcoin_lightning_wallet-1.2.1-fx.xpi ? Is this URL fixed?
// - List @

//
//private getDarwinNMHS() {
//    return {
//      Firefox: `${this.homedir()}/Library/Application\ Support/Mozilla/`,
//      Chrome: `${this.homedir()}/Library/Application\ Support/Google/Chrome/`,
//      "Chrome Beta": `${this.homedir()}/Library/Application\ Support/Google/Chrome\ Beta/`,
//      "Chrome Dev": `${this.homedir()}/Library/Application\ Support/Google/Chrome\ Dev/`,
//      "Chrome Canary": `${this.homedir()}/Library/Application\ Support/Google/Chrome\ Canary/`,
//      Chromium: `${this.homedir()}/Library/Application\ Support/Chromium/`,
//      "Microsoft Edge": `${this.homedir()}/Library/Application\ Support/Microsoft\ Edge/`,
//      "Microsoft Edge Beta": `${this.homedir()}/Library/Application\ Support/Microsoft\ Edge\ Beta/`,
//      "Microsoft Edge Dev": `${this.homedir()}/Library/Application\ Support/Microsoft\ Edge\ Dev/`,
//      "Microsoft Edge Canary": `${this.homedir()}/Library/Application\ Support/Microsoft\ Edge\ Canary/`,
//      Vivaldi: `${this.homedir()}/Library/Application\ Support/Vivaldi/`,
//    };
//  }

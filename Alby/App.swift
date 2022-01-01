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

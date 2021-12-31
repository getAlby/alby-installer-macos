//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021
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
                    Button("Install") {
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
            .frame(width: 800, height: 600)
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

    private var path: String {
        "/Users/\(NSUserName())/Library/Application Support/Mozilla/NativeMessagingHosts"
    }

    func seek() -> Bool {
        fm.fileExists(atPath: path)
    }

    func install() throws {
        try json.write(to: URL(fileURLWithPath: path).appendingPathComponent("alby").appendingPathExtension("json"), atomically: true, encoding: .ascii)
    }
}

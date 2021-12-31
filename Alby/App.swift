//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021
import SwiftUI

@main
struct Window: App {
    @State var loaded = false
    private var alby = Alby()

    var body: some Scene {
        WindowGroup {
            Group {
                if loaded {
                    Text("lo")
                } else {
                    Text("Seeking Browsers...")
                }
            }
            .frame(width: 800, height: 600)
            .onAppear {
                print("appear")
                loaded = alby.seek()
            }
        }
    }
}

struct Alby {
    private let fm = FileManager.default

    private var appSupport: URL {
        fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    }

    func seek() -> Bool {
        fm.fileExists(atPath: appSupport.appendingPathComponent("Mozilla").appendingPathComponent("NativeMessagingHosts").path)
    }
}

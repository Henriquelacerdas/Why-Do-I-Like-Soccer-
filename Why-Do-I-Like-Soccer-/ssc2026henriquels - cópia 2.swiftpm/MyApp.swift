import SwiftUI

@main
struct MyApp: App {
    @StateObject private var soundManager = SoundManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(soundManager)
                .onAppear {
                    soundManager.playBackgroundMusic(filename: "musicaFundo", type: "m4a")
                }
        }
    }
}

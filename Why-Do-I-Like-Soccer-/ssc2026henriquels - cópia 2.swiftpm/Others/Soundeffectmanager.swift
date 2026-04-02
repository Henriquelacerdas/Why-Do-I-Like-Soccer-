import AVFoundation

// Manages short sound effects for SpriteKit scenes
// Preloads sounds once and reuses players
final class SoundEffectManager {
    
    nonisolated(unsafe) static let shared = SoundEffectManager()
    
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        preload("kick")
        preload("goal")
        preload("goalWhite")
    }
    
    private func preload(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3")
                ?? Bundle.main.url(forResource: name, withExtension: "wav")
                ?? Bundle.main.url(forResource: name, withExtension: "m4a") else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
        } catch {}
    }
    
    func play(_ name: String, volume: Float = 0.5) {
        guard let player = players[name] else { return }
        player.volume = volume
        player.currentTime = 0
        player.play()
    }
    
    func stop(_ name: String) {
        players[name]?.stop()
    }
    
    func stopAll() {
        for player in players.values {
            player.stop()
        }
    }
}

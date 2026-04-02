
import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    var player: AVAudioPlayer?

    func playBackgroundMusic(filename: String, type: String) {
        print("Tentando buscar o arquivo: \(filename).\(type)")
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: type) else {
            print("Arquivo \(filename).\(type) não encontrado no Bundle")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            
            player?.numberOfLoops = -1
            player?.volume = 0.3
            player?.prepareToPlay()
            
            player?.play()
            
        } catch let error {
            print("Erro: \(error.localizedDescription)")
        }
    }

    func stopMusic() {
        player?.stop()
    }
}

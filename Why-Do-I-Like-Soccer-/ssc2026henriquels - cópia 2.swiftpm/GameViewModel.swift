import SwiftUI

final class GameViewModel: ObservableObject {
    
    @Published var playerPositions: [UUID: CGPoint] = [:]
    @Published var showInstructionCard = true
    @Published var showHelpOverlay = false
    @Published var showConfirmation = false
    @Published var navigateToAnalysis = false
    @Published var textIsSkipped = false
    @Published var showButton = false
    
    func updatePlayerPosition(id: UUID, newPosition: CGPoint) {
        playerPositions[id] = newPosition
    }
    
    func dismissInstructionCard() {
        withAnimation(.easeOut(duration: 0.3)) {
            showInstructionCard = false
        }
    }
    
    func confirmFormation() {
        navigateToAnalysis = true
    }
}

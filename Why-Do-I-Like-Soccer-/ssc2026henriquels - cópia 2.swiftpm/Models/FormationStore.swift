import CoreGraphics

enum FormationStore {
    nonisolated(unsafe) static var attackerPositions: [CGPoint] = []
    
    static var allRedPositions: [CGPoint] {
        attackerPositions + [FieldLayout.redGoalkeeperNorm]
    }
}

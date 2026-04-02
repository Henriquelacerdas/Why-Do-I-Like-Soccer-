import SpriteKit

/// Builds sequential ball pass chains from a starting position through a series of players
struct PassChainBuilder {
    
    struct ChainResult {
        let actions: [SKAction]
        let finalBallPosition: CGPoint
        
        let interceptTarget: CGPoint?
        
        let positionBeforeLastPass: CGPoint?
        
        let lastPlayerPixel: CGPoint?
    }
    
    let layout: FieldLayout
    let playerPositions: [CGPoint]
    
    var passSpeed: CGFloat = 0.5

    var passPause: TimeInterval = 0.15
    
    var stopAtHalfway: Bool = false
    
    var kickSoundAction: SKAction? = nil
    
    
    // Builds a chain of passes starting from the given position
    func buildChain(from startPosition: CGPoint) -> ChainResult {
        var actions: [SKAction] = []
        var currentPos = startPosition
        var previousPos: CGPoint? = nil
        var lastPlayerPixel: CGPoint? = nil
        let goalkeeperPixelX = layout.minX + (layout.playWidth * FieldLayout.goalkeeperX)
        let halfwayPixelX = layout.minX + (layout.playWidth * 0.5)
        
        while true {
            let candidates = playerPositions.filter { pos in
                let pixelPos = layout.normToPixel(pos)
                return pixelPos.x > currentPos.x + 1.0
                    && abs(pixelPos.x - goalkeeperPixelX) > 10.0
            }
            
            guard let nearest = findNearest(to: currentPos, among: candidates) else { break }
            let nearestPixel = layout.normToPixel(nearest)
            
            // Check if this player is past halfway (for interception/counter-attack)
            if stopAtHalfway && nearestPixel.x > halfwayPixelX {
                return ChainResult(
                    actions: actions,
                    finalBallPosition: currentPos,
                    interceptTarget: nearestPixel,
                    positionBeforeLastPass: previousPos,
                    lastPlayerPixel: nearestPixel
                )
            }
            
            let targetPos = CGPoint(
                x: nearestPixel.x + layout.ballOffset,
                y: nearestPixel.y
            )
            
            let passAction = BallActionFactory.pass(
                from: currentPos,
                to: targetPos,
                speed: passSpeed,
                playWidth: layout.playWidth
            )
            
            if let soundAction = kickSoundAction {
                actions.append(soundAction)
            }
            actions.append(passAction)
            actions.append(SKAction.wait(forDuration: passPause))
            previousPos = currentPos
            lastPlayerPixel = nearestPixel
            currentPos = targetPos
        }
        
        return ChainResult(
            actions: actions,
            finalBallPosition: currentPos,
            interceptTarget: nil,
            positionBeforeLastPass: previousPos,
            lastPlayerPixel: lastPlayerPixel
        )
    }
    
    private func findNearest(to position: CGPoint, among candidates: [CGPoint]) -> CGPoint? {
        candidates.min { a, b in
            layout.normToPixel(a).distance(to: position) < layout.normToPixel(b).distance(to: position)
        }
    }
}

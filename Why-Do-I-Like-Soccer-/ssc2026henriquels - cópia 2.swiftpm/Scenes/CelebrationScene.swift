import SpriteKit

// Demonstrates the ideal flank attack pattern with three phases:
// 1. Flank run + attacker repositioning
// 2. Cross to attacker
// 3. Shot on goal and loop
class CelebrationScene: BaseSoccerScene {
    
    // Animated Nodes (recreated each loop)
    
    private var flankNode: SKShapeNode?
    private var attackerNode: SKShapeNode?
    private var animatedBallNode: SKSpriteNode?
    
    // Cached Data
    
    private var flankPlayerNorm: CGPoint?
    private var attackerNorm: CGPoint?
    private var allRedPositions: [CGPoint] = []
    
    // Setup
    
    override func sceneDidSetup() {
        drawDefenders()
        prepareAttackerData()
        drawStaticAttackers()
        runAnimationLoop()
    }
    
    // Attacker Data
    
    private func prepareAttackerData() {
        allRedPositions = FormationStore.allRedPositions
        
        // Left flank player: highest x in the left flank zone
        let flankCandidates = allRedPositions.filter {
            $0.x > 0.5 && $0.x < 0.8 && $0.y > 0.8
        }
        flankPlayerNorm = flankCandidates.max(by: { $0.x < $1.x })
        
        // Attacker: highest x among remaining (excluding flank + goalkeeper)
        let remaining = allRedPositions.filter { pos in
            if let fp = flankPlayerNorm, pos.isClose(to: fp) { return false }
            if pos.isClose(to: FieldLayout.redGoalkeeperNorm) { return false }
            return true
        }
        attackerNorm = remaining.max(by: { $0.x < $1.x })
    }
    
    private func drawStaticAttackers() {
        for normPos in allRedPositions {
            let isAnimated = (flankPlayerNorm != nil && normPos.isClose(to: flankPlayerNorm!))
                || (attackerNorm != nil && normPos.isClose(to: attackerNorm!))
            
            if !isAnimated {
                createPlayerNode(color: .red, normPos: normPos, zPosition: 20)
            }
        }
    }
    
    // Animation Loop
    
    private func runAnimationLoop() {
        // Remove previous animated nodes
        flankNode?.removeFromParent()
        attackerNode?.removeFromParent()
        animatedBallNode?.removeFromParent()
        
        guard let attackerOrigNorm = attackerNorm else {
            // No valid players for animation — draw them static
            if let fp = flankPlayerNorm { createPlayerNode(color: .red, normPos: fp, zPosition: 20) }
            if let ap = attackerNorm { createPlayerNode(color: .red, normPos: ap, zPosition: 20) }
            return
        }
        
        // Positions
        let flankStartNorm = CGPoint(x: 0.5, y: 0.85)
        let flankEndNorm = CGPoint(x: 0.8, y: 0.8)
        let attackerEndNorm = CGPoint(x: 0.8, y: 0.5)
        
        // Create animated nodes
        let newFlank = createPlayerNode(color: .red, normPos: flankStartNorm, zPosition: 20)
        flankNode = newFlank
        
        let newAttacker = createPlayerNode(color: .red, normPos: attackerOrigNorm, zPosition: 20)
        attackerNode = newAttacker
        
        let newBall = createBallSprite(near: flankStartNorm, offsetX: layout.ballOffset)
        animatedBallNode = newBall
        
        // Pixel targets
        let flankEndPixel = layout.normToPixel(flankEndNorm)
        let attackerEndPixel = layout.normToPixel(attackerEndNorm)
        

        let runDuration: TimeInterval = 1.5
        
        newFlank.run(easeMove(to: flankEndPixel, duration: runDuration))
        newAttacker.run(easeMove(to: attackerEndPixel, duration: runDuration))
        
        let ballRunTarget = CGPoint(x: flankEndPixel.x + layout.ballOffset, y: flankEndPixel.y)
        let ballPhase1 = BallActionFactory.moveBall(
            to: ballRunTarget, duration: runDuration, rotations: 2, timingMode: .easeInEaseOut
        )
        
        newBall.run(ballPhase1) { [weak self] in
            self?.runPhase2Cross(ball: newBall, attackerPixel: attackerEndPixel)
        }
    }
    

    private func runPhase2Cross(ball: SKSpriteNode, attackerPixel: CGPoint) {
        let passTarget = CGPoint(x: attackerPixel.x + layout.ballOffset, y: attackerPixel.y)
        let crossMove = BallActionFactory.moveBall(
            to: passTarget, duration: 0.6, rotations: 1, timingMode: .easeOut
        )
        let crossAction = crossMove
        
        ball.run(crossAction) { [weak self] in
            self?.runPhase3Shot(ball: ball)
        }
    }
    

    private func runPhase3Shot(ball: SKSpriteNode) {
        let gkCoord = DefenseFormation.allPlayers.max(by: { $0.x < $1.x }) ?? DefenseFormation.goalkeeper
        let goalNorm = CGPoint(x: gkCoord.x + 0.018, y: gkCoord.y + 0.08)
        let goalPixel = layout.normToPixel(goalNorm)
        
        let shotMove = BallActionFactory.moveBall(
            to: goalPixel, duration: 0.5, rotations: 1.5, timingMode: .easeIn
        )
        let shotAction = shotMove
        
        ball.run(shotAction) { [weak self] in
            self?.run(.wait(forDuration: 1.0)) { self?.runAnimationLoop() }
        }
    }
    
    // Helpers
    
    private func createBallSprite(near normPos: CGPoint, offsetX: CGFloat) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.size = layout.ballSize
        ball.zPosition = 25
        let pixel = layout.normToPixel(normPos)
        ball.position = CGPoint(x: pixel.x + offsetX, y: pixel.y)
        addChild(ball)
        return ball
    }
    
    private func easeMove(to point: CGPoint, duration: TimeInterval) -> SKAction {
        let action = SKAction.move(to: point, duration: duration)
        action.timingMode = .easeInEaseOut
        return action
    }
}

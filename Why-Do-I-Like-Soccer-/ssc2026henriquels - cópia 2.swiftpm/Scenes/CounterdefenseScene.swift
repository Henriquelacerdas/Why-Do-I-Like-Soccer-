import SpriteKit

class CounterDefenseScene: BaseSoccerScene {
    
    private var forwardNodes: [SKShapeNode] = []
    private var animatedBallNode: SKSpriteNode?
    private var interceptorRedNode: SKShapeNode?
    
    private var forwardNorms: [CGPoint] = []
    private var interceptorOriginalPosition: CGPoint?
    private var isAnimating = false
    private var hasIntercepted = false
    
    override func sceneDidSetup() {
        prepareForwardData()
        drawStaticDefenders()
        drawAttackers()
        runAnimationLoop()
    }
    
    private func prepareForwardData() {
        forwardNorms = DefenseFormation.forwards.sorted { $0.x < $1.x }
    }
    
    private func drawStaticDefenders() {
        // Draw everyone except the animated forwards
        let staticPlayers = DefenseFormation.defenders + DefenseFormation.midfielders + [DefenseFormation.goalkeeper]
        for coord in staticPlayers {
            createPlayerNode(color: .white, normPos: coord, zPosition: 10)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isAnimating, !hasIntercepted,
              let carrier = forwardNodes.first,
              let ball = animatedBallNode else { return }
        
        // Keeps ball attached to carrier's front
        ball.position = CGPoint(
            x: carrier.position.x - layout.ballOffset,
            y: carrier.position.y
        )
    }
    
    private func runAnimationLoop() {
        cleanupAnimatedNodes()
        isAnimating = true
        hasIntercepted = false
        
        forwardNodes = forwardNorms.map { norm in
            createPlayerNode(color: .white, normPos: norm, zPosition: 30)
        }
        
        let carrierNorm = forwardNorms[0]
        
        let carrierPixel = layout.normToPixel(carrierNorm)
        let newBall = SKSpriteNode(imageNamed: "ball")
        newBall.size = layout.ballSize
        newBall.zPosition = 35
        newBall.position = CGPoint(x: carrierPixel.x - layout.ballOffset, y: carrierPixel.y)
        addChild(newBall)
        animatedBallNode = newBall
        
        let moveOffset: CGFloat = 0.2
        let moveDuration: TimeInterval = 2.0
        
        for (i, node) in forwardNodes.enumerated() {
            let targetNorm = CGPoint(x: forwardNorms[i].x - moveOffset, y: forwardNorms[i].y)
            let move = SKAction.move(to: layout.normToPixel(targetNorm), duration: moveDuration)
            move.timingMode = .easeInEaseOut
            node.run(move, withKey: "forwardRun")
        }
        
        guard let redNode = findLowestXRedNode() else {
            scheduleLoop(afterDelay: moveDuration + 1.5)
            return
        }
        
        interceptorRedNode = redNode
        interceptorOriginalPosition = redNode.position
        
        let carrierTargetNorm = CGPoint(x: carrierNorm.x - moveOffset, y: carrierNorm.y)
        let carrierTargetPixel = layout.normToPixel(carrierTargetNorm)
        
        // Intercept at 70% of the carrier's path
        let interceptTarget = CGPoint(
            x: carrierPixel.x + (carrierTargetPixel.x - carrierPixel.x) * 0.7,
            y: carrierPixel.y + (carrierTargetPixel.y - carrierPixel.y) * 0.7
        )
        
        let chaseDist = redNode.position.distance(to: interceptTarget)
        let chaseDuration = TimeInterval(chaseDist / (layout.playWidth * 0.35))
        
        let chaseMove = SKAction.move(to: interceptTarget, duration: chaseDuration)
        chaseMove.timingMode = .easeIn
        redNode.run(chaseMove, withKey: "redChase")
        
        let checkInterval: TimeInterval = 0.05
        let proximityThreshold = layout.playerRadius * 2
        
        let checkAction = SKAction.sequence([
            .wait(forDuration: checkInterval),
            .run { [weak self] in
                guard let self = self, !self.hasIntercepted,
                      let ball = self.animatedBallNode else { return }
                
                // Triggers interception on contact
                if redNode.position.distance(to: ball.position) < proximityThreshold {
                    self.performInterception(ballNode: ball)
                }
            }
        ])
        run(.repeatForever(checkAction), withKey: "proximityCheck")
    }
    
    private func performInterception(ballNode: SKSpriteNode) {
        hasIntercepted = true
        isAnimating = false
        removeAction(forKey: "proximityCheck")
        
        for node in forwardNodes { node.removeAction(forKey: "forwardRun") }
        interceptorRedNode?.removeAction(forKey: "redChase")
        
        let ballPos = ballNode.position
        let isAboveCenter = ballPos.y > (layout.minY + layout.playHeight / 2)
        
        // Clears ball to the nearest sideline
        let clearanceY = isAboveCenter
            ? (layout.minY + layout.playHeight + 40)
            : (layout.minY - 40)
        
        let kickAction = BallActionFactory.clearance(
            to: CGPoint(x: ballPos.x, y: clearanceY)
        )
        
        ballNode.run(kickAction) { [weak self] in
            self?.scheduleLoop(afterDelay: 1.5)
        }
    }
    
    private func scheduleLoop(afterDelay delay: TimeInterval) {
        run(.wait(forDuration: delay)) { [weak self] in
            self?.runAnimationLoop()
        }
    }
    
    private func cleanupAnimatedNodes() {
        removeAction(forKey: "proximityCheck")
        
        for node in forwardNodes { node.removeFromParent() }
        forwardNodes = []
        
        animatedBallNode?.removeFromParent()
        animatedBallNode = nil
        
        if let redNode = interceptorRedNode, let origPos = interceptorOriginalPosition {
            redNode.removeAllActions()
            redNode.position = origPos
        }
        interceptorRedNode = nil
        interceptorOriginalPosition = nil
    }
    
    private func findLowestXRedNode() -> SKShapeNode? {
        let gkPixel = layout.normToPixel(FieldLayout.redGoalkeeperNorm)
        
        // Find the red player closest to the white's goal (excluding GK)
        return children
            .compactMap { $0 as? SKShapeNode }
            .filter { $0.fillColor == .red && $0.position.distance(to: gkPixel) > 10 }
            .min { $0.position.x < $1.position.x }
    }
}

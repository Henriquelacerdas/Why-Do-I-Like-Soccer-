import SpriteKit

// Looping animation showing 3 white forwards advancing forward
class CounterAttackFeedbackScene: BaseSoccerScene {
    
    private var forwardNodes: [SKShapeNode] = []
    private var animatedBallNode: SKSpriteNode?
    
    private var forwardNorms: [CGPoint] = []
    private var isAnimating = false
    
    
    override func sceneDidSetup() {
        prepareForwardData()
        drawStaticDefenders()
        drawAttackers()
        runAnimationLoop()
    }
    
    private func prepareForwardData() {
        forwardNorms = DefenseFormation.forwards.sorted { $0.x < $1.x }
    }
    
    // Draws only defenders, midfielders, and goalkeeper, not the forwards (animated)
    private func drawStaticDefenders() {
        let staticPlayers = DefenseFormation.defenders + DefenseFormation.midfielders + [DefenseFormation.goalkeeper]
        for coord in staticPlayers {
            createPlayerNode(color: .white, normPos: coord, zPosition: 10)
        }
    }
    
    // Frame Update
    
    override func update(_ currentTime: TimeInterval) {
        guard isAnimating,
              forwardNodes.count >= 3,
              let ball = animatedBallNode else { return }
        
        let carrier = forwardNodes[1]
        ball.position = CGPoint(
            x: carrier.position.x - layout.ballOffset,
            y: carrier.position.y
        )
    }
    
    private func runAnimationLoop() {
        cleanupAnimatedNodes()
        isAnimating = true
        
        // Create forward nodes at original positions
        forwardNodes = forwardNorms.map { norm in
            createPlayerNode(color: .white, normPos: norm, zPosition: 30)
        }
        
        guard forwardNodes.count >= 3 else { return }
        
        //let middleCarrier = forwardNodes[1]
        let middleNorm = forwardNorms[1]
        
        // Create ball at middle carrier
        let carrierPixel = layout.normToPixel(middleNorm)
        let newBall = SKSpriteNode(imageNamed: "ball")
        newBall.size = layout.ballSize
        newBall.zPosition = 35
        newBall.position = CGPoint(x: carrierPixel.x - layout.ballOffset, y: carrierPixel.y)
        addChild(newBall)
        animatedBallNode = newBall
        
        // All 3 forwards advance left by 0.25
        let moveOffset: CGFloat = 0.25
        let moveDuration: TimeInterval = 2.0
        
        for (i, node) in forwardNodes.enumerated() {
            let targetNorm = CGPoint(x: forwardNorms[i].x - moveOffset, y: forwardNorms[i].y)
            let move = SKAction.move(to: layout.normToPixel(targetNorm), duration: moveDuration)
            move.timingMode = .easeInEaseOut
            node.run(move, withKey: "forwardRun")
        }
        
        // After movement completes, wait and restart
        run(.wait(forDuration: moveDuration + 1.5)) { [weak self] in
            self?.runAnimationLoop()
        }
    }
    
    private func cleanupAnimatedNodes() {
        isAnimating = false
        
        for node in forwardNodes { node.removeFromParent() }
        forwardNodes = []
        
        animatedBallNode?.removeFromParent()
        animatedBallNode = nil
    }
}

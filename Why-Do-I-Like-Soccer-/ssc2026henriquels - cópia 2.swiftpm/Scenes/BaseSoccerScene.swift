import SpriteKit

// Field rendering, player drawing, and coordinates conversion
class BaseSoccerScene: SKScene {
    
    
    private(set) var layout: FieldLayout!
        
    private(set) var whitePlayerNodes: [SKShapeNode] = []
    private(set) var redGoalkeeperNode: SKShapeNode?
    var redPlayerPixelPositions: [CGPoint] = []
    
    
    override func didMove(to view: SKView) {
        backgroundColor = .systemBackground
        layout = FieldLayout(viewSize: size)
        drawField()
        sceneDidSetup()
    }
    
    override func willMove(from view: SKView) {
        removeAllActions()
        removeAllChildren()
        SoundEffectManager.shared.stopAll()
    }
    
    func sceneDidSetup() {
    }
    
    
    func playKickSound() {
        SoundEffectManager.shared.play("kick", volume: 0.5)
    }
    
    func kickSoundAction() -> SKAction {
        SKAction.run { [weak self] in self?.playKickSound() }
    }
   
    func drawField() {
        let bgTexture = SKTexture(imageNamed: "SoccerField")
        let background = SKSpriteNode(texture: bgTexture)
        background.zPosition = 0
        background.size = layout.fieldSize
        background.position = layout.fieldCenter
        addChild(background)
    }
    
    func drawDefenders() {
        whitePlayerNodes = DefenseFormation.allPlayers.map { coord in
            createPlayerNode(color: .white, normPos: coord, zPosition: 10)
        }
    }
    
    func drawAttackers() {
        let positions = FormationStore.allRedPositions
        redPlayerPixelPositions = []
        
        for normPos in positions {
            let node = createPlayerNode(color: .red, normPos: normPos, zPosition: 20)
            let pixelPos = layout.normToPixel(normPos)
            redPlayerPixelPositions.append(pixelPos)
            
            if normPos.isClose(to: FieldLayout.redGoalkeeperNorm) {
                redGoalkeeperNode = node
            }
        }
    }
    
    @discardableResult
    func createPlayerNode(color: UIColor, normPos: CGPoint, zPosition: CGFloat) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: layout.playerRadius)
        node.fillColor = color
        node.strokeColor = .black
        node.lineWidth = 3
        node.zPosition = zPosition
        node.position = layout.normToPixel(normPos)
        addChild(node)
        return node
    }
    
    func createBallAtGoalkeeper() -> (ball: SKSpriteNode, position: CGPoint) {
        let ballNode = SKSpriteNode(imageNamed: "ball")
        ballNode.size = layout.ballSize
        ballNode.zPosition = 25
        
        let startNorm = CGPoint(
            x: FieldLayout.goalkeeperX + FieldLayout.playerRadiusRatio,
            y: 0.5
        )
        let startPos = layout.normToPixel(startNorm)
        ballNode.position = startPos
        addChild(ballNode)
        
        return (ballNode, startPos)
    }
    
    // Goal Animation
    func showGoalAnimation(assetName: String = "goal", completion: (() -> Void)? = nil) {
        // Play goal sound
        let soundName = assetName == "goal" ? "goal" : "goalWhite"
        SoundEffectManager.shared.play(soundName, volume: 0.6)
        run(.wait(forDuration: 2.0)) {
            SoundEffectManager.shared.stop(soundName)
        }
        
        // Dark overlay
        let overlay = SKSpriteNode(color: .black, size: CGSize(width: size.width * 2, height: size.height * 2))
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        overlay.alpha = 0
        addChild(overlay)
        overlay.run(.fadeAlpha(to: 0.7, duration: 0.3))
        
        // Goal banner
        let goalNode = SKSpriteNode(imageNamed: assetName)
        goalNode.size = CGSize(width: size.width * 0.9, height: size.height * 0.7)
        goalNode.position = CGPoint(x: -size.width / 2, y: size.height / 2)
        goalNode.zPosition = 101
        addChild(goalNode)
        
        let slideIn = SKAction.move(to: layout.fieldCenter, duration: 0.4)
        slideIn.timingMode = .easeOut
        let wait = SKAction.wait(forDuration: 1.5)
        let slideOut = SKAction.move(
            to: CGPoint(x: size.width * 1.5, y: size.height / 2),
            duration: 0.4
        )
        slideOut.timingMode = .easeIn
        
        goalNode.run(.sequence([slideIn, wait, slideOut])) {
            DispatchQueue.main.async { completion?() }
        }
    }
}


extension CGPoint {
    // Checks approximate equality for normalized coordinates.
    func isClose(to other: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
        abs(x - other.x) < tolerance && abs(y - other.y) < tolerance
    }
}

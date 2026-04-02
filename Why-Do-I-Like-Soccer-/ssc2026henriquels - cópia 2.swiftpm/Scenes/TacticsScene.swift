import SpriteKit

// Interactive scene where the user positions their attacking players
class TacticsScene: SKScene {
    
    var onPositionChanged: ((UUID, CGPoint) -> Void)?
    var onSceneTapped: (() -> Void)?
    var onFirstPlayerMoved: (() -> Void)?
    
    private let fieldLayout: FieldLayout.Type = FieldLayout.self
    private var playableRect: CGRect?
    private var playerRadius: CGFloat = 0
    
    // Touch State
    private var selectedNode: SKNode?
    private var activeTapNode: SKNode?
    private var touchStartLocation: CGPoint?
    private var isDragging = false
    private var hasNotifiedFirstMove = false
    private let dragThreshold: CGFloat = 10.0
    
    // Lifecycle
    
    override func didMove(to view: SKView) {
        setupField()
        setupDefensePlayers()
        setupAttackPlayers()
        createBallAtGoalkeeper()
        saveNormalizedPositions()
    }
    
    // Field Setup
    
    private func setupField() {
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "SoccerField"))
        background.name = "field"
        background.zPosition = 0
        
        let viewWidth = size.width
        let viewHeight = size.height
        let targetHeight = viewHeight * FieldLayout.fieldScaleFactor
        let targetWidth = targetHeight * FieldLayout.aspectRatio
        
        background.size = CGSize(width: targetWidth, height: targetHeight)
        background.position = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        addChild(background)
        
        let margin = targetHeight * FieldLayout.marginRatio
        let minX = background.position.x - (targetWidth / 2) + margin
        let maxX = background.position.x + (targetWidth / 2) - margin
        let minY = background.position.y - (targetHeight / 2) + margin
        let maxY = background.position.y + (targetHeight / 2) - margin
        
        playableRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        playerRadius = (maxY - minY) * FieldLayout.playerRadiusRatio
    }
    
    private var fieldConstraint: SKConstraint? {
        guard let rect = playableRect else { return nil }
        return SKConstraint.positionX(
            SKRange(lowerLimit: rect.minX, upperLimit: rect.maxX),
            y: SKRange(lowerLimit: rect.minY, upperLimit: rect.maxY)
        )
    }
    
    // Player Setup
    
    private func setupDefensePlayers() {
        guard let rect = playableRect else { return }
        
        for coord in DefenseFormation.allPlayers {
            let node = SKShapeNode(circleOfRadius: playerRadius)
            node.fillColor = .white
            node.strokeColor = .black
            node.lineWidth = 3
            node.zPosition = 10
            node.name = "defense_player_fixed"
            node.position = CGPoint(
                x: rect.minX + rect.width * coord.x,
                y: rect.minY + rect.height * coord.y
            )
            addChild(node)
        }
    }
    
    private func setupAttackPlayers() {
        guard let rect = playableRect, let constraint = fieldConstraint else { return }
        
        // 10 movable red players
        for _ in 0..<10 {
            let node = SKShapeNode(circleOfRadius: playerRadius)
            node.fillColor = .red
            node.strokeColor = .black
            node.lineWidth = 3
            node.zPosition = 20
            node.name = UUID().uuidString
            node.position = findRandomValidPosition(in: rect)
            node.constraints = [constraint]
            addChild(node)
        }
        
        // Fixed red goalkeeper
        let goalkeeper = SKShapeNode(circleOfRadius: playerRadius)
        goalkeeper.fillColor = .red
        goalkeeper.strokeColor = .black
        goalkeeper.lineWidth = 3
        goalkeeper.zPosition = 20
        goalkeeper.name = "goalkeeperAtack"
        goalkeeper.position = CGPoint(x: rect.minX + playerRadius * 2, y: rect.midY)
        addChild(goalkeeper)
    }
    
    private func createBallAtGoalkeeper() {
        guard let rect = playableRect else { return }
        let ballX = rect.minX + rect.width * 0.055
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = "ballNode"
        let side = rect.height * FieldLayout.ballSizeRatio
        ball.size = CGSize(width: side, height: side)
        ball.position = CGPoint(x: ballX, y: size.height / 2)
        ball.zPosition = 25
        addChild(ball)
    }
    
    // Position Persistence
    
    private func saveNormalizedPositions() {
        guard let rect = playableRect else { return }
        
        let positions: [CGPoint] = children.compactMap { node in
            guard let name = node.name, UUID(uuidString: name) != nil else { return nil }
            return CGPoint(
                x: (node.position.x - rect.minX) / rect.width,
                y: (node.position.y - rect.minY) / rect.height
            )
        }
        
        FormationStore.attackerPositions = positions
    }
    
    // Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onSceneTapped?()
        guard let location = touches.first?.location(in: self) else { return }
        
        touchStartLocation = location
        isDragging = false
        
        // Check for non-movable players first (white defenders + red goalkeeper)
        if let node = nonMovableNode(at: location) {
            let message = node.name == "goalkeeperAtack"
                ? "Goalkeeper is not part\nof the tactical formation"
                : "You can't move the\nopposing team"
            showTemporaryAlert(message, at: node.position)
            shakeNode(node)
            return
        }
        
        guard let node = interactableNode(at: location) else { return }
        
        selectedNode = node
        if node != activeTapNode {
            node.run(.scale(to: 1.2, duration: 0.1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self),
              let node = selectedNode else { return }
        
        if let start = touchStartLocation, start.distance(to: location) > dragThreshold {
            isDragging = true
        }
        
        guard isDragging else { return }
        
        if let active = activeTapNode { deselectTapNode(active) }
        
        node.position = resolveCollisions(for: node, target: location)
        
        if let name = node.name, let uuid = UUID(uuidString: name) {
            onPositionChanged?(uuid, node.position)
            notifyFirstMove()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if isDragging {
            handleDragEnd()
        } else {
            handleTapEnd(at: location)
        }
    }
    
    // Drag Handling
    
    private func handleDragEnd() {
        selectedNode?.run(.scale(to: 1.0, duration: 0.1))
        selectedNode = nil
        saveNormalizedPositions()
    }
    
    // Tap Handling
    
    private func handleTapEnd(at location: CGPoint) {
        if let node = interactableNode(at: location) {
            selectedNode?.run(.scale(to: 1.0, duration: 0.1))
            selectedNode = nil
            
            guard node.name != "goalkeeperAtack",
                  node.name != "ballNode",
                  node.name != "defense_player_fixed" else { return }
            
            if node == activeTapNode {
                deselectTapNode(node)
            } else {
                if let old = activeTapNode { deselectTapNode(old) }
                selectTapNode(node)
            }
        } else {
            handleTapOnField(at: location)
        }
    }
    
    private func handleTapOnField(at location: CGPoint) {
        if let movingNode = activeTapNode {
            let target = resolveCollisions(for: movingNode, target: location)
            movingNode.run(.move(to: target, duration: 0.15)) { [weak self] in
                guard let self = self else { return }
                if let name = movingNode.name, let uuid = UUID(uuidString: name) {
                    self.onPositionChanged?(uuid, movingNode.position)
                }
                self.saveNormalizedPositions()
                self.notifyFirstMove()
            }
            deselectTapNode(movingNode)
        }
        
        selectedNode?.run(.scale(to: 1.0, duration: 0.1))
        selectedNode = nil
    }
    
    // Selection Visual Feedback
    
    private func selectTapNode(_ node: SKNode) {
        activeTapNode = node
        node.run(.scale(to: 1.2, duration: 0.1))
    }
    
    private func deselectTapNode(_ node: SKNode) {
        node.run(.scale(to: 1.0, duration: 0.1))
        activeTapNode = nil
    }
    
    // Collision Resolution
    
    private func resolveCollisions(for movingNode: SKNode, target: CGPoint) -> CGPoint {
        var position = target
        let minDistance = playerRadius * 2
        
        for other in children where other != movingNode && other.name != "field" {
            guard isPlayerNode(other) else { continue }
            
            if position.distance(to: other.position) < minDistance {
                let angle = atan2(
                    position.x - other.position.x,
                    position.y - other.position.y
                )
                position = CGPoint(
                    x: other.position.x + sin(angle) * minDistance,
                    y: other.position.y + cos(angle) * minDistance
                )
            }
        }
        return position
    }
    
    // Returns a non-movable player node at the location (white defenders or red goalkeeper)
    private func nonMovableNode(at location: CGPoint) -> SKNode? {
        let touched = nodes(at: location)
        return touched.first { node in
            node.name == "defense_player_fixed" || node.name == "goalkeeperAtack"
        }
    }
    
    // Returns a movable red attacker node at the location
    private func interactableNode(at location: CGPoint) -> SKNode? {
        let touched = nodes(at: location)
        return touched.first { node in
            node.name != "field" && node.name != "ballNode"
                && node.name != "defense_player_fixed"
                && node.name != "goalkeeperAtack"
        }
    }
    
    private func isPlayerNode(_ node: SKNode) -> Bool {
        guard let name = node.name else { return false }
        return name.contains("player") || name.contains("goalkeeper") || UUID(uuidString: name) != nil
    }
    
    private func findRandomValidPosition(in rect: CGRect) -> CGPoint {
        while true {
            let pos = CGPoint(
                x: .random(in: rect.minX...rect.maxX),
                y: .random(in: rect.minY...rect.maxY)
            )
            let conflict = children.contains { $0.name != "field" && $0.position.distance(to: pos) < playerRadius * 2 }
            if !conflict { return pos }
        }
    }
    
    private func notifyFirstMove() {
        guard !hasNotifiedFirstMove else { return }
        hasNotifiedFirstMove = true
        DispatchQueue.main.async { self.onFirstPlayerMoved?() }
    }
    
    // Visual Feedback
    
    private func shakeNode(_ node: SKNode) {
        let shake = SKAction.sequence([
            .moveBy(x: 5, y: 0, duration: 0.05),
            .moveBy(x: -5, y: 0, duration: 0.05),
            .moveBy(x: 5, y: 0, duration: 0.05),
            .moveBy(x: -5, y: 0, duration: 0.05)
        ])
        node.run(shake)
    }
    
    private func showTemporaryAlert(_ message: String, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "SFProDisplay-Bold")
        label.numberOfLines = 0
        label.horizontalAlignmentMode = .center
        label.text = message
        label.fontSize = 20
        label.fontColor = .red
        label.zPosition = 100
        label.position = CGPoint(x: position.x, y: position.y + 40)
        label.alpha = 0
        addChild(label)
        
        label.run(.sequence([
            .fadeIn(withDuration: 0.2),
            .wait(forDuration: 1.5),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
    }
}

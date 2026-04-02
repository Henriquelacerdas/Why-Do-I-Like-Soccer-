import SpriteKit

// highlighting the unoccupied flank zones.
class FlanksFeedbackScene: BaseSoccerScene {
    
    override func sceneDidSetup() {
        drawDefenders()
        drawAttackers()
        drawPulsingFlankZones()
    }
    
    // Pulsing Flank Zones
    
    private func drawPulsingFlankZones() {
        let topZone = createZoneRect(
            normOrigin: CGPoint(x: 0.5, y: 0.8),
            normSize: CGSize(width: 0.3, height: 0.2)
        )
        addChild(topZone)
        applyPulse(to: topZone)
        
        let bottomZone = createZoneRect(
            normOrigin: CGPoint(x: 0.5, y: 0.0),
            normSize: CGSize(width: 0.3, height: 0.2)
        )
        addChild(bottomZone)
        applyPulse(to: bottomZone)
    }
    
    private func createZoneRect(normOrigin: CGPoint, normSize: CGSize) -> SKShapeNode {
        let origin = layout.normToPixel(normOrigin)
        let pixelWidth = layout.playWidth * normSize.width
        let pixelHeight = layout.playHeight * normSize.height
        
        let rect = CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight)
        let node = SKShapeNode(rect: rect, cornerRadius: 8)
        node.fillColor = UIColor.systemYellow.withAlphaComponent(0.3)
        node.strokeColor = .systemYellow
        node.lineWidth = 3
        node.zPosition = 30
        node.position = origin
        return node
    }
    
    private func applyPulse(to node: SKNode) {
        let pulse = SKAction.sequence([
            .fadeAlpha(to: 0.2, duration: 0.8),
            .fadeAlpha(to: 1.0, duration: 0.8)
        ])
        node.run(.repeatForever(pulse))
    }
}

import SpriteKit

// Factory for creating reusable ball animation actions.
enum BallActionFactory {
    
    // Creates a combined move + rotate action for ball movement.
    static func moveBall(
        to target: CGPoint,
        duration: TimeInterval,
        rotations: CGFloat = 1,
        timingMode: SKActionTimingMode = .linear
    ) -> SKAction {
        let move = SKAction.move(to: target, duration: duration)
        move.timingMode = timingMode
        let rotate = SKAction.rotate(byAngle: -CGFloat.pi * 2 * rotations, duration: duration)
        return SKAction.group([move, rotate])
    }
    
    // Creates a pass action.
    static func pass(
        from origin: CGPoint,
        to target: CGPoint,
        speed: CGFloat,
        playWidth: CGFloat
    ) -> SKAction {
        let dist = origin.distance(to: target)
        let duration = TimeInterval(dist / (playWidth * speed))
        return moveBall(to: target, duration: duration)
    }
    
    // Creates a shot action with easeIn timing.
    static func shot(
        from origin: CGPoint,
        to target: CGPoint,
        speed: CGFloat,
        playWidth: CGFloat,
        rotations: CGFloat = 1.5
    ) -> SKAction {
        let dist = origin.distance(to: target)
        let duration = TimeInterval(dist / (playWidth * speed))
        return moveBall(to: target, duration: duration, rotations: rotations, timingMode: .easeIn)
    }
    
    // Creates a clearance kick.
    static func clearance(
        to target: CGPoint,
        duration: TimeInterval = 0.4,
        rotations: CGFloat = 2
    ) -> SKAction {
        return moveBall(to: target, duration: duration, rotations: rotations, timingMode: .easeOut)
    }
    
    // Creates a dribble action with easeInEaseOut timing.
    static func dribble(
        from origin: CGPoint,
        to target: CGPoint,
        speed: CGFloat,
        playWidth: CGFloat
    ) -> SKAction {
        let dist = origin.distance(to: target)
        let duration = TimeInterval(dist / (playWidth * speed))
        return moveBall(to: target, duration: duration, rotations: 3, timingMode: .easeInEaseOut)
    }
}

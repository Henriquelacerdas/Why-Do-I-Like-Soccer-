import CoreGraphics

// Defines the 4-3-3 defensive formation coordinates
struct DefenseFormation {
    
    static let defenders: [CGPoint] = [
        CGPoint(x: 0.81, y: 0.84),
        CGPoint(x: 0.81, y: 0.62),
        CGPoint(x: 0.81, y: 0.40),
        CGPoint(x: 0.81, y: 0.18)
    ]
    
    static let midfielders: [CGPoint] = [
        CGPoint(x: 0.67, y: 0.35),
        CGPoint(x: 0.72, y: 0.50),
        CGPoint(x: 0.67, y: 0.65)
    ]
    
    static let forwards: [CGPoint] = [
        CGPoint(x: 0.57, y: 0.27),
        CGPoint(x: 0.52, y: 0.50),
        CGPoint(x: 0.57, y: 0.72)
    ]
    
    static let goalkeeper = CGPoint(x: 0.975, y: 0.5)
    
    // All defense players including goalkeeper.
    static let allPlayers: [CGPoint] = defenders + midfielders + forwards + [goalkeeper]
}

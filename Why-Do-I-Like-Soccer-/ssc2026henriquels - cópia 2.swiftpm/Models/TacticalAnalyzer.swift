import CoreGraphics

// Analyzes the user's formation and determines the tactical outcome.
struct TacticalAnalyzer {
    
    enum Outcome {
        case counterAttack    // Too few players in first half (< 2)
        case interception     // Missing coverage on one or both flanks
        case successfulAttack // Good formation (goal scored)
    }
    
    struct FlankZone {
        static let minX: CGFloat = 0.5
        static let maxX: CGFloat = 0.8
        static let topMinY: CGFloat = 0.8   // left flank (top of screen)
        static let bottomMaxY: CGFloat = 0.2 // right flank (bottom of screen)
    }
    
    let positions: [CGPoint]
    
    var leftFlankCount: Int {
        positions.filter {
            $0.x > FlankZone.minX && $0.x < FlankZone.maxX && $0.y > FlankZone.topMinY
        }.count
    }
    
    var rightFlankCount: Int {
        positions.filter {
            $0.x > FlankZone.minX && $0.x < FlankZone.maxX && $0.y < FlankZone.bottomMaxY
        }.count
    }
    
    var firstHalfCount: Int {
        positions.filter { $0.x < 0.5 }.count
    }
    
    var isMissingFlanks: Bool {
        leftFlankCount == 0 || rightFlankCount == 0
    }
    
    var isVulnerableToCounter: Bool {
        firstHalfCount < 2
    }
    
    var isAllInFirstHalf: Bool {
        positions.allSatisfy { $0.x < 0.5 }
    }
    
    // Determines the animation outcome based on formation analysis
    var outcome: Outcome {
        if isVulnerableToCounter {
            return .counterAttack
        } else if isMissingFlanks || isAllInFirstHalf {
            return .interception
        } else {
            return .successfulAttack
        }
    }
}

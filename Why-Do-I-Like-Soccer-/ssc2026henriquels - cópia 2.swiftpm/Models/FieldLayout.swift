import CoreGraphics

// Encapsulates all soccer field dimension calculations and coordinate conversion
struct FieldLayout {

    
    static let aspectRatio: CGFloat = 105.0 / 68.0
    static let fieldScaleFactor: CGFloat = 1.21
    static let marginRatio: CGFloat = 0.12
    static let playerRadiusRatio: CGFloat = 0.025
    static let ballSizeRatio: CGFloat = 0.08
    static let ballOffsetRatio: CGFloat = 0.03
    static let goalkeeperX: CGFloat = 0.03
    
    let minX: CGFloat
    let minY: CGFloat
    let playWidth: CGFloat
    let playHeight: CGFloat
    let fieldSize: CGSize
    let playerRadius: CGFloat
    let viewSize: CGSize
    
    init(viewSize: CGSize) {
        self.viewSize = viewSize
        
        let (fieldWidth, fieldHeight) = FieldLayout.fittedFieldSize(for: viewSize)
        self.fieldSize = CGSize(width: fieldWidth, height: fieldHeight)
        
        let margin = fieldHeight * FieldLayout.marginRatio
        let centerX = viewSize.width / 2
        let centerY = viewSize.height / 2
        
        self.minX = centerX - (fieldWidth / 2) + margin
        self.minY = centerY - (fieldHeight / 2) + margin
        self.playWidth = (centerX + (fieldWidth / 2) - margin) - self.minX
        self.playHeight = (centerY + (fieldHeight / 2) - margin) - self.minY
        self.playerRadius = self.playHeight * FieldLayout.playerRadiusRatio
    }
    

    func normToPixel(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: minX + playWidth * point.x,
            y: minY + playHeight * point.y
        )
    }

    func pixelToNorm(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: (point.x - minX) / playWidth,
            y: (point.y - minY) / playHeight
        )
    }
    
    var fieldCenter: CGPoint {
        CGPoint(x: viewSize.width / 2, y: viewSize.height / 2)
    }
    
    var ballSize: CGSize {
        let side = playHeight * FieldLayout.ballSizeRatio
        return CGSize(width: side, height: side)
    }
    
    var ballOffset: CGFloat {
        playWidth * FieldLayout.ballOffsetRatio
    }
    
    static let redGoalkeeperNorm = CGPoint(x: goalkeeperX, y: 0.5)
    
    
    private static func fittedFieldSize(for viewSize: CGSize) -> (CGFloat, CGFloat) {
        let candidateHeight = viewSize.height * fieldScaleFactor
        let candidateWidth = candidateHeight * aspectRatio
        
        if candidateWidth > viewSize.width {
            return (viewSize.width, viewSize.width / aspectRatio)
        }
        return (candidateWidth, candidateHeight)
    }
}

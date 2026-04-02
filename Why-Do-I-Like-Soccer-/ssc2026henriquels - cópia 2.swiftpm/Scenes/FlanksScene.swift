import SpriteKit

// Animates the tactical outcome based on the user's formation
class FlanksScene: BaseSoccerScene {
    var onGoalAnimationComplete: (() -> Void)?
    var onInterceptionComplete: (() -> Void)?
    var onCounterAttackGoalComplete: (() -> Void)?
    
    override func sceneDidSetup() {
        drawDefenders()
        drawAttackers()
        runTacticalAnimation()
    }
    
    private func runTacticalAnimation() {
        let analyzer = TacticalAnalyzer(positions: FormationStore.attackerPositions)
        
        switch analyzer.outcome {
        case .counterAttack:
            runCounterAttackAnimation()
        case .interception:
            runInterceptionAnimation()
        case .successfulAttack:
            runSuccessfulAttackAnimation()
        }
    }
    
    private func makePassChainBuilder(speed: CGFloat = 0.5, pause: TimeInterval = 0.15, stopAtHalfway: Bool = false) -> PassChainBuilder {
        var builder = PassChainBuilder(layout: layout, playerPositions: FormationStore.attackerPositions)
        builder.passSpeed = speed
        builder.passPause = pause
        builder.stopAtHalfway = stopAtHalfway
        builder.kickSoundAction = kickSoundAction()
        return builder
    }
    
    // Finds the nearest white player node to a given point
    private func nearestWhitePlayer(to point: CGPoint) -> SKShapeNode? {
        whitePlayerNodes.min { a, b in
            a.position.distance(to: point) < b.position.distance(to: point)
        }
    }
}

// Successful Attack Animation

extension FlanksScene {
    
    fileprivate func runSuccessfulAttackAnimation() {
        let (ballNode, startPos) = createBallAtGoalkeeper()
        let builder = makePassChainBuilder()
        let chain = builder.buildChain(from: startPos)
        
        var actions = chain.actions
        let finalPos = chain.finalBallPosition
        
        // Determine goal target based on vertical position
        let normY = layout.pixelToNorm(finalPos).y
        let goalX = layout.minX + layout.playWidth * 0.995
        let goalY = layout.minY + layout.playHeight * (normY > 0.5 ? 0.6 : 0.44) // what side will kick
        let goalPos = CGPoint(x: goalX, y: goalY)
        
        let kickAction = BallActionFactory.shot(
            from: finalPos,
            to: goalPos,
            speed: 1.0,
            playWidth: layout.playWidth,
            rotations: 1.5
        )
        actions.append(kickSoundAction())
        actions.append(kickAction)
        
        guard !actions.isEmpty else { return }
        
        ballNode.run(.sequence(actions)) { [weak self] in
            self?.showGoalAnimation { self?.onGoalAnimationComplete?() }
        }
    }
}

// Counter-Attack Animation

extension FlanksScene {
    
    fileprivate func runCounterAttackAnimation() {
        let (ballNode, startPos) = createBallAtGoalkeeper()
        let builder = makePassChainBuilder(speed: 0.25, pause: 0.3, stopAtHalfway: true)
        let chain = builder.buildChain(from: startPos)
        
        guard let interceptTarget = chain.interceptTarget else {
            // No target found past halfway — just run existing passes
            if !chain.actions.isEmpty {
                ballNode.run(.sequence(chain.actions))
            }
            return
        }
        
        let finalPos = chain.finalBallPosition
        
        if chain.actions.isEmpty {
            // 0 players before half —> go straight to interception
            beginInterception(ballNode: ballNode, from: finalPos, toward: interceptTarget)
        } else {
            ballNode.run(.sequence(chain.actions)) { [weak self] in
                self?.beginInterception(ballNode: ballNode, from: finalPos, toward: interceptTarget)
            }
        }
    }
    
    private func beginInterception(ballNode: SKSpriteNode, from origin: CGPoint, toward target: CGPoint) {
        let interceptionPoint = interpolate(from: origin, to: target, factor: 0.7)
        
        guard let interceptor = nearestWhitePlayer(to: interceptionPoint) else { return }
        
        let dist = origin.distance(to: interceptionPoint)
        let duration = TimeInterval(dist / (layout.playWidth * 0.3))
        
        let ballAction = BallActionFactory.moveBall(to: interceptionPoint, duration: duration)
        let defenderMove = SKAction.move(to: interceptionPoint, duration: duration)
        
        interceptor.run(defenderMove)
        playKickSound()
        ballNode.run(ballAction) { [weak self] in
            self?.runDribbleToGoal(interceptor: interceptor, ballNode: ballNode, from: interceptionPoint)
        }
    }
    
    private func runDribbleToGoal(interceptor: SKShapeNode, ballNode: SKSpriteNode, from origin: CGPoint) {
        let dribbleTarget = layout.normToPixel(CGPoint(x: 0.3, y: 0.5))
        let ballTarget = CGPoint(x: dribbleTarget.x - layout.ballOffset, y: dribbleTarget.y)
        
        let dist = origin.distance(to: dribbleTarget)
        let duration = TimeInterval(dist / (layout.playWidth * 0.18))
        
        // Interceptor dribbles
        let carrierMove = SKAction.move(to: dribbleTarget, duration: duration)
        carrierMove.timingMode = .easeInEaseOut
        interceptor.run(carrierMove)
        
        // Ball follows
        let ballDribble = BallActionFactory.dribble(from: origin, to: ballTarget, speed: 0.18, playWidth: layout.playWidth)
        ballNode.run(ballDribble) { [weak self] in
            self?.shootCounterAttackGoal(ballNode: ballNode)
        }
        
        // Goalkeeper chases after delay
        startGoalkeeperChase(toward: dribbleTarget, afterDelay: 0.5)
    }
    
    private func startGoalkeeperChase(toward target: CGPoint, afterDelay delay: TimeInterval) {
        guard let gk = redGoalkeeperNode else { return }
        
        run(.wait(forDuration: delay)) { [weak self] in
            guard let self = self else { return }
            let dist = gk.position.distance(to: target)
            let duration = TimeInterval(dist / (self.layout.playWidth * 0.15))
            
            let chase = SKAction.move(to: target, duration: duration)
            chase.timingMode = .easeIn
            gk.run(chase)
        }
    }
    
    private func shootCounterAttackGoal(ballNode: SKSpriteNode) {
        let goalPixel = layout.normToPixel(CGPoint(x: 0, y: 0.5))
        let shotTarget = CGPoint(
            x: goalPixel.x,//
            y: goalPixel.y + layout.playHeight * 0.08
        )
        
        let shotAction = BallActionFactory.shot(
            from: ballNode.position,
            to: shotTarget,
            speed: 0.45,
            playWidth: layout.playWidth,
            rotations: 1.5
        )
        
        playKickSound()
        ballNode.run(shotAction) { [weak self] in
            self?.showGoalAnimation(assetName: "goalWhite") {
                self?.onCounterAttackGoalComplete?()
            }
        }
    }
    
    // Geometry Helper
    private func interpolate(from a: CGPoint, to b: CGPoint, factor: CGFloat) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * factor,
            y: a.y + (b.y - a.y) * factor
        )
    }
}

// Interception Animation (Bad Flanks)
extension FlanksScene {
    
    fileprivate func runInterceptionAnimation() {
        let (ballNode, startPos) = createBallAtGoalkeeper()
        
        // First try with stopAtHalfway (normal flanks case)
        let builder = makePassChainBuilder(stopAtHalfway: true)
        let chain = builder.buildChain(from: startPos)
        
        if let interceptTarget = chain.interceptTarget {
            // Normal case: intercept on the way to a player past halfway
            let runActions = {
                self.performInterceptionClearance(ballNode: ballNode, from: chain.finalBallPosition, toward: interceptTarget)
            }
            if chain.actions.isEmpty {
                runActions()
            } else {
                ballNode.run(.sequence(chain.actions)) { runActions() }
            }
        } else {
            // All players in first half: build full chain, intercept before last player
            let fullBuilder = makePassChainBuilder(stopAtHalfway: false)
            let fullChain = fullBuilder.buildChain(from: startPos)
            
            guard let beforeLast = fullChain.positionBeforeLastPass,
                  let lastPlayer = fullChain.lastPlayerPixel,
                  fullChain.actions.count >= 2 else {
                // if only 0-1 players, just run whatever we have
                if !fullChain.actions.isEmpty {
                    ballNode.run(.sequence(fullChain.actions)) { [weak self] in
                        self?.run(.wait(forDuration: 1.0)) {
                            DispatchQueue.main.async { self?.onInterceptionComplete?() }
                        }
                    }
                }
                return
            }
            
            // Remove last pass + wait (2 actions) from the chain
            let trimmedActions = Array(fullChain.actions.dropLast(2))
            
            let runInterception = {
                self.performInterceptionClearance(ballNode: ballNode, from: beforeLast, toward: lastPlayer)
            }
            
            if trimmedActions.isEmpty {
                runInterception()
            } else {
                ballNode.run(.sequence(trimmedActions)) { runInterception() }
            }
        }
    }
    
    private func performInterceptionClearance(ballNode: SKSpriteNode, from origin: CGPoint, toward target: CGPoint) {
        let interceptionPoint = interpolate(from: origin, to: target, factor: 0.7)
        
        guard let interceptor = nearestWhitePlayer(to: interceptionPoint) else { return }
        
        let dist = origin.distance(to: interceptionPoint)
        let duration = TimeInterval(dist / (layout.playWidth * 0.5))
        
        let ballAction = BallActionFactory.moveBall(to: interceptionPoint, duration: duration)
        let defenderMove = SKAction.move(to: interceptionPoint, duration: duration)
        
        // Clearance kick direction
        let isAboveCenter = interceptionPoint.y > (layout.minY + layout.playHeight / 2)
        let clearanceY = isAboveCenter ? (layout.minY + layout.playHeight + 50) : (layout.minY - 50)
        let clearancePos = CGPoint(x: interceptionPoint.x, y: clearanceY)
        let clearanceAction = BallActionFactory.clearance(to: clearancePos)
        
        interceptor.run(defenderMove)
        
        playKickSound()
        ballNode.run(ballAction) { [weak self] in
            // Play goalWhite sound on interception (unsuccessful attack)
            SoundEffectManager.shared.play("goalWhite", volume: 0.6)
            self?.playKickSound()
            ballNode.run(clearanceAction) {
                self?.run(.wait(forDuration: 1.0)) {
                    SoundEffectManager.shared.stop("goalWhite")
                    DispatchQueue.main.async { self?.onInterceptionComplete?() }
                }
            }
        }
    }
}

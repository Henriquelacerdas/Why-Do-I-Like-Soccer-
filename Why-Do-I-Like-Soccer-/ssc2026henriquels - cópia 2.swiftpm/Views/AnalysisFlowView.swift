import SwiftUI
import SpriteKit

// Multi-phase analysis flow: animation -> congrats/fail -> celebration/feedback
struct AnalysisFlowView: View {
    
    enum Phase {
        case animation
        case congrats
        case celebration
        case fail
        case failCounterAttack
    }
    
    @State private var phase: Phase = .animation
    
    // Congrats typewriter
    @State private var congratsTextSkipped = false
    @State private var congratsShowButton = false
    
    var body: some View {
        Group {
            switch phase {
            case .animation:
                animationPhase
            case .congrats:
                congratsPhase
            case .celebration:
                celebrationPhase
            case .fail:
                FailScreenView(reason: .badFlanks)
            case .failCounterAttack:
                FailScreenView(reason: .counterAttack)
            }
        }
        .onChange(of: phase) { _, _ in
            SoundEffectManager.shared.stopAll()
        }
    }
    
    private var animationPhase: some View {
        GeometryReader { geo in
            SpriteView(scene: createFlanksScene(size: geo.size))
        }
    }
    
    // Phase 2: Congratulations
    
    private var congratsPhase: some View {
        ZStack {
            Image("congratulations")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                TypeWriterTextView(
                    text: "Congratulations! Your advances were good enough to score a goal. Let's analyze why it worked.",
                    font: .title,
                    isFinished: $congratsShowButton,
                    isSkipped: $congratsTextSkipped
                )
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    if congratsShowButton {
                        Button {
                            withAnimation(.easeInOut(duration: 0.5)) { phase = .celebration }
                        } label: {
                            nextButtonImage("nextBig", width: 145)
                                .padding(.bottom)
                        }
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { congratsTextSkipped = true }
    }
    
    // Phase 3: Celebration Loop
    
    private var celebrationPhase: some View {
        CelebrationFlankView(destination: CounterDefenseView())
    }
    
    // Scene Factories
    
    private func createFlanksScene(size: CGSize) -> SKScene {
        let scene = FlanksScene(size: size)
        scene.scaleMode = .resizeFill
        
        scene.onGoalAnimationComplete = {
            withAnimation(.easeInOut(duration: 0.5)) { phase = .congrats }
        }
        scene.onInterceptionComplete = {
            withAnimation(.easeInOut(duration: 0.5)) { phase = .fail }
        }
        scene.onCounterAttackGoalComplete = {
            withAnimation(.easeInOut(duration: 0.5)) { phase = .failCounterAttack }
        }
        
        return scene
    }
    
    // Shared Components
    
    private func nextButtonImage(_ name: String, width: CGFloat) -> some View {
        Image(name)
            .resizable()
            .foregroundStyle(Color.black)
            .scaledToFit()
            .frame(width: width)
            .padding(.horizontal, 40)
    }
}

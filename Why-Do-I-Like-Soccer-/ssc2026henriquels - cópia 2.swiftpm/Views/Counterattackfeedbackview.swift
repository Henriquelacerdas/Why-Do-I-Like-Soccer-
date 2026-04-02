import SwiftUI
import SpriteKit

// Feedback screen explaining the danger of not having enough players in the first half, with a looping counter-attack animation.
struct CounterAttackFeedbackView: View {
    
    @State private var textIsSkipped = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                TypeWriterTextView(
                    text: "Their players are positioned too far forward, which could lead to dangerous counter-attacks.",
                    font: .title,
                    isFinished: $showButton,
                    isSkipped: $textIsSkipped
                )
                .padding()
                //.frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120, alignment: .topLeading)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                //.padding(.horizontal, 20)
                //.padding(.top, 10)
                .padding()
                
                GeometryReader { geo in
                    SpriteView(scene: createScene(size: geo.size))
                }
                
                HStack {
                    Spacer()
                    if showButton {
                        NavigationLink(destination: CelebrationFlankView(destination: FinalScreen()).navigationBarBackButtonHidden(true)) {
                            Image("nextBig")
                                .resizable()
                                .foregroundStyle(Color.black)
                                .scaledToFit()
                                .frame(width: 120)
                                .padding(.horizontal, 40)
                        }
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { textIsSkipped = true }
        .onDisappear { SoundEffectManager.shared.stopAll() }
    }
    
    private func createScene(size: CGSize) -> SKScene {
        let scene = CounterAttackFeedbackScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

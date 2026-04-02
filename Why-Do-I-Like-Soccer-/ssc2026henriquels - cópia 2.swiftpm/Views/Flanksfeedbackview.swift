import SwiftUI
import SpriteKit

// Feedback screen showing the field with pulsing flank zones and explanatory text
struct FlanksFeedbackView: View {
    
    @State private var textIsSkipped = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                TypeWriterTextView(
                    text: "The 4-3-3 formation leaves open spaces on the flanks that could offer you dangerous attacking opportunities.",
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
                    SpriteView(scene: createFeedbackScene(size: geo.size))
                }
                
                HStack {
                    Spacer()
                    if showButton {
                        NavigationLink(destination: CounterDefenseView().navigationBarBackButtonHidden(true)) {
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
    
    private func createFeedbackScene(size: CGSize) -> SKScene {
        let scene = FlanksFeedbackScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

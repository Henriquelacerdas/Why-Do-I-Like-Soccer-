import SwiftUI
import SpriteKit

// Screen showing red intercepting a white counter-attack
struct CounterDefenseView: View {
    
    @State private var textIsSkipped = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                TypeWriterTextView(
                    text: "One positive aspect of their formation was positioning players in the first half of the field, which is important to prevent counter-attacks.",
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
                        NavigationLink(destination: FinalScreen().navigationBarBackButtonHidden(true)) {
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
        let scene = CounterDefenseScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

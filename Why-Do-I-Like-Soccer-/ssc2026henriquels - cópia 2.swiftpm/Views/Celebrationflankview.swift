import SwiftUI
import SpriteKit

// Reusable celebration screen showing the flank attack explanation with a looping CelebrationScene animation
struct CelebrationFlankView<Destination: View>: View {
    
    let destination: Destination
    
    @State private var textIsSkipped = false
    @State private var showButton = false
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                TypeWriterTextView(
                    text: "By attacking down the flanks, you can create effective attacks using long passes directly to a forward.",
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
                        NavigationLink(destination: destination.navigationBarBackButtonHidden(true)) {
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
        let scene = CelebrationScene(size: size)
        scene.scaleMode = .resizeFill
        return scene
    }
}

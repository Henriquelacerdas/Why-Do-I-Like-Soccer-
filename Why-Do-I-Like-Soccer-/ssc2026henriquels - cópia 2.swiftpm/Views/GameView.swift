import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject private var vm = GameViewModel()
    @State private var cardBounce = false
    @State private var isPulsing = false
    @State private var hasClickedIdea = false
    
    var body: some View {
        ZStack {
            VStack {
                headerBar
                fieldWithInstructions
                confirmButton
            }
            .disabled(vm.showHelpOverlay)
            
            if vm.showHelpOverlay {
                helpOverlay
            }
        }
        .navigationDestination(isPresented: $vm.navigateToAnalysis) {
            AnalysisFlowView().navigationBarBackButtonHidden(true)
        }
        .alert("End Tactical Setup?", isPresented: $vm.showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") { vm.confirmFormation() }
        } message: {
            Text("Do you want to receive feedback on your attack strategy?")
        }
    }
    
    private var headerBar: some View {
        HStack {
            VStack {
                TypeWriterTextView(
                    text: "I'm defending (whites) and you're attacking (reds). Position your players in all the field strategically to create a strong attack.",
                    font: .title,
                    isFinished: $vm.showButton,
                    isSkipped: $vm.textIsSkipped
                )
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                .padding()
            }
            
            Spacer()
            
            helpButton
        }
    }
    
    private var helpButton: some View {
        Button {
            hasClickedIdea = true
            withAnimation { vm.showHelpOverlay = true }
        } label: {
            Image("idea")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 99))
                .overlay(RoundedRectangle(cornerRadius: 99).stroke(Color.black, lineWidth: 2))
                .scaledToFit()
                .frame(width: 80)
                .scaleEffect(hasClickedIdea ? 1.0 : (isPulsing ? 1.2 : 1.0))
                .animation(
                    hasClickedIdea
                        ? .easeInOut(duration: 0.2)
                        : .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: hasClickedIdea ? false : isPulsing
                )
                .padding(.horizontal, 10)
        }
        .padding(.trailing)
        .onAppear {
            isPulsing = true
        }
    }
    
    private var fieldWithInstructions: some View {
        ZStack {
            GeometryReader { geo in
                SpriteView(scene: createScene(size: geo.size))
            }
            
            if vm.showInstructionCard {
                instructionCard
            }
        }
    }
    
    private var instructionCard: some View {
        HStack(spacing: 12) {
            Image("dragOrTap")
                .resizable()
                .scaledToFit()
                .frame(width: 80)
            
            Text("Drag or click on your\nplayers to move them")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.7)))
        .offset(y: cardBounce ? -188 : -172)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                cardBounce = true
            }
        }
        .transition(.opacity.animation(.easeOut(duration: 0.3)))
        .allowsHitTesting(false)
    }
    
    private var confirmButton: some View {
        HStack {
            Spacer()
            Button { vm.showConfirmation = true } label: {
                Image("nextBig")
                    .resizable()
                    .foregroundStyle(Color.black)
                    .scaledToFit()
                    .frame(width: 145)
                    .padding(.horizontal, 30)
            }
        }
    }
    
    private var helpOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Every defensive formation always leaves some open space in the defensive area. In the 4-3-3, those spaces are the defensive flanks.")
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Image("SoccerHelp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 525, height: 340)
                
                Button("Got it!") {
                    withAnimation {
                        vm.showHelpOverlay = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(40)
            .transition(.scale)
        }
    }
    
    private func createScene(size: CGSize) -> SKScene {
        let scene = TacticsScene(size: size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .systemBackground
        
        scene.onPositionChanged = { id, pos in
            DispatchQueue.main.async { vm.updatePlayerPosition(id: id, newPosition: pos) }
        }
        
        scene.onFirstPlayerMoved = { vm.dismissInstructionCard() }
        
        scene.onSceneTapped = {
            DispatchQueue.main.async { vm.textIsSkipped = true }
        }
        
        return scene
    }
}

import SwiftUI

struct Screen5: View {
    @State private var textIsSkipped: Bool = false
    @State private var animationStep = 0
    @State private var showButtom: Bool = false
    
    
    // Relative coordinates
    let goalkeeperCoords: (CGFloat, CGFloat) = (0.9, 0.5)
    
    let defendersCoords: [(CGFloat, CGFloat)] = [
        (0.75, 0.75), (0.75, 0.58), (0.75, 0.42), (0.75, 0.25)
    ]
    let midfieldersCoords: [(CGFloat, CGFloat)] = [
        (0.64, 0.39), (0.67, 0.5), (0.64, 0.61)
    ]
    let forwardsCoords: [(CGFloat, CGFloat)] = [
        (0.55, 0.3), (0.51, 0.5), (0.55, 0.7)
    ]

    var body: some View {
        GeometryReader { mainGeo in
            VStack {

                TypeWriterTextView(
                    text: "One of the strategic elements in soccer is the team’s defensive formation. My favorite is the 4-3-3, with 4 defenders, 3 midfielders, and 3 forwards, plus the goalkeeper.",
                    font: .title, isFinished: $showButtom, isSkipped: $textIsSkipped)
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                .padding()
                    
                Image("SoccerField")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        GeometryReader { geo in
                            let width = geo.size.width
                            let height = geo.size.height
                            let scaleFactor = width / 700
                            
                            ZStack {
                                PlayerDot(isHighlighted: false)
                                    .scaleEffect(scaleFactor)
                                    .position(
                                        x: width * goalkeeperCoords.0,
                                        y: height * goalkeeperCoords.1
                                    )
                                // Defenders
                                ForEach(0..<4, id: \.self) { i in
                                    PlayerDot(isHighlighted: animationStep == 1)
                                        .scaleEffect(scaleFactor)
                                        .position(
                                            x: width * defendersCoords[i].0,
                                            y: height * defendersCoords[i].1
                                        )
                                }
                                
                                // Midfielders
                                ForEach(0..<3, id: \.self) { i in
                                    PlayerDot(isHighlighted: animationStep == 2)
                                        .scaleEffect(scaleFactor)
                                        .position(
                                            x: width * midfieldersCoords[i].0,
                                            y: height * midfieldersCoords[i].1
                                        )
                                }
                                
                                // Forwards
                                ForEach(0..<3, id: \.self) { i in
                                    PlayerDot(isHighlighted: animationStep == 3)
                                        .scaleEffect(scaleFactor)
                                        .position(
                                            x: width * forwardsCoords[i].0,
                                            y: height * forwardsCoords[i].1
                                        )
                                }
                            }
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
                NavigationLink(destination: GameView().navigationBarBackButtonHidden(true)) {
                    Text("Learn in Practice!")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Capsule().fill(Color.blue))
                }
                //.padding(.bottom, 20)
            }
            .contentShape(Rectangle())
            .onTapGesture{
                textIsSkipped = true
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .task {
            await runAnimationSequence()
        }
    }
    
    func runAnimationSequence() async {
         while !Task.isCancelled {
             withAnimation(.easeInOut(duration: 0.5)) { animationStep = 0 }
             try? await Task.sleep(nanoseconds: 1_500_000_000)
             
             withAnimation(.easeInOut(duration: 0.8)) { animationStep = 1 }
             try? await Task.sleep(nanoseconds: 1_500_000_000)
             
             withAnimation(.easeInOut(duration: 0.8)) { animationStep = 2 }
             try? await Task.sleep(nanoseconds: 1_500_000_000)
             
             withAnimation(.easeInOut(duration: 0.8)) { animationStep = 3 }
             try? await Task.sleep(nanoseconds: 1_500_000_000)
         }
    }
}

struct PlayerDot: View {
    var isHighlighted: Bool
    
    var body: some View {
        Circle()
            .fill(isHighlighted ? Color.blue : Color.white)
            .frame(width: 20, height: 20)
            .shadow(radius: 3)
            .overlay(
                Circle().stroke(Color.black, lineWidth: 2)
            )
            .scaleEffect(isHighlighted ? 1.2 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHighlighted)
    }
}

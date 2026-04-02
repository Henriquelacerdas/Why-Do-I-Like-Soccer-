import SwiftUI

// Shown when the user's formation fails to score
struct FailScreenView: View {
    
    enum FailReason {
        case badFlanks
        case counterAttack
    }
    
    var reason: FailReason = .badFlanks
    
    @State private var textIsSkipped = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            Image("fail")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                TypeWriterTextView(
                    text: "This tactical formation was not enough to score a goal. Let's analyse what could have been done better.",
                    font: .title,
                    isFinished: $showButton,
                    isSkipped: $textIsSkipped
                )
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    if showButton {
                        NavigationLink(destination: destinationView) {
                            Image("nextBlack")
                                .resizable()
                                .foregroundStyle(Color.black)
                                .scaledToFit()
                                .frame(width: 240)
                        }
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { textIsSkipped = true }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch reason {
        case .badFlanks:
            FlanksFeedbackView().navigationBarBackButtonHidden(true)
        case .counterAttack:
            CounterAttackFeedbackView().navigationBarBackButtonHidden(true)
        }
    }
}

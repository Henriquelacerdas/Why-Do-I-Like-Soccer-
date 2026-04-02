
import SwiftUI

struct Screen1: View {
    @State private var textIsSkipped: Bool = false
    @State private var showButtom: Bool = false
    
    var body: some View {
        ZStack {
            Image("backgroundScreen1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                TypeWriterTextView(
                    text: "I'm completely passionate about soccer. People often ask me why do I like spending 90 minutes watching 20 people running after a ball. At first impression, it really doesn't make that much sense.", font: .title, isFinished: $showButtom, isSkipped: $textIsSkipped)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                    .padding()
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    if showButtom {
                        NavigationLink(destination: Screen2().navigationBarBackButtonHidden(true)){
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
        .onTapGesture{
            textIsSkipped = true
        }
    }
}


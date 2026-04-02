import SwiftUI

struct FinalScreen2: View {
    @State private var textIsSkipped: Bool = false
    @State private var showButtom: Bool = false
    
    var body: some View {
        ZStack{
            Image("finalization")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                TypeWriterTextView(text: "For me, soccer is an art that brings together emotion, family, strategy, and many other things. Even though it has no practical utility, it is what keeps me alive.", font: .title, isFinished: $showButtom, isSkipped: $textIsSkipped)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                    .padding()
                
                Spacer()
                
                HStack{
                    Spacer()
                    if showButtom{
                        NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)){
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

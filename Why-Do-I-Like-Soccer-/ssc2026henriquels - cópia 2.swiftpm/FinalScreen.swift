
import SwiftUI

struct FinalScreen: View {
    @State private var textIsSkipped: Bool = false
    @State private var showButtom: Bool = false
    
    var body: some View {
        ZStack{
            Image("prefinalization")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                TypeWriterTextView(text: "I hope that, after this journey, your perspective on soccer has changed a little.", font: .title, isFinished: $showButtom, isSkipped: $textIsSkipped)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                    .padding()
                
                Spacer()
                
                HStack{
                    Spacer()
                    if showButtom{
                        NavigationLink(destination: FinalScreen2().navigationBarBackButtonHidden(true)){
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






import SwiftUI

struct Screen4: View {
    @State private var textIsSkipped: Bool = false
    @State private var showButtom: Bool = false
    
    var body: some View {
        ZStack {
            Image("tacticalModels")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                TypeWriterTextView(
                    text: "In addition to all that, there's one more thing that completely changes the experience of watching soccer: tactical models.", font: .title, isFinished: $showButtom, isSkipped: $textIsSkipped
                )
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.9)))
                    .padding()
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    if showButtom {
                        NavigationLink(destination: Screen5().navigationBarBackButtonHidden(true)){
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


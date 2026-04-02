import SwiftUI

struct TypeWriterTextView: View {
    
    let text: String
    var delay: Int = 30
    var font: Font
    var textAlignment: TextAlignment = .leading
    
    @Binding var isFinished: Bool
    @Binding var isSkipped: Bool
    @State private var animatedText = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Invisible full text to evite text background size changes
            Text(text)
                .font(font)
                .multilineTextAlignment(textAlignment)
                .opacity(0)
            
            Text(animatedText)
                .font(font)
                .multilineTextAlignment(textAlignment)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .task { await animate() }
        .onChange(of: isSkipped) { _ in
            if isSkipped { skipToEnd() }
        }
    }
    
    private func animate() async {
        isFinished = false
        animatedText = ""
        
        for char in text {
            if isSkipped {
                skipToEnd()
                return
            }
            
            animatedText.append(char)
            
            do {
                try await Task.sleep(for: .milliseconds(delay))
            } catch {
                return
            }
        }
        
        isFinished = true
    }
    
    private func skipToEnd() {
        animatedText = text
        isFinished = true
    }
}

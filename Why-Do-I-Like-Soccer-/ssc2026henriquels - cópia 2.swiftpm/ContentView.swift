import SwiftUI

struct ContentView: View {
    @State private var showAboutMe = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background1")
                    .resizable()
                    .scaledToFill()
                
                VStack {
                    Group {
                        Text("Why do I")
                        Text("like soccer?")
                    }
                    .font(.system(size: 80, design: .default))
                    .bold()
                    
                    Spacer()
                        .frame(height: 50)
                    
                    NavigationLink(destination: Screen1().navigationBarBackButtonHidden(true)) {
                        Text("Start Experience")
                            .font(.largeTitle)
                            .bold()
                            .frame(width: 300, height: 50)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAboutMe = true
                        }
                    } label: {
                        Text("About Me")
                            .font(.largeTitle)
                            .bold()
                            .frame(width: 300, height: 50)
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                Spacer()
                
                if showAboutMe {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAboutMe = false
                            }
                        }

                    VStack {
                        ScrollView {
                            VStack(spacing: 20) {
                                
                                HStack {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showAboutMe = false
                                        }
                                    } label: {
                                        Image("back")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                    }
                                    
                                    Spacer()
                                }

                                Image("foto")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 4))

                                Text("""
                Hi, my name is Henrique, and I am a Brazilian computer engineering student passionate about mathematics, technology, dogs, and, of course, soccer.

                This app was created to share a bit of my perspective on soccer with those who have never understood why people love the sport so much. It is also a tribute to my family and friends, who are so important to me.

                I hope you enjoy the experience!
                """)
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 20)
                            }
                            .padding(30)
                        }
                        .frame(maxWidth: 750)
                        .frame(maxHeight: 600)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(24)
                        .shadow(radius: 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                
                }
            }
        }
    }
}

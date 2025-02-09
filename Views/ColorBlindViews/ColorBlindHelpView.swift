//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//

import SwiftUI

struct ColorBlindHelpView: View {
    @ObservedObject var vm: ColorBlindVM
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
                .ignoresSafeArea()
                .ignoresSafeArea()
            
            VStack {
                TabView (selection: $vm.helpPageIndex) {
                    // Page 1
                    VStack {
                        Text("Page 1")
                            .font(.title)
                            .padding()
                        Text("This is the content of the first page.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                            .offset(x: vm.arrowOffset)
                            .onAppear {
                                withAnimation(
                                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                                ) {
                                    vm.arrowOffset = 20
                                }
                            }
                            .padding(.top, 20)
                            .onTapGesture {
                                // Go to the next page when the arrow is tapped
                                withAnimation {
                                    vm.helpPageIndex = (vm.helpPageIndex + 1) % 2 // Cycle between 0 and 1
                                }
                            }
                        
                    }
                    .tag(0)
                    
                    // Page 2
                    VStack {
                        Text("Page 2")
                            .font(.title)
                            .padding()
                        Text("This is the content of the second page.")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button {
                    withAnimation {
                        vm.helpMode = false
                    }
                } label: {
                    Text("Got it")
                        .padding()
                }
                
            }
            //                    .padding(50)
        }
        .transition(.opacity.combined(with: .opacity))
        .padding(20)
        
    }
}

#Preview {
    ColorBlindHelpView(vm: ColorBlindVM())
}

//
//ZStack {
//                    // Dimmed background
//                    Color.black.opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                        .onTapGesture {
//                            withAnimation {
////                                        showPopup = false
//                            }
//                        }
//
//                    // Popup content
//                    VStack(spacing: 20) {
//                        Text("Instructions")
//                            .font(.headline)
//                            .foregroundColor(.white)
//
//                        Text("This is a popup to provide instructions or other information.")
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.white)
//                            .padding()
//
//                        Button("Got it!") {
//                            withAnimation {
////                                        showPopup = false
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .foregroundColor(.black)
//                        .cornerRadius(10)
//                    }
//                    .padding()
//                    .background(.ultraThinMaterial) // Glass effect
//                    .cornerRadius(20)
//                    .shadow(radius: 10)
//                    .frame(maxWidth: 300) // Limit the popup width
//                }
//                .transition(.opacity.combined(with: .scale))

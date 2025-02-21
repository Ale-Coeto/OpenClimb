//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//

import SwiftUI

struct ColorBlindHelpView: View {
    @ObservedObject var vm: ColorBlindVM
    let pd:CGFloat = 30
    
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
                        Text("How to use")
                            .font(.title)
                            .padding()
                            .foregroundStyle(Color("Text"))
            
                        
                        InstructionView(number: 1, description: "Point the camera to the starting hold. The detected color should be fully in the center box.")
                        
                        Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 10, height: 10)
                        .padding(.bottom, pd)
                        
                        InstructionView(number: 2, description: "When centered, click the capture button.")
                        
                        ZStack {
                            Circle()
                                .fill(.gray)
                                .opacity(0.2)
                                .frame(width: 40)
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .frame(width: 40)
                                .opacity(0.6)
                        }
                        .padding(.bottom, pd)
                       
                        InstructionView(number: 3, description: "To freeze and unfreeze use the same capture button.")
                        .padding(.bottom, pd)
                      
                        InstructionView(number: 4, description: "To select another starting hold or improve the result click the 'Reset' button.")
                   
                        
                        HStack {
                            Image(systemName: "arrow.trianglehead.counterclockwise")
                            Text("Reset")
                        }
                        .padding(8.5)
                        .background(Color("Secondary"))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.bottom, 30)
                        
//                        Spacer()
                        
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
                    .padding(.vertical, 50)
                    .padding(.horizontal)
                    .tag(0)
                    
                    // Page 2
                    VStack {
                        Text("Page 2")
                            .font(.title)
                            .padding()
                        Text("This is the content of the second page.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button {
                            withAnimation {
                                vm.helpMode = false
                            }
                        } label: {
                            Text("Got it!")
                        .padding(10)
                        .background(Color("Secondary"))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        }
                    }
                    .tag(1)
                    
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                
                
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


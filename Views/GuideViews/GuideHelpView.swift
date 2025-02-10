//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 09/02/25.
//

import SwiftUI

struct GuideHelpView: View {
    @ObservedObject var vm: GuideVM
    
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
    GuideHelpView(vm: GuideVM())
}

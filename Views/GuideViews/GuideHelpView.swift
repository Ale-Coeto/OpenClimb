//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 09/02/25.
//
//  View with instructions to use guide mode
//

import SwiftUI

struct GuideHelpView: View {
    @ObservedObject var vm: GuideVM
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.9))
                .ignoresSafeArea()
            
            VStack {
                TabView (selection: $vm.helpPageIndex) {
                    // Page 1
                    VStack {
                        
                        Image(systemName: "questionmark.circle")
                            .font(.title)
                            .padding()
                            .foregroundStyle(Color("Primary"))
                        
                        Text("How to use")
                            .font(.title)
                            .padding()
                            .foregroundStyle(Color("Text"))
                        
                        
                        InstructionView(number: 1, description: "Place the camera pointing to the climbing wall.")
                            .padding(.bottom)
                        
                        InstructionView(number: 2, description: "Go to the wall and make sure you are fully visible.")
                            .padding(.bottom)
                        
                        InstructionView(number: 3, description: "Every x seconds, OpenClimb will detect your body position and holds, saying the possible holds that you could reach.")
                            .padding(.bottom)
                        
                        
                        Arrow(vm: vm)
                        
                    }
                    .padding(.horizontal, 30)
                    .tag(0)
                    
                    // Page 2
                    VStack {
                        Text("Description format")
                            .font(.title)
                            .padding()
                            .foregroundStyle(Color("Text"))
                        
                        VStack(alignment: .leading) {
                            
                            
                            Text("The descriptions include the following elements:")
                                .padding(.bottom)
                            
                            FormatView(label: "Color", icon: "paintpalette", description: "To identify routes.")
                            
                            FormatView(label: "Limbs", icon: "hand.raised", description: "Right hand, left hand, right foot, left foot.")
                            
                            FormatView(label: "Holds Positions", icon: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", description: "Above, below, left, right, above to the left, above to the right, below to the left and below to the right.")
                            
                            FormatView(label: "Distance", icon: "ruler", description: "Near (default), far")
                            
                        }
                        
                        Text("Example")
                            .foregroundStyle(Color("Text"))
                            .fontWeight(.semibold)
                        
                        Text("\"There is a blue hold far above your right hand.\"")
                        
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
                    .padding(.horizontal, 30)
                    .tag(1)
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
            }
        }
        .transition(.opacity.combined(with: .opacity))
        .padding(20)
        
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        vm.helpMode = false
                    }
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.gray)
                        .font(.title3)
                }
            }
            Spacer()
        }
        .padding(30)
        
    }
}



#Preview {
    GuideHelpView(vm: GuideVM())
}

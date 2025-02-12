//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import SwiftUI

struct IntroView: View {
    @StateObject var vm = IntroViewVM()
    
    
    var body: some View {
        ZStack {
            Color("Primary")
                .ignoresSafeArea()
                
            
            ZStack {
                
//                if !vm.isIpad {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.6))
                        .ignoresSafeArea()
                        .shadow(radius: 10)
//                }
                
                
                VStack {
                    TabView (selection: $vm.pageIndex) {
                        // Page 1
                        DeveloperView(vm: vm)
                            .tag(0)
                        
                        WhatIsView(vm: vm)
                            .tag(1)
                        
                        // Page 2
                        ColorBlindFeatureView(vm: vm)
                            .tag(2)
                        
                        // Page 3
                        GuideFeatureView(vm: vm)
                            .tag(3)
                        
                        //Page 4
                        TechView()
                            .tag(4)
                       
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    
                    //                Button {
                    //                    withAnimation {
                    //                        vm.helpMode = false
                    //                    }
                    //                } label: {
                    //                    Text("Got it")
                    //                        .padding()
                    //                }
                    
                }
                .padding(30)
                //                    .padding(50)
            }
            .padding(.vertical, 60)
            .padding(.horizontal, vm.isIpad ? 40 : 30)
            .transition(.opacity.combined(with: .opacity))
        }
    }
}

#Preview {
    IntroView()
}

//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//
//  Main intro view
//

import SwiftUI

struct IntroView: View {
    @StateObject var vm = IntroViewVM()
    
    
    var body: some View {
        ZStack {
            Color("Primary")
                .ignoresSafeArea()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.6))
                    .ignoresSafeArea()
                    .shadow(radius: 10)
                
                VStack {
                    TabView (selection: $vm.pageIndex) {
                        // Page 1
                        DeveloperView(vm: vm)
                            .tag(0)
                            .accessibilityLabel("Page 1: Developer information about app developer")
                        
                        WhatIsView(vm: vm)
                            .tag(1)
                            .accessibilityLabel("Page 2: Information about the app's purpose")
                        
                        // Page 2
                        ColorBlindFeatureView(vm: vm)
                            .tag(2)
                            .accessibilityLabel("Page 3: Color blind mode feature")
                        
                        // Page 3
                        GuideFeatureView(vm: vm)
                            .tag(3)
                            .accessibilityLabel("Page 4: Guide mode feature")
                        
                        //Page 4
                        TechView()
                            .tag(4)
                            .accessibilityLabel("Page 5: Technical details of the app")
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    
                }
                .padding(30)
            }
            .padding(.vertical, 60)
            .padding(.horizontal, vm.isIpad ? 40 : 30)
            .transition(.opacity.combined(with: .opacity))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    IntroView()
}

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
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .ignoresSafeArea()
                .shadow(radius: 10)
                
        
            
            VStack {
                TabView (selection: $vm.pageIndex) {
                    // Page 1
                    WhatIsView()
                    .tag(0)
                    
                    // Page 2
                    FeaturesView()
                    .tag(1)
                    
                    // Page 3
                    TechView()
                        .tag(2)
                    
                    //Page 4
                    DeveloperView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Got it")
                }
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
        .transition(.opacity.combined(with: .opacity))
        .padding(.vertical, 60)
        .padding(.horizontal, 40)
    }
}

#Preview {
    IntroView()
}

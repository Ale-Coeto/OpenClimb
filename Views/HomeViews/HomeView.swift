//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Climbing is a sport that targets movement in complex ways. In competitive levels there are also several categories for visually impaired people. This app intents to provide more independence to people with these complications using vision tools.")
                
                NavigationLink {
                    SeeMoreView()
                } label: {
                    Text("Learn more about visual categories in climbing")
                        .underline()
                        .foregroundStyle(Color("Text"))
                }
                
                NavigationLink {
                    ColorBlindView()
                } label: {
                    ModeCard(title: "Colorblind Mode", description: "aaa", image: "")
                }
                
                
                NavigationLink {
                    GuideView()
                } label: {
                    ModeCard(title: "Guide Mode", description: "bbb", image: "")
                }
                
                
            }
            .padding()
            .background(.gray)
            
        }
        
    }
}

#Preview {
    HomeView()
}

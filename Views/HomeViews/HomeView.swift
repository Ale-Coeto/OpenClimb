//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//
//  Home view

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 0) {
                HStack {
                    Text("Home")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .accessibilityLabel("Home Screen")
                    Spacer()
                    
                }
                .padding()
                .background(Color("Primary"))
                
                ScrollView {
                    
                    VStack (alignment: .leading) {
                        
                        Text("Climbing")
                            .foregroundStyle(Color("Text"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Climbing is a sport that targets movement in complex ways. In competitive levels there are also several categories for visually impaired people. This app intents to provide more independence to people with these complications using vision tools.")
                            .accessibilityLabel("Climbing is a sport that requires complex movement. This app helps visually impaired climbers with vision tools.")
                            .minimumScaleFactor(0.8)
                        NavigationLink {
                            SeeMoreView()
                        } label: {
                            Text("Learn more")
                                .underline()
                                .foregroundStyle(Color("Secondary"))
                                .padding(.top, 5)
                        }
                        .accessibilityLabel("Learn more about climbing and accessibility.")
                        .padding(.bottom, 30)
                        
                        Text("Modes")
                            .foregroundStyle(Color("Text"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                            .accessibilityAddTraits(.isHeader)
                        
                        ModeCard(title: "Colorblind Mode", description: "Distinguish different routes by color", image: "CB")
                            .accessibilityLabel("Colorblind Mode. Helps distinguish different routes by color.")
                        
                        ModeCard(title: "Guide Mode", description: "Get real-time audio guidance to climb a route.", image: "GM")
                            .padding(.vertical)
                            .accessibilityLabel("Guide Mode. Provides real-time audio guidance for climbing.")
                        
                    }
                    .padding(30)
                }
                .ignoresSafeArea()
                .background(Color("Bg"))
                
            }
        }
    }
}

#Preview {
    HomeView()
}

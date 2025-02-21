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
            VStack (spacing: 0) {
                HStack {
                    Text("Home")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
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
                        
                        Text("Climbing is a sport that targets movement in complex ways. In competitive levels there are also several categories for visually impaired people. This app intents to provide more independence to people with these complications using vision tools.")
                        
                        NavigationLink {
                            SeeMoreView()
                        } label: {
                            Text("Learn more")
                                .underline()
                                .foregroundStyle(Color("Secondary"))
                        }
                        .padding(.bottom, 30)
                        
                            Text("Models")
                                .foregroundStyle(Color("Text"))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.bottom)
                        
                        //                NavigationLink {
                        //                    ColorBlindView()
                        //                } label: {
                        ModeCard(title: "Colorblind Mode", description: "Distinguish different routes by color", image: "CB")
                        //                    .padding(.vertical)
                        //                }
                        
                        
                        //                NavigationLink {
                        //                    GuideView()
                        //                } label: {
                        ModeCard(title: "Guide Mode", description: "Get real-time audio guidance to climb a route.", image: "")
                            .padding(.vertical)
                        
                        
                        //                }
                        
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

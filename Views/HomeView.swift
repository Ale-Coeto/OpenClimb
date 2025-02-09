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
                
                NavigationLink {
                    ColorBlindView()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                        
                        VStack {
                            Text("Color blind mode")
                        }
                    }
                }
                
                
                NavigationLink {
                    GuideView()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                        
                        VStack {
                            Text("Guide mode")
                        }
                    }
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

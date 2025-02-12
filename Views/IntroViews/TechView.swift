//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import SwiftUI

struct TechView: View {
    var body: some View {
        VStack {
            Text("Main tools used")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
            
            VStack {
                ToolView(image: "Idk", label: "Vision")
            }
            
            NavigationLink {
                HomeView()
            } label: {
                Text("Check it out!")
            }
        }
    }
}

#Preview {
    TechView()
}

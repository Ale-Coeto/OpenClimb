//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        
        NavigationStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityLabel("App Logo: circle with centered mountain")
                .frame(width: 300)
        }
        
        NavigationLink {
            IntroView()
        } label: {
            HStack {
                Text("Get started")
                Image(systemName: "arrow.right")
            }
            .padding()
            .background(Color("Secondary"))
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .padding(.bottom, 100)
        .accessibilityLabel("Get started button")
        .accessibilityHint("Navigates to the introduction screen")
        
    }
}

#Preview {
    LandingView()
}

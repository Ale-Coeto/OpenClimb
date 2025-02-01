//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        Image(systemName: "square")
        Text("Open Climb")
        Button {
            
        } label: {
            HStack {
                Text("Get started")
                Image(systemName: "arrow.right")
            }
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 15))
            
        }
            
    }
}

#Preview {
    LandingView()
}

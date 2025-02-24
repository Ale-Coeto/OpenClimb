//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//
// Tech used view
//

import SwiftUI

struct TechView: View {
    var body: some View {
        VStack {
            Text("Main frameworks used")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
            
            VStack (alignment: .leading) {
                ToolView(image: "visionpro", label: "Vision", color: Color(.blue))
                ToolView(image: "waveform.path.ecg", label: "CreateML/CoreML", color: Color(.mint))
                ToolView(image: "mic", label: "AVFoundation", color: Color(.green))
                ToolView(image: "photo", label: "CoreImage", color: Color(.yellow))
                ToolView(image: "arrow.triangle.2.circlepath", label: "Combine", color: Color(.orange))
                ToolView(image: "square.grid.2x2", label: "UIKit", color: Color(.red))
                ToolView(image: "r.circle", label: "Roboflow", color: Color(.purple))
            }
            .padding(.bottom)
            
            NavigationLink {
                HomeView()
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
        }
        .padding(.bottom)
    }
}

#Preview {
    TechView()
}

//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 11/02/25.
//
//  View to introduce guide mode
//

import SwiftUI

struct GuideFeatureView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            Image("GM")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 50)
                .accessibilityLabel("Image showing the guide mode feature")
            
            Text("Guide mode")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
                .accessibilityLabel("Title: Guide mode")
            
            Text("In real competitions, people with low vision or blind people are allowed to climb with a guide that can only lead them by telling them the positions of each hold. Thus, this mode aims to provide them with independence when training, providing audio descriptions according to their body positions and detected holds.")
                .accessibilityLabel("Description explaining guide mode for climbers with low vision or blindness")
            
            ArrowView(vm: vm)
                .padding(.top)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    GuideFeatureView(vm: IntroViewVM())
}

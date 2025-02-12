//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 11/02/25.
//

import SwiftUI

struct GuideFeatureView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            Text("Guide mode")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
            
            Text("In real competitions, people with low vision or blind people are allowed to climb with a guide that can only lead them by telling them holds positions. Thus, this mode aims to provide them with independence when training, providing audio descriptions according to their body positions and detected holds.")
            
            ArrowView(vm: vm)
                .padding(.top)
        }
    }
}

#Preview {
    GuideFeatureView(vm: IntroViewVM())
}

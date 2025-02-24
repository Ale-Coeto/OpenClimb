//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//
// View for intro for colorblind mode
//

import SwiftUI

struct ColorBlindFeatureView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            
            Image("CB")
                .resizable()
                .aspectRatio(contentMode: .fit)            
                .padding(.horizontal, 50)
                .accessibilityLabel("Image showing the colorblind mode feature")
            
            Text("Color blind mode")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
                .accessibilityLabel("Title: Color blind mode")
            
            Text("When climbing indoors, climbers usually find routes that can be distinguished through colors. However this can become problematic for colorblind people, so the first tool is designed to help distinguish different colored routes.")
                .accessibilityLabel("Description explaining colorblind mode")
            
            ArrowView(vm: vm)
                .padding(.top)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ColorBlindFeatureView(vm: IntroViewVM())
}

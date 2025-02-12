//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import SwiftUI

struct ColorBlindFeatureView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            
            Text("Color blind mode")
                .padding()
                .foregroundStyle(Color("Text"))
                .fontWeight(.semibold)
                .font(.title3)
            
            Text("When climbing indoors, climbers usually find routes that can be distinguished through colors. However this can become problematic for colorblind people, so the first tool is designed to help distinguish different colored routes.")
            
            ArrowView(vm: vm)
                .padding(.top)
        }
    }
}

#Preview {
    ColorBlindFeatureView(vm: IntroViewVM())
}

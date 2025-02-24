//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//
//  View to explain the app's purpose
//

import SwiftUI

struct WhatIsView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .accessibilityLabel("Logo of the OpenClimb app")
            
            Text("What is OpenClimb?")
                .padding()
                .fontWeight(.semibold)
                .foregroundStyle(Color("Text"))
                .accessibilityLabel("Heading: What is OpenClimb?")
            
            
            Text("Open climb is an app designed to provide tools for visually impaired people who want to try climbing or are looking for more independence when practicing the sport indoors.")
                .padding()
                .accessibilityLabel("Description of OpenClimb app for visually impaired climbers")
            
            ArrowView(vm: vm)
                .padding(.top)
            
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WhatIsView(vm: IntroViewVM())
}

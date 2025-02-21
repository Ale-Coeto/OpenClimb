//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
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
            
            Text("What is OpenClimb?")
                .padding()
                .fontWeight(.semibold)
                .foregroundStyle(Color("Text"))
            
            
            Text("Open climb is an app designed to provide tools for visually impaired people who want to try climbing or are looking for more independence when practicing the sport indoors.")
                .padding()
            
            ArrowView(vm: vm)
                .padding(.top)
            
        }
    }
}

#Preview {
    WhatIsView(vm: IntroViewVM())
}

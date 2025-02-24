//
//  SwiftUIView 2.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import SwiftUI

struct DeveloperView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color("Secondary"))
                    .frame(width: vm.imageSize)
                
                Image("Developer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: vm.imageSize)
                    .clipShape(
                        Circle()
                    )
            }
            .padding(.bottom, 20)
            
            
            
            Text("Hi, I'm a software developer currently studying computer science. I was a SSC Winner for 2024 and love to develop new ideas and share my passion for programming with the rest of the community. I also really enjoy climbing and hope to help more people try the sport.")
                .padding(.horizontal)

            
            Text("- Alejandra Coeto")
                .padding()
                
            
            ArrowView(vm: vm)
        }
    }
}

#Preview {
    DeveloperView(vm: IntroViewVM())
}

//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 20/02/25.
//

import SwiftUI

struct FormatView: View {
    let label: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color("Secondary"))
            Text(label)
                .fontWeight(.semibold)
                .foregroundStyle(Color("Secondary"))
        }
        Text(description)
            .padding(.bottom)
    }
}

struct Arrow: View {
    @ObservedObject var vm: GuideVM
    
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.largeTitle)
            .foregroundColor(.blue)
            .offset(x: vm.arrowOffset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                ) {
                    vm.arrowOffset = 20
                }
            }
            .padding(.top, 20)
            .onTapGesture {
                // Go to the next page when the arrow is tapped
                withAnimation {
                    vm.helpPageIndex = (vm.helpPageIndex + 1) // Cycle between 0 and 1
                }
            }
            .onAppear {
                vm.arrowOffset = 0
            }
    }
}

#Preview {
    FormatView(label: "Hi", icon: "arrow.up", description: "text")
}

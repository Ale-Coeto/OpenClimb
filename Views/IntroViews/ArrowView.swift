//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 11/02/25.
//

import SwiftUI

struct ArrowView: View {
    @ObservedObject var vm: IntroViewVM
    
    var body: some View {
        Image(systemName: "arrow.right")
            .font(.title)
            .foregroundColor(.blue)
            .offset(x: vm.arrowOffset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                ) {
                    vm.arrowOffset = 10
                }
            }
            .onTapGesture {
                // Go to the next page when the arrow is tapped
                withAnimation {
                    vm.pageIndex = (vm.pageIndex + 1)
                }
            }
            .onAppear {
                vm.arrowOffset = 0
            }
            
    }
}

#Preview {
    ArrowView(vm: IntroViewVM())
}

//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 11/02/25.
//

import SwiftUI

struct ToolView: View {
    var image: String
    var label: String
    var color: Color
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 40, height: 40)
                    
                Image(systemName: image)
                    .foregroundStyle(.white)
            }
            .padding(.trailing, 5)
            
            Text(label)
        }
    }
}

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
            
    }
}

#Preview {
    ToolView(image: "square.and.arrow.up", label: " ", color: Color(.blue))
}

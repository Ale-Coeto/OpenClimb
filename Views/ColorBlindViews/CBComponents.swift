//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 12/02/25.
//

import SwiftUI

struct DetectedColorView: View {
    let color: (red: UInt8, green: UInt8, blue: UInt8)?
    
    var body: some View {
        HStack (alignment: .center) {
            
            if let color = color {
                Rectangle()
                    .fill(
                        Color(
                            red: Double(color.red) / 255.0,
                            green: Double(color.green) / 255.0,
                            blue: Double(color.blue) / 255.0
                        )
                    )
                    .frame(width: 10, height: 10)
            } else {
                Rectangle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
            }
            Text("Color: \(closestColorName(for: color))")
                .foregroundStyle(.white)
    
        }
        .padding()
    }
}

struct InstructionView: View {
    let number: Int
    let description: String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .top) {
                Text("\(number). ")
                    .foregroundStyle(Color("Secondary"))
                
                Text(description)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack() {
        DetectedColorView(color: (red: 1, green: 1, blue: 1))
    }
}

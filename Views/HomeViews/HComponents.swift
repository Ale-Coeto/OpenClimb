//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 13/02/25.
//

import SwiftUI

struct ModeCard: View {
    let title: String
    let description: String
    let image: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            
            HStack {
                Image(image)
                
                VStack {
                    Text(title)
                    
                    Text(description)
                }
            }
        }
    }
}

#Preview {
    ModeCard(title: "First mode", description: "This is a sample description", image: "Logo")
}

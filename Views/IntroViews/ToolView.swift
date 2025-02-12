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
    
    var body: some View {
        HStack {
            Image(image)
            
            Text(label)
        }
    }
}

#Preview {
    ToolView(image: " ", label: " ")
}

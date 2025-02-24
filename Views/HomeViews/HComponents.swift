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
//            RoundedRectangle(cornerRadius: 10)
//                .fill(.white)
//                .shadow(radius: 1)
//                .frame(height: .)
            
            HStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .padding(.leading)
                
                VStack (alignment: .leading) {
                    Text(title)
                        .foregroundStyle(Color("Text"))
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .foregroundStyle(.gray)
                    
                    NavigationLink {
                        if title == "Colorblind Mode" {
                            ColorBlindView()
                        } else {
                            GuideView()
                        }
                        
                    } label: {
                            Text("Get started")
                        .padding(10)
                        .background(Color("Secondary"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            .padding()
            .background(.white)
            .cornerRadius(10)
            .shadow(color: Color(.black).opacity(0.3), radius: 0.5)
            
        }
    }
}

struct SightCategory: View {
    let category: String
    let bullets: [String]
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .top) {
                Text("\(category). ")
                    .foregroundStyle(Color("Secondary"))
                
                VStack (alignment: .leading) {
                    ForEach(bullets, id:\.self) { bullet in
                        Text("\(bullet)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ModeCard(title: "First mode", description: "This is a sample description", image: "Logo")
    SightCategory(category: "B1", bullets: ["uno", "doss"])
}

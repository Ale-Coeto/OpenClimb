//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 13/02/25.
//
//  Component views for home views
//

import SwiftUI

struct ModeCard: View {
    let title: String
    let description: String
    let image: String
    
    var body: some View {
        ZStack {
            HStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .accessibilityLabel("Image for \(title)")
                
                VStack (alignment: .leading) {
                    Text(title)
                        .foregroundStyle(Color("Text"))
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("ModeCardTitle") 
                        .accessibilityLabel(title)
                    
                    Text(description)
                        .foregroundStyle(.gray)
                        .accessibilityLabel(description)
                    
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
                            .accessibilityLabel("Start guide for \(title)")
                    }
                }
                .padding(.horizontal)
            }
            
            .padding()
            .background(.white)
            .cornerRadius(10)
            .shadow(color: Color(.black).opacity(0.3), radius: 0.5)
            .accessibilityElement(children: .ignore)
            
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
                    .accessibilityLabel("Category: \(category)")
                
                VStack (alignment: .leading) {
                    ForEach(bullets, id:\.self) { bullet in
                        Text("\(bullet)")
                            .accessibilityLabel("Bullet point: \(bullet)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ModeCard(title: "First mode", description: "This is a sample description", image: "Logo")
    SightCategory(category: "B1", bullets: ["uno", "doss"])
}

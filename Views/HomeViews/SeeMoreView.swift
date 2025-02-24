//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 13/02/25.
//

import SwiftUI

struct SeeMoreView: View {
    var body: some View {
        VStack (spacing: 0){
            HStack {
                Text("Paraclimbing")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
    
            }
            .padding()
            .background(Color("Primary"))
            
            ScrollView {
                VStack {
                    Text("Vision Impairment")
                        .foregroundStyle(Color("Text"))
                        .fontWeight(.semibold)
                        .font(.title2)
                        .padding(5)
                    
                    VStack (alignment: .leading) {
                        Text("For visually impaired athletes, there are 3 categories in which they can compete according to their condition:")
                            .padding(.bottom, 5)
                        
                        SightCategory(category: "B1", bullets: ["Athletes have no light perception (blind).", "Visual acuity: < LogMAR 2.60"])
                            .padding(.bottom)
                        
                        SightCategory(category: "B2", bullets: ["Athletes have very low vision in both eyes. This could be on how far (acuity) or wide (field) they can see.","Visual acuity: LogMAR 1.50-2.60","Visual field: < 10 degrees diameter."])
                            .padding(.bottom)
                        
                        SightCategory(category: "B3", bullets: ["Athletes have low vision in both eyes.","Visual acuity: LogMAR 1-1.4", "Visual field: < 40 degrees diameter."])
                            .padding(.bottom)
                        
                        Text("From these categories, only B1 athletes are required to wear a blindfold during competitions. However, all of these climbers are allowed to have a sighted guide to help them select their climbing route.")
                            .padding(.top, 5)
                    }
                    .padding(.bottom, 30)
                    
                    
                    Text("Guide")
                        .foregroundStyle(Color("Text"))
                        .fontWeight(.semibold)
                        .font(.title2)
                        .padding(5)
                    VStack (alignment: .leading) {
                        Text("The guide should help the climber to identify more holds by telling their positions, but shouldn't really give tips on how to move, which limb to use or exaclty which hold to go to.")
                    }
                    .padding(.bottom, 30)
                    
                   
                        Text("Lear more about paraclimbing")
                            .foregroundStyle(Color("Text"))
                            .fontWeight(.semibold)
                            .font(.title2)
                            .padding(5)
                    
                    VStack (alignment: .leading) {
                        Link("Paralympic guide 2028", destination: URL(string: "https://www.paralympic.org.au/wp-content/uploads/2024/08/PA_Para-Climbing-Information-Sheet-New-branding.pdf")!)
                            .foregroundStyle(Color("Secondary"))
                            .padding(.bottom)
                            .underline()
                        
                        Link("IFSC Paraclimbing classification rules", destination: URL(string: "https://images.ifsc-climbing.org/ifsc/image/private/t_q_good/prd/eahxryevjn3vn3usq4jh.pdf")!)
                            .foregroundStyle(Color("Secondary"))
                            .underline()
                    }
                    
                }
                .padding(30)
            }
            .background(Color("Bg"))
        }
    }
}

#Preview {
    SeeMoreView()
}

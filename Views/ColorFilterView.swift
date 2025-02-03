//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 20/01/25.
//

import SwiftUI

struct ColorFilterView: View {
    @StateObject private var viewModel = FrameHandler()
    
        var body: some View {
            VStack {
//                if viewModel.loading {
//                    Text("LOADING")
//                }
//                if let image = viewModel.frame {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
////                        .frame(height: 300)
//                        .border(Color.black, width: 1)
//                } else {
//                    Text("xd")
//                }
                
                Spacer()
                
                HStack {
                    Button("Start camera") {
                        viewModel.startSession()
                    }
                    
                    Button("Stop camera") {
                        viewModel.stopSession()
                    }
                    
                }
//                HStack {
////                    Button("+") {
////                        viewModel.filterIntensity += 0.1
////                    }
////                    Button("-") {
////                        viewModel.filterIntensity -= 0.1
////                    }
//                }
                
            }
            .onAppear {
                viewModel.startSession()
            }
            .onDisappear {
                viewModel.stopSession()
            }
        
    }
}

#Preview {
    ColorFilterView()
}

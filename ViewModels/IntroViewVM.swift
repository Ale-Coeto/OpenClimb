//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import Foundation

class IntroViewVM: ObservableObject {
    @Published var pageIndex: Int = 0
    @Published var arrowOffset: CGFloat = 0
}

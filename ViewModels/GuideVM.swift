//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 09/02/25.
//
//  Class view model for guide mode view
//

import Foundation

class GuideVM: ObservableObject {
    @Published var helpMode: Bool = true
    @Published var arrowOffset: CGFloat = 0
    @Published var helpPageIndex: Int = 0
}

//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 10/02/25.
//

import Foundation
import SwiftUI

@MainActor
class IntroViewVM: ObservableObject {
    @Published var pageIndex: Int = 0
    @Published var arrowOffset: CGFloat = -5
    var isIpad: Bool {
            UIDevice.current.userInterfaceIdiom == .pad
        }
    var imageSize: CGFloat {
        isIpad ? 250 : 150
    }
}

//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 08/02/25.
//

import SwiftUI

let colorDictionary: [String: Color] = [
    "black": .black,
    "blue": .blue,
    "brown": Color.brown, // No built-in `.brown`, so using custom
    "climber": .gray, // Assuming a neutral color for "climber"
    "cream": Color(red: 1.0, green: 0.99, blue: 0.82), // Light cream color
    "going down": .gray, // Assuming gray for a neutral meaning
    "green": .green,
    "orange": .orange,
    "pink": .pink,
    "purple": .purple,
    "red": .red,
    "white": .white,
    "yellow": .yellow
]


let namedColors: [String: (red: UInt8, green: UInt8, blue: UInt8)] = [
    "black": (0, 0, 0),
    "blue": (0, 0, 255),
    "brown": (165, 42, 42),
    "cream": (255, 253, 208),
    "green": (0, 255, 0),
    "orange": (255, 165, 0),
    "pink": (255, 192, 203),
    "purple": (128, 0, 128),
    "red": (255, 0, 0),
    "white": (255, 255, 255),
    "yellow": (255, 255, 0)
]

// Function to calculate the Euclidean distance between two RGB colors
func colorDistance(_ color1: (UInt8, UInt8, UInt8), _ color2: (UInt8, UInt8, UInt8)) -> Double {
    let rDiff = Double(color1.0) - Double(color2.0)
    let gDiff = Double(color1.1) - Double(color2.1)
    let bDiff = Double(color1.2) - Double(color2.2)
    
    return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
}

// Function to find the closest color name
func closestColorName(for color: (red: UInt8, green: UInt8, blue: UInt8)?) -> String {
    guard let color = color else { return "calculating" }
        return namedColors.min { colorDistance(color, $0.value) < colorDistance(color, $1.value) }?.key ?? "Unknown"
    
}

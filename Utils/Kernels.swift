//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//

import Foundation
let kernelCode = """
kernel vec4 highlightColor(__sample image, float redThreshold, float greenThreshold, float blueThreshold) {
    float red = image.r;
    float green = image.g;
    float blue = image.b;
    float threshold = 0.25; // Represents ~20/255 in normalized values

    // Define the threshold ranges
    float redMin = redThreshold - threshold;
    float redMax = redThreshold + threshold;
    float greenMin = greenThreshold - threshold;
    float greenMax = greenThreshold + threshold;
    float blueMin = blueThreshold - threshold;
    float blueMax = blueThreshold + threshold;

    // Check if the pixel's color is within the thresholds
    if (red >= redMin && red <= redMax &&
        green >= greenMin && green <= greenMax &&
        blue >= blueMin && blue <= blueMax) {
        // Keep the matching colors with original opacity
        float whiteFactor = 0.4;
        float nRed = mix(red, 1.0, whiteFactor);
        float nGreen = mix(green, 1.0, whiteFactor);
        float nBlue = mix(blue, 1.0, whiteFactor);
        return vec4(nRed, nGreen, nBlue, image.a);
    } else {
       float darkeningFactor = 0.9; // Adjust this value for stronger/weaker darkening
       float nRed = mix(red, 0.0, darkeningFactor);
       float nGreen = mix(green, 0.0, darkeningFactor);
       float nBlue = mix(blue, 0.0, darkeningFactor);
       return vec4(nRed, nGreen, nBlue, image.a);
    }
}
"""


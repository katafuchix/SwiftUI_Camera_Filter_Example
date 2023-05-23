//
//  CGImage+Extended.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import Foundation
import CoreGraphics
import VideoToolbox

extension CGImage {
    // 映像バッファからCGImageを生成
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else {
            return nil
        }
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        return image
    }
}

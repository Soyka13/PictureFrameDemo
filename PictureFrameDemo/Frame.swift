//
//  Frame.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//

import Foundation

struct Frame {
    var width: Float = 20
    var height: Float = 25.47
    var borderThickness: Float = 4.5
    var pictureAspectRatio: Float = 0.668 {
        didSet {
            self.calculateFrameHeight()
        }
    }
    
    mutating func calculateFrameHeight() {
        let pictureWidth = width - (2 * borderThickness)
        let pictureHeight = pictureWidth / pictureAspectRatio
        height = pictureHeight + (2 * borderThickness)
    }
}

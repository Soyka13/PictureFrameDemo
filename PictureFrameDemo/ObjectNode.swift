//
//  ObjectNode.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//

import Foundation
import ARKit

class ObjectNode: SCNNode {
    var image: UIImage?

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupObject(at position: SCNVector3) {
        guard let image = image else { return }
        let planeGeometry = SCNPlane(width: 0.25, height: 0.25)
        let material = SCNMaterial()
        material.diffuse.contents = image
        planeGeometry.materials = [material]

        self.geometry = planeGeometry
        self.eulerAngles = SCNVector3(self.eulerAngles.x + (-Float.pi / 2),
                                      self.eulerAngles.y, self.eulerAngles.z)
        self.position = position
    }
}

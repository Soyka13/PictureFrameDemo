//
//  FramedPictureNode.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//

import Foundation
import ARKit
import SceneKit

class FramedPictureNode: SCNNode {
    var image: UIImage?
    var pictureFrame: Frame?
    
    override init() {
        super.init()
        name = "tile_node"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = "tile_node"
    }
    
    func setup(image: UIImage, pictureFrame: Frame, at position: SCNVector3) {
        self.image = image
        self.pictureFrame = pictureFrame
        
        self.position = position
        let frameDepth = min(CGFloat(max(pictureFrame.width, pictureFrame.height) / 1000), 0.03)
        
        guard let frameNode = createFrame(depth: frameDepth) else { return }
        
        guard let backgroundNode = createBackground() else { return }
        
        frameNode.addChildNode(backgroundNode)
        
        backgroundNode.position = SCNVector3(
            x: 0,
            y: 0,
            z: Float(frameDepth/2)+0.0005)
        
        frameNode.eulerAngles.x -= (.pi / 2)
        frameNode.position = SCNVector3(
            x: position.x,
            y: position.y,
            z: position.z + Float(frameDepth/2)
        )
        
        guard let pictureNode = createPictureNode() else { return }
        frameNode.addChildNode(pictureNode)

        pictureNode.position = SCNVector3(
            x: 0,
            y: 0,
            z: Float(frameDepth/2)+0.001)
        addChildNode(frameNode.flattenedClone())
        
    }
    
    private func createPictureNode() -> SCNNode? {
        guard let pictureFrame = pictureFrame else { return nil }
        let pictureHeight = pictureFrame.height - (pictureFrame.borderThickness * 2)
        let pictureWidth = pictureFrame.width - (pictureFrame.borderThickness * 2)
        let picture = SCNPlane(width: CGFloat(pictureWidth / 100), height: CGFloat(pictureHeight / 100))
        picture.firstMaterial?.diffuse.contents = image
        picture.firstMaterial?.lightingModel = .blinn
        picture.firstMaterial?.specular.contents = UIColor(white: 0.6, alpha: 1.0)
        picture.firstMaterial?.shininess = 100
        return SCNNode(geometry: picture)
    }
    
    func createFrame(depth frameDepth: CGFloat) -> SCNNode? {
        guard let pictureFrame = pictureFrame else { return nil }
        let frameBox = SCNBox(width: CGFloat(pictureFrame.width / 100), height: CGFloat(pictureFrame.height / 100), length: frameDepth, chamferRadius: 0.001)
        
        frameBox.firstMaterial?.diffuse.contents = UIImage(named: "SilverColor.jpg")
        frameBox.firstMaterial?.normal.contents = UIImage(named: "SilverNormal.jpg")
        frameBox.firstMaterial?.roughness.contents = UIImage(named: "SilverRoughness.jpg")

        frameBox.firstMaterial?.lightingModel = .physicallyBased
        frameBox.firstMaterial?.metalness.contents = UIColor(white: 0.7, alpha: 1.0)
        frameBox.firstMaterial?.shininess = 100
        
        return SCNNode(geometry: frameBox)
    }
    
    func createBackground() -> SCNNode? {
        guard let pictureFrame = pictureFrame else { return nil }
        let margin = CGFloat(pictureFrame.borderThickness / 100) / 2
        let background = SCNPlane(width: CGFloat(pictureFrame.width / 100) - margin, height: CGFloat(pictureFrame.height / 100) - margin)
        background.firstMaterial?.diffuse.contents = UIImage(named: "WhiteColor.jpg")
        background.firstMaterial?.lightingModel = .blinn
        background.firstMaterial?.specular.contents = UIColor(white: 0.6, alpha: 1.0)
        background.firstMaterial?.shininess = 100
        return SCNNode(geometry: background)
    }
}

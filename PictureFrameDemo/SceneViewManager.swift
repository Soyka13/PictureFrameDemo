//
//  SceneViewManager.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//

import Foundation
import ARKit
import SceneKit

class SceneViewManager {
    
    private var sceneView: ARSCNView

    private var currentNode: SCNNode?

    private var planes = [PlaneNode]()

    var isObjectPlaced: Bool {
        return currentNode != nil
    }
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    func setupARSessionConfig() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        sceneView.session.run(configuration)
        showSceneDebugInfo()
    }

    func pauseARSession() {
        guard let config = sceneView.session.configuration as? ARWorldTrackingConfiguration else { return }
        config.planeDetection = []
        print("AR session paused")
        sceneView.session.pause()
    }

    func resetARSession() {
        guard let config = sceneView.session.configuration as? ARWorldTrackingConfiguration else { return }
        config.planeDetection = .vertical
        print("session reseted")
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    func showSceneDebugInfo() {
        sceneView.debugOptions = .showFeaturePoints
        sceneView.showsStatistics = true
    }
    
    func addObject(_ image: UIImage, to node: SCNNode) {
        let objectNode = ObjectNode(image: image)
        objectNode.setupObject(at: node.position)
        node.addChildNode(objectNode)
        currentNode = objectNode
    }

    func addNodeAnchor(worldTransform: simd_float4x4) {
        sceneView.session.add(anchor: ARAnchor(name: "node_anchor", transform: worldTransform))
    }

    func removeARPlaneNode(node: SCNNode) {
        for childNode in node.childNodes {
            childNode.removeFromParentNode()
        }
    }

    func addPlane(to node: SCNNode, anchor: ARPlaneAnchor) {
        let grid = PlaneNode(anchor: anchor)
        self.planes.append(grid)
        node.addChildNode(grid)
    }

    func getPlane(with identifier: UUID) -> PlaneNode? {
        let grid = planes.filter { grid in
            return grid.anchor.identifier == identifier
        }.first
        return grid
    }

    func removePlanes() {
        planes.forEach { $0.removeFromParentNode() }
    }

    func resetProperties() {
        currentNode = nil
        planes.removeAll()
    }
}

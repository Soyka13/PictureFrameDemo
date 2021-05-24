//
//  ViewController.swift
//  PictureFrameDemo
//
//  Created by Olena Stepaniuk on 24.05.2021.
//
//

import UIKit
import Then
import SnapKit
import SceneKit
import ARKit

class ARViewController: UIViewController, UIGestureRecognizerDelegate, ARCoachingOverlayViewDelegate {

    // MARK: - Properties
    private var objectImage: UIImage?

    private lazy var sceneView = ARSCNView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.session.delegate = self
    }

    private lazy var coachingOverlay = ARCoachingOverlayView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.session = sceneView.session
        $0.activatesAutomatically = true
        $0.goal = .verticalPlane

    }

    private var viewCenter: CGPoint {
        let viewBounds = view.bounds
        return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
    }

    private lazy var arSceneManager = SceneViewManager(sceneView: sceneView)

    init(objectImage: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.objectImage = objectImage
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        arSceneManager.setupARSessionConfig()

        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        arSceneManager.pauseARSession()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let query = sceneView.raycastQuery(from: viewCenter,
                                                 allowing: .existingPlaneGeometry, alignment: .vertical) else {
           return
        }

        let results = sceneView.session.raycast(query)

        if let hitTestResult = results.first {
            arSceneManager.addNodeAnchor(worldTransform: hitTestResult.worldTransform)
        }
    }
}

// MARK: - Setup UI
extension ARViewController {
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(sceneView)
        sceneView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
        }

        sceneView.addSubview(coachingOverlay)

        coachingOverlay.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
        }
    }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchorName = anchor.name, let objectImage = objectImage,
           !arSceneManager.isObjectPlaced, anchorName == "node_anchor" {
            arSceneManager.addObject(objectImage, to: node)
            arSceneManager.removePlanes()
            return
        }

        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical,
           !arSceneManager.isObjectPlaced {
            arSceneManager.addPlane(to: node, anchor: planeAnchor)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        guard let grid = arSceneManager.getPlane(with: planeAnchor.identifier) else { return }
        grid.update(anchor: planeAnchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        arSceneManager.removeARPlaneNode(node: node)
    }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        arSceneManager.resetProperties()
    }

    func sessionWasInterrupted(_ session: ARSession) {
        arSceneManager.resetProperties()
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        arSceneManager.resetARSession()
    }
}

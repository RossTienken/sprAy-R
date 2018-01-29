//
//  ViewController.swift
//  SpAy-R
//
//  Created by Ross Tienken on 1/29/18.
//  Copyright © 2018 TheBoys. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var refreshBtn: customButton!
    @IBOutlet weak var reticle: UILabel!
    
    var showRefresh = false
    var currentColor = UIColor.white
    var colorName = "white"
    var canvasNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(canvasNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let cameraPoint = sceneView.pointOfView else{
            return
        }
        let cameraTransform = cameraPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        let sphere = SCNSphere(radius: 0.02)
        let material = SCNMaterial()
        DispatchQueue.main.async {
            if self.drawButton.isTouchInside {
                material.diffuse.contents = self.currentColor
                sphere.materials = [material]
                
                if self.showRefresh == false {
                    self.showButton()
                }
                
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z)
                
                print(self.colorName)
                self.canvasNode.addChildNode(sphereNode)
                
            }
        }
    }
    
    func showButton() {
        showRefresh = true
        refreshBtn.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    @IBAction func refreshSrc(_ sender: Any) {
        self.canvasNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        refreshBtn.isHidden = true
        showRefresh = false
    }
    @IBAction func blackBtn(_ sender: Any) {
        colorName = "black"
        currentColor = UIColor.black
        reticle.textColor = UIColor.black
    }
    @IBAction func blueBtn(_ sender: Any) {
        colorName = "blue"
        currentColor = UIColor.blue
        reticle.textColor = UIColor.blue
    }
    @IBAction func greenBtn(_ sender: Any) {
        colorName = "green"
        currentColor = UIColor.green
        reticle.textColor = UIColor.green
    }
    @IBAction func orangeBtn(_ sender: Any) {
        colorName = "orange"
        currentColor = UIColor.orange
        reticle.textColor = UIColor.orange
    }
    @IBAction func redBtn(_ sender: Any) {
        colorName = "red"
        currentColor = UIColor.red
        reticle.textColor = UIColor.red
    }
    @IBAction func whiteBtn(_ sender: Any) {
        colorName = "white"
        currentColor = UIColor.white
        reticle.textColor = UIColor.white
    }
    
}

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
    @IBOutlet weak var radSlider: UISlider!
    
    //color picker
    @IBOutlet weak var showRainbow: UIButton!
    @IBOutlet weak var colorBack: UIImageView!  //background color
    
    //spray cans
    @IBOutlet weak var blackCan: UIButton!
    @IBOutlet weak var blueCan: UIButton!
    @IBOutlet weak var cyanCan: UIButton!
    @IBOutlet weak var purpleCan: UIButton!
    @IBOutlet weak var pinkCan: UIButton!
    @IBOutlet weak var maroonCan: UIButton!
    @IBOutlet weak var redCan: UIButton!
    @IBOutlet weak var orangeCan: UIButton!
    @IBOutlet weak var yellowCan: UIButton!
    @IBOutlet weak var greenCan: UIButton!
    @IBOutlet weak var darkGreenCan: UIButton!
    @IBOutlet weak var whiteCan: UIButton!
    
    
    
    var showRefresh = false
    var showPicker = false
    var currentColor = UIColor.white
    var canvasNode = SCNNode()
    var newRad = Float(0.02)
    
    @IBAction func newRadValue(_ sender: Any) {
        newRad = radSlider.value
        reticle.font = reticle.font.withSize(CGFloat(newRad * 1000))
    }
    
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
        
        
        let sphere = SCNSphere(radius: CGFloat(newRad))
        let material = SCNMaterial()
        DispatchQueue.main.async {
            if self.showRainbow.isTouchInside {
                self.showPicker = true
                self.showColors()
            }
            if self.drawButton.isTouchInside {
                material.diffuse.contents = self.currentColor
                sphere.materials = [material]
                
                if self.showRefresh == false {
                    self.showButton()
                }
                
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z)
                
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
    
    func showColors() {
        //background color
        self.colorBack.isHidden = false
        
        //spray cans
        self.blackCan.isHidden = false
        self.blueCan.isHidden = false
        self.redCan.isHidden = false
    }
    
    func hideColors() {
        // background color
        colorBack.isHidden = true
        
        //spray cans
        blackCan.isHidden = true
        blueCan.isHidden = true
        redCan.isHidden = true
    }
    

    @IBAction func refreshSrc(_ sender: Any) {
        self.canvasNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        refreshBtn.isHidden = true
        showRefresh = false
    }
    
    
    @IBAction func blackBtn(_ sender: Any) {
        currentColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    @IBAction func cyanBtn(_ sender: Any) {
        currentColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
    }
    
    @IBAction func blueBtn(_ sender: Any) {
        currentColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
    }
    
    @IBAction func purpleBtn(_ sender: Any) {
        currentColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
    }
    @IBAction func pinkBtn(_ sender: Any) {
        currentColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
    }
    
    @IBAction func redBtn(_ sender: Any) {
        currentColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        drawButton.setImage(#imageLiteral(resourceName: "canRed"), for: .normal)
        self.hideColors()
    }
    
    @IBAction func maroonBtn(_ sender: Any) {
        currentColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
    }
    
    @IBAction func orangeBtn(_ sender: Any) {
        currentColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
    }
    
    @IBAction func yellowBtn(_ sender: Any) {
        currentColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
    }
    
    @IBAction func greenBtn(_ sender: Any) {
        currentColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
    }
    
    @IBAction func darkGreenBtn(_ sender: Any) {
        currentColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
    }
    
    @IBAction func whiteBtn(_ sender: Any) {
        currentColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    }
    
}

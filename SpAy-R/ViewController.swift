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
    @IBOutlet weak var drawButton: customDraw!
    @IBOutlet weak var refreshBtn: customButton!
    @IBOutlet weak var saveBtn: customButton!
    @IBOutlet weak var reticle: UILabel!
    @IBOutlet weak var radSlider: UISlider!
    
    // Color wheel
    @IBOutlet weak var wheelBackground: UIImageView!
    @IBOutlet weak var wheelBackColor: UIImageView!
    @IBOutlet var colorPicker: SwiftHSVColorPicker!
    @IBOutlet weak var selectColor: customWheelButton!
    @IBOutlet weak var selectLabel: UILabel!
    
    // default color choices
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
    @IBOutlet weak var rainbowCan: UIButton!
    @IBOutlet weak var rainbowLabel: UILabel!
    
    var showRefresh = false
    var showPicker = false
    var currentColor = UIColor.white
    var colorName = "white"
    var canvasNode = SCNNode()
    var newRad = Float(0.03)
    var drawPOS = [[]]
    
    @IBAction func newRadValue(_ sender: Any) {
        newRad = radSlider.value
        reticle.font = reticle.font.withSize(CGFloat(newRad * 1500))
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
        
        // Color picker
        colorPicker.setViewColor(UIColor.red)
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let cameraPoint = sceneView.pointOfView else{
            return
        }
        let cameraTransform = cameraPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -0.75 * cameraTransform.m31, y: -0.75 * cameraTransform.m32, z: -0.75 * cameraTransform.m33)

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
                
                let newPOS = [cameraPosition.x, cameraPosition.y, cameraPosition.z, self.colorName, self.newRad] as [Any]
                
                self.drawPOS.append(newPOS)
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
    
    @IBAction func build(_ sender: Any) {
        
        let points = drawPOS
        var i = 0
        for point in points {
            if(i != 0) {
                let radius = CGFloat(point[4] as! Float)
                let sphere = SCNSphere(radius: CGFloat(radius))
                let material = SCNMaterial()
                
                
                DispatchQueue.main.async {
                    let color = self.getColor(point[3] as! String)
                    
                    material.diffuse.contents = color
                    sphere.materials = [material]
                    
                    if self.showRefresh == false {
                        self.showButton()
                    }
                    
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.position = SCNVector3(x: point[0] as! Float, y: point[1] as! Float, z: point[2] as! Float)
                    
                    self.canvasNode.addChildNode(sphereNode)
                }
            }else { i = 1}
        }
        
    }
    
    func getColor(_ color:String) -> Any{
        switch color {
        case "black":
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        case "cyan":
            return UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        case "blue":
            return UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        case "purple":
            return UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        case "pink":
            return UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        case "red":
            return UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        case "maroon":
            return UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        case "orange":
            return UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        case "yellow":
            return UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        case "green":
            return UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        case "darkGreen":
            return UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        case "white":
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        default:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
            
        }
    }
    
    func showColors() {
        //background color
        self.colorBack.isHidden = false
        
        //spray cans
        self.blackCan.isHidden = false
        self.cyanCan.isHidden = false
        self.blueCan.isHidden = false
        self.purpleCan.isHidden = false
        self.pinkCan.isHidden = false
        self.redCan.isHidden = false
        self.maroonCan.isHidden = false
        self.orangeCan.isHidden = false
        self.yellowCan.isHidden = false
        self.greenCan.isHidden = false
        self.darkGreenCan.isHidden = false
        self.whiteCan.isHidden = false
        self.rainbowCan.isHidden = false
        self.rainbowLabel.isHidden = false
    }
    
    func hideColors() {
        // background color
        colorBack.isHidden = true
        
        //spray cans
        blackCan.isHidden = true
        cyanCan.isHidden = true
        blueCan.isHidden = true
        purpleCan.isHidden = true
        pinkCan.isHidden = true
        redCan.isHidden = true
        maroonCan.isHidden = true
        orangeCan.isHidden = true
        yellowCan.isHidden = true
        greenCan.isHidden = true
        darkGreenCan.isHidden = true
        whiteCan.isHidden = true
        rainbowCan.isHidden = true
        rainbowLabel.isHidden = true
    }
    


    @IBAction func refreshSrc(_ sender: Any) {

        self.canvasNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        refreshBtn.isHidden = true
        showRefresh = false
        saveBtn.isHidden = false
    }
    
    
    @IBAction func blackBtn(_ sender: Any) {
        colorName = "black"
        currentColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func cyanBtn(_ sender: Any) {
        colorName = "cyan"
        currentColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func blueBtn(_ sender: Any) {
        colorName = "blue"
        currentColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func purpleBtn(_ sender: Any) {
        colorName = "purple"
        currentColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func pinkBtn(_ sender: Any) {
        colorName = "pink"
        currentColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func redBtn(_ sender: Any) {
        colorName = "red"
        currentColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func maroonBtn(_ sender: Any) {
        colorName = "maroon"
        currentColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func orangeBtn(_ sender: Any) {
        colorName = "orange"
        currentColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func yellowBtn(_ sender: Any) {
        colorName = "yellow"
        currentColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func greenBtn(_ sender: Any) {
        colorName = "green"
        currentColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func darkGreenBtn(_ sender: Any) {
        colorName = "darkGreen"
        currentColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func whiteBtn(_ sender: Any) {
        colorName = "white"
        currentColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor

        self.hideColors()
    }
    
    @IBAction func rainbowBtn(_ sender: Any) {
        wheelBackground.isHidden = false
        wheelBackColor.isHidden = false
        colorPicker.isHidden = false
        selectColor.isHidden = false
        selectLabel.isHidden = false
    }
    
    @IBAction func selectBtn(_ sender: Any) {
        // color changes
        currentColor = colorPicker.color
        reticle.textColor = colorPicker.color
        drawButton.backgroundColor = colorPicker.color
        drawButton.layer.borderColor = colorPicker.color.cgColor
        
        // hide color options
        self.hideColors()
        
        
        wheelBackground.isHidden = true
        wheelBackColor.isHidden = true
        colorPicker.isHidden = true
        selectColor.isHidden = true
        selectLabel.isHidden = true
    }
    
}

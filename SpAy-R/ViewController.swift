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
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: customDraw!
    @IBOutlet weak var reticle: UILabel!
    @IBOutlet weak var radSlider: UISlider!
    
    // Save/Load forms
    @IBOutlet weak var saveForm: UIView!
    @IBOutlet weak var saveText: UITextField!
    
    @IBOutlet weak var loadForm: UIView!
    @IBOutlet weak var loadText: UITextField!
    
    
    // Pullout bar
    @IBOutlet weak var clearSaveLoad: clearSaveLoad!

    @IBOutlet weak var saveOpen: topButton!
    @IBOutlet weak var saveIcon: UIImageView!
    
    @IBOutlet weak var loadOpen: middleButton!
    @IBOutlet weak var loadIcon: UIImageView!
    
    @IBOutlet weak var clearBtn: bottomButton!
    @IBOutlet weak var clearIcon: UIImageView!

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
    var currentColor = UIColor.white
    var colorName = [CGFloat(1.0),CGFloat(1.0),CGFloat(1.0), CGFloat(1.0)]
    var canvasNode = SCNNode()
    var newRad = Float(0.03)
    var drawPOS = [[]]
    
    @IBAction func newRadValue(_ sender: Any) {
        newRad = radSlider.value
        reticle.font = reticle.font.withSize(CGFloat(newRad * 1500))
    }
    
    // light status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true

        // Create a new scene
        let scene = SCNScene()

        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(canvasNode)
        sceneView.autoenablesDefaultLighting = true
        
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
                self.showColors()
            }
            if self.drawButton.isTouchInside {
                material.diffuse.contents = self.currentColor
                sphere.materials = [material]

                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z)
                
                let newPOS = [cameraPosition.x, cameraPosition.y, cameraPosition.z, self.colorName, self.newRad] as [Any]
                
                self.drawPOS.append(newPOS)
                self.canvasNode.addChildNode(sphereNode)
            }
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                guard let cameraPoint = sceneView.pointOfView else{
                    return
                }
                let cameraTransform = cameraPoint.transform
                let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
                let cameraOrientation = SCNVector3(x: -0.75 * cameraTransform.m31, y: -0.75 * cameraTransform.m32, z: -0.75 * cameraTransform.m33)
                
                let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
                
                let sphere = SCNSphere(radius: CGFloat(newRad))
                let material = SCNMaterial()
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z)
                
                let newPOS = [cameraPosition.x, cameraPosition.y, cameraPosition.z, self.colorName, self.newRad] as [Any]
                
                self.drawPOS.append(newPOS)
                self.canvasNode.addChildNode(sphereNode)
            }
        }
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
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z) )
            let planeNode = SCNNode()
                planeNode.position = SCNVector3(x:planeAnchor.center.x , y: 0, z: planeAnchor.center.z)
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
                gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/PoopEmoji.png")
                plane.materials = [gridMaterial]
                planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else { return}
        
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
    
    func build() {
        
        let points = drawPOS
        var i = 0
        for point in points {
            if(i > 1) {
//                let radPoint = (point[4] as! [String])
                
                let radius = point[4] as! CGFloat
                let sphere = SCNSphere(radius: CGFloat(radius))
                let material = SCNMaterial()
                
                
                DispatchQueue.main.async {
                    let color = self.getColor(point[3] as! Array<CGFloat>)
                    
                    material.diffuse.contents = color
                    sphere.materials = [material]
                    
                    
                    let sphereNode = SCNNode(geometry: sphere)
                    sphereNode.position = SCNVector3(x: Float(point[0] as! CGFloat), y: Float(point[1] as! CGFloat), z: Float(point[2] as! CGFloat))
                    
                    self.canvasNode.addChildNode(sphereNode)
                }
            }else { i = i+1}
        }
        
    }
    
    func getColor(_ color:Array<CGFloat>) -> CGColor{
        return UIColor(red: color[0], green: color[1], blue: color[2], alpha: color[3]).cgColor
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        self.view.endEditing(true)
        saveForm.isHidden = true
        
        let parameters = ["data": drawPOS, "name": saveText.text!.lowercased() as Any]
        
        guard let url = URL(string: "http://10.9.21.139:5000/api/model") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            
            }.resume()
    }
    
    
    @IBAction func loadBtn(_ sender: Any) {
        self.view.endEditing(true)
        loadForm.isHidden = true
        
        self.canvasNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        let loadInput = loadText.text!.lowercased()
        let modelName = loadInput.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        guard let url = URL(string: "http://10.9.21.139:5000/api/model/"+modelName!) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            if let data = data {
                
                do {
                    guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {return}
                    self.drawPOS = [[]]
                    
                    self.drawPOS = json["data"] as! [[Any]]
                    
                    self.build()
                    
                }
            }
            }.resume()
    }
    
    @IBOutlet weak var tapClose: UIButton!
    @IBAction func tapAction(_ sender: Any) {
        hideOptions()
    }
    
    
    @IBAction func saveClose(_ sender: Any) {
        saveForm.isHidden = true
    }
    
    @IBAction func loadClose(_ sender: Any) {
        loadForm.isHidden = true
    }
    // Options bar actions
    @IBAction func showBar(_ sender: Any) {
        showOptions()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        saveForm.isHidden = false
        hideOptions()
    }
    
    @IBAction func loadAction(_ sender: Any) {
        loadForm.isHidden = false
        hideOptions()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        drawPOS = [[]]
        self.canvasNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        hideOptions()
    }
    
    func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
    }
    
    // Show/Hide cans & colors
    
    func showColors() {
        // Hide options
        hideOptions()
        
        // Background color
        self.colorBack.isHidden = false
        
        // Spray cans
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
        
        // Spray cans
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
    
    func showOptions() {
        tapClose.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.saveOpen.frame.origin.x = CGFloat(-10)
            self.saveIcon.frame.origin.x = CGFloat(5)
            
            self.loadOpen.frame.origin.x = CGFloat(-10)
            self.loadIcon.frame.origin.x = CGFloat(10)
            
            self.clearBtn.frame.origin.x = CGFloat(-10)
            self.clearIcon.frame.origin.x = CGFloat(5)
        })
    }
    
    func hideOptions() {
        tapClose.isHidden = true
        UIView.animate(withDuration: 1.0, animations: {
            self.saveOpen.frame.origin.x = CGFloat(-200)
            self.saveIcon.frame.origin.x = CGFloat(-100)
            
            self.loadOpen.frame.origin.x = CGFloat(-200)
            self.loadIcon.frame.origin.x = CGFloat(-100)
            
            self.clearBtn.frame.origin.x = CGFloat(-200)
            self.clearIcon.frame.origin.x = CGFloat(-100)
        })
    }
    
    // Can actions
    
    @IBAction func blackBtn(_ sender: Any) {
        colorName = [0,0,0,CGFloat(1)]
        currentColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func cyanBtn(_ sender: Any) {
        colorName = [0.1333, 0.9176, 0.9608, CGFloat(1)]
        currentColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.1333, green: 0.9176, blue: 0.9608, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func blueBtn(_ sender: Any) {
        colorName = [0,0,1,CGFloat(1)]
        currentColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func purpleBtn(_ sender: Any) {
        colorName = [0.8,0,1,CGFloat(1)]
        currentColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.8, green: 0, blue: 1, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func pinkBtn(_ sender: Any) {
        colorName = [1,0.3686,0.949,CGFloat(1)]
        currentColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 0.3686, blue: 0.949, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func redBtn(_ sender: Any) {
        colorName = [1,0,0,CGFloat(1)]
        currentColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func maroonBtn(_ sender: Any) {
        colorName = [0.502,0,0,CGFloat(1)]
        currentColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.502, green: 0, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func orangeBtn(_ sender: Any) {
        colorName = [0.9608,0.549,0.1333,CGFloat(1)]
        currentColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        reticle.textColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0.9608, green: 0.549, blue: 0.1333, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func yellowBtn(_ sender: Any) {
        colorName = [1,1,0,CGFloat(1)]
        currentColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func greenBtn(_ sender: Any) {
        colorName = [0,0.6,0,CGFloat(1)]
        currentColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func darkGreenBtn(_ sender: Any) {
        colorName = [0,0.2,0,CGFloat(1)]
        currentColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        reticle.textColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        drawButton.backgroundColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0)
        drawButton.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1.0).cgColor
        
        self.hideColors()
    }
    
    @IBAction func whiteBtn(_ sender: Any) {
        colorName = [1,1,1,CGFloat(1)]
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
        let colour = colorPicker.color
        let rgbColour = colour?.cgColor
        let rgbColours = rgbColour?.components
        colorName = rgbColours!
        
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

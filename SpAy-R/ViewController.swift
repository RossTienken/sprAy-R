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
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var reticle: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var colorPicker: UISegmentedControl!
    @IBOutlet var colorDisplay: UIView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var micToggle: UISwitch!
    
    var currentColor = UIColor.white
    
    let recorder = RPScreenRecorder.shared()
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
//       some bullshit that patrick added to try and make the screen recorder work
        
        recordButton.layer.cornerRadius = 32.5
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
                
                
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z)
                
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            }
        }
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
    
    @IBAction func blackBtn(_ sender: Any) {
        currentColor = UIColor.black
        reticle.textColor = UIColor.black
    }
    @IBAction func blueBtn(_ sender: Any) {
        currentColor = UIColor.blue
        reticle.textColor = UIColor.blue
    }
    @IBAction func greenBtn(_ sender: Any) {
        currentColor = UIColor.green
        reticle.textColor = UIColor.green
    }
    @IBAction func orangeBtn(_ sender: Any) {
        currentColor = UIColor.orange
        reticle.textColor = UIColor.orange
    }
    @IBAction func redBtn(_ sender: Any) {
        currentColor = UIColor.red
        reticle.textColor = UIColor.red
    }
    @IBAction func whiteBtn(_ sender: Any) {
        currentColor = UIColor.white
        reticle.textColor = UIColor.white
    }
    
    func viewReset() {
        micToggle.isEnabled = true
        statusLabel.text = "Ready to Record"
        statusLabel.textColor = UIColor.black
        recordButton.backgroundColor = UIColor.green
    }
    
    @IBAction func recordButtonTapped() {
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    
    func startRecording() {
        
        
        guard recorder.isAvailable else {
            print("Recording is not available at this time.")
            return
        }
        
        if micToggle.isOn {
            recorder.isMicrophoneEnabled = true
        } else {
            recorder.isMicrophoneEnabled = false
        }
        
        recorder.startRecording{ [unowned self] (error) in
            
            guard error == nil else {
                print("There was an error starting the recording.")
                return
            }
            
            print("Started Recording Successfully")
            self.micToggle.isEnabled = false
            self.recordButton.backgroundColor = UIColor.red
            self.statusLabel.text = "Recording..."
            self.statusLabel.textColor = UIColor.red
            
            self.isRecording = true
            
        }
        
    }
    
    func stopRecording() {
        
        recorder.stopRecording { [unowned self] (preview, error) in
            print("Stopped recording")
            
            guard preview != nil else {
                print("Preview controller is not available.")
                return
            }
            
            let alert = UIAlertController(title: "Recording Finished", message: "Would you like to edit or delete your recording?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
                self.recorder.discardRecording(handler: { () -> Void in
                    print("Recording suffessfully deleted.")
                })
            })
            
            let editAction = UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction) -> Void in
                preview?.previewControllerDelegate = self as RPPreviewViewControllerDelegate
                self.present(preview!, animated: true, completion: nil)
            })
            
            alert.addAction(editAction)
            alert.addAction(deleteAction)
            self.present(alert, animated: true, completion: nil)
            
            self.isRecording = false
            
            self.viewReset()
            
        }
        
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
}

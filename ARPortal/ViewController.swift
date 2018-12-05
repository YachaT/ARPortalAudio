//
//  ViewController.swift
//  ARPortal
//
//  Created by Yacha Toueg on 11/15/18.
//  Copyright © 2018 Yacha Toueg. All rights reserved.
//

import UIKit
import ARKit
import AVFoundation


class ViewController: UIViewController, ARSCNViewDelegate {
    var audioPlayer = AVAudioPlayer()

    @IBAction func Play(_ sender: Any) {
        audioPlayer.play()
    }
    
    @IBAction func Pause(_ sender: Any) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
        else {
        }
    }
    @IBAction func Restart(_ sender: Any) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }
        else {
            audioPlayer.play()
        }
    }
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        // we will need to first detect a horizontal plane to have our portal show. Let's add  horizontal detection
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        // here we trigger the didAdd function that will show "plane detected" for 3seconds
        self.sceneView.delegate = self
        
        // the user will add the portal after tapping on a horizontal plane.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:Bundle.main.path(forResource:"relaxation", ofType:"mp3")!))
            audioPlayer.prepareToPlay()}
            
        catch { print(error)
        }
    }
    
     // this test if the location that you touched in the scene view matches the location of the plane of a horizontal surface. If the touch location does match the location of an existing plane then this test array will have one element of results - that element being the result of what you touched
    
    
   @objc func handleTap(sender: UITapGestureRecognizer){
    guard let sceneView = sender.view as? ARSCNView else {return}
    let touchLocation = sender.location(in: sceneView)
    let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
    
    if !hitTestResult.isEmpty {
        self.addPortal(hitTestResult: hitTestResult.first!)
    } else {
        // npo
    }}
    
    // let's add our portal node!
    func addPortal(hitTestResult: ARHitTestResult){
        let portalScene = SCNScene(named:"Portal.scnassets/Portal.scn")
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        let transform = hitTestResult.worldTransform
        let planeXpostion = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode.position = SCNVector3(planeXpostion,planeYposition,planeZposition)
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        // call the function addplane
        self.addPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imageName: "bottom")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "Back")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "sidewallA")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "sidewallB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sidedoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sidedoorB")
     }
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeDetected.isHidden = true
        }
    }
    
    //function to add plane (adding the photo to the object from the Portal.scn) (recurisvely true --> the floor and the roof are not immediate children of the portal but they are immediate children of the entrance
    
    //adding the planes ROOF AND BOTTOM
    func addPlane(nodeName:String, portalNode: SCNNode, imageName:String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"Portal.scnassets/\(imageName).png")
    }
    
    //addind the walls
    func addWalls(nodeName:String, portalNode: SCNNode, imageName:String){
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named:"Portal.scnassets/\(imageName).png")
        
    }
}

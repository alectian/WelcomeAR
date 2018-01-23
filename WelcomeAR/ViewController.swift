//
//  ViewController.swift
//  WelcomeAR
//
//  Created by tab on 2017/12/15.
//  Copyright © 2017年 tab. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import AVFoundation
import AVKit

let screenBounds = UIScreen.main.bounds
let loginBtnFrame = CGRect.init(x: screenBounds.size.width-100, y: 100, width: 100, height: 50)
let loginBtnTitle = "Log In >"
class ViewController: RootViewController, ARSCNViewDelegate , AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var overlayView: UIView! {
        didSet {
            self.overlayView.layer.borderColor = UIColor(red:0.49, green:1.00, blue:0.99, alpha:1.00).cgColor
            self.overlayView.layer.borderWidth = 5
            self.overlayView.layer.cornerRadius = 8
            self.overlayView.backgroundColor = .clear
        }
    }
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let backCamera =  AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: backCamera) else {
            return session
        }
        session.addInput(input)
        return session
    }()
    lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    //    observation 可見的結果拿到
    var previiosObservarion: VNDetectedObjectObservation?
    //    視覺序列處理器
    let visionSequenceHandler = VNSequenceRequestHandler()
    //    識別範圍
    let confidenceThreshold = 0.4
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "ObjectTrackingQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        
        self.overlayView.frame = .zero
        self.cameraView.layer.addSublayer(self.cameraLayer)
        
        
        let loginBtn:MyButton = MyButton.init(frame: loginBtnFrame)
        loginBtn.setTitle(loginBtnTitle, for: .normal)
        loginBtn.addTarget(self, action: #selector(loginAction), for: UIControlEvents.touchUpInside)
        //        sceneView.addSubview(loginBtn)
        view.addSubview(loginBtn)
        
        
//        let cameraInput = AVCaptureInput()
        
        
        // Set the view's delegate
//        sceneView.delegate = self
//
//        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    @objc func loginAction(){
    
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginNav")
        present(loginVC!, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
//        sceneView.session.run(configuration)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //        確認我們拿到當前最新的數據
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let lastObservation = self.previiosObservarion else { return }
        
        let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: handleVisionRequestUpdate)
        
        request.trackingLevel = .accurate // 追蹤等級： 精準追蹤(比較耗電)
        
        do{
            try self.visionSequenceHandler.perform([request], on: pixelBuffer)
        } catch {
            print("沒有什麼好追的！")
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("tapped screen")
        
        self.overlayView.frame.size = CGSize(width: 100, height: 100) // 框框最初大小 100 * 100
        self.overlayView.center = (touches.first?.location(in: self.view))!
//        self.overlayView.center = sender.location(in: self.view) // 點擊物件的中心
        
        let orginalRect = self.overlayView.frame ?? .zero
        var convertedRect = self.cameraLayer.metadataOutputRectConverted(fromLayerRect: orginalRect)
        
        convertedRect.origin.y = 1 - convertedRect.origin.y
        
        let currentObservervation = VNDetectedObjectObservation(boundingBox: convertedRect)
        self.previiosObservarion = currentObservervation
    }

    
    
    func handleVisionRequestUpdate( request: VNRequest, error: Error?){
        
        DispatchQueue.main.async {
            guard let currentObservation = request.results?.first as? VNDetectedObjectObservation else {
                
                self.overlayView.frame = .zero
                return
            }
            self.previiosObservarion = currentObservation // 更新最新結果
            
            
            //            guard currentObservation.confidence >= self.confidenceThreshold else {return}
            
            var currentBoundingBox = currentObservation.boundingBox
            currentBoundingBox.origin.y = 1 - currentBoundingBox.origin.y //翻轉座標
            
            let newBoundingBox = self.cameraLayer.layerRectConverted(fromMetadataOutputRect: currentBoundingBox)
            
            self.overlayView.frame = newBoundingBox
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
//        sceneView.session.pause()
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
}

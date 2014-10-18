//
//  AVFViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/16/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore
import Photos

class AVFViewController: UIViewController {

    var stillImageOutput = AVCaptureStillImageOutput()
    var album : PHAssetCollection!
    var delegate : GalleryDelegate?
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturePreviewImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        self.setupAVFoundation()
        self.setupTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - AVFoundation
    
    func setupAVFoundation() {
        var captureSession = AVCaptureSession()
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        var bounds = self.previewView.layer.bounds
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        // previewLayer.frame = CGRectMake(0, 65, self.view.frame.size.width, CGFloat(self.view.frame.size.height * 0.6))
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.bounds = bounds
        previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        // self.view.layer.addSublayer(previewLayer)
        self.previewView.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        
        if input == nil {
            println("No Bueno!")
        }
        captureSession.addInput(input)
        
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        
        self.stillImageOutput.outputSettings = outputSettings
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
    }

    @IBAction func capturePressed(sender: AnyObject) {
        var videoConnection : AVCaptureConnection?
        
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            
            if videoConnection != nil {
                break;
            }
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImageView.image = image
        })
        
        self.saveButton.enabled = true
    }
    
    // MARK: - Photos Framework Save
    
    @IBAction func saveButton(sender: AnyObject) {
        self.saveAssetToPhotos()
    }
    
    func saveAssetToPhotos() {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self.capturePreviewImageView.image)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.album)
            albumChangeRequest.addAssets([assetPlaceholder])
        }, completionHandler: nil)
        
        self.delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Gesture Recognizer
    
    func setupTapGesture() {
        var tapImage = UITapGestureRecognizer(target: self, action: "saveAssetToPhotos")
        self.capturePreviewImageView.addGestureRecognizer(tapImage)
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        // let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "dismissVC")
        // let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveAssetToPhotos:")
        self.navigationTitle.title = "AVFoundation Camera"
        self.saveButton.enabled = false
        //self.navigationBar.backItem?.leftBarButtonItem = cancelButton
        //self.navigationItem.leftBarButtonItem = cancelButton
        // self.instructionsLabel.text = "Tap image to save"
        // self.instructionsLabel.hidden = true
    }
    
}
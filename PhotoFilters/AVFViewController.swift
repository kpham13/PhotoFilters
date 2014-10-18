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
    
    @IBOutlet weak var capturePreviewImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVC()

        var captureSession = AVCaptureSession()
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        previewLayer.frame = CGRectMake(0, 65, self.view.frame.size.width, CGFloat(self.view.frame.size.height * 0.6))
        self.view.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        
        if input == nil {
            println("no bueno")
        }
        
        captureSession.addInput(input)
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
        
        // Gesture Recognizer
        var tapImage = UITapGestureRecognizer(target: self, action: "saveAssetToPhotos:")
        self.capturePreviewImageView.addGestureRecognizer(tapImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    }
    
    // MARK: - Photos Framework Save
    
    func saveAssetToPhotos(asset: PHAsset) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self.capturePreviewImageView.image)
            let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.album)
            albumChangeRequest.addAssets([assetPlaceholder])
        }, completionHandler: nil)
        
        self.delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        self.dismissVC()
    }
    
    // MARK: - Navigation Actions
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.dismissVC()
    }
    
    func dismissVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        self.navigationTitle.title = "AVFoundation Camera"
    }
    
}
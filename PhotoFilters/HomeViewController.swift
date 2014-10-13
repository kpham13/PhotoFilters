//
//  HomeViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/13/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit

// 4 ImagePickerControllerDelegate, NavigationControllerDelegate | 8.5 GalleryDelegate
class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate {

    var defaultImage = UIImage(named: "default")
    
    @IBOutlet weak var imageView: UIImageView! // 1 UIImageView and Outlet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 2 UIButton and Action Sheet
    @IBAction func photoPressed(sender: AnyObject) {
        // Instantiate UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet) // UIAlertControllerStyle is an enum. Once typed, it'll give you options afterwards.
        
        // Create UIAlertActions
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let imagePickerAction = UIAlertAction(title: "Image Picker", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        // Choose Existing
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            // 3 Segue from HomeViewController to GalleryViewController
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        // Add actions to UIAlertController
        alertController.addAction(cameraAction)
        alertController.addAction(imagePickerAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        // Show alertController
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 5 UIImagePickerController selection
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 8.6
    // MARK: - Gallery Delegate
    
    func didTapOnPicture(image : UIImage) {
        println("didTapOnPicture")
        self.imageView.image = image
    }
    
    // 8.2
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Custom
    
    func imageLoad() {
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 6
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.imageView.image = self.defaultImage
    }
}

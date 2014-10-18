//
//  HomeViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/13/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import OpenGLES
import Social

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var galleryVC = GalleryViewController() //? and weak var in GalleryViewController
    
    var context : CIContext?
    var originalThumbnail : UIImage?
    var filters = [Filter]()
    var filterThumbnails = [FilterThumbnail]()
    let imageQueue = NSOperationQueue()
    var currentImage : UIImage?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVC()
        self.coreImageContext()
        self.generateThumbnail()
        
        // Call CoreDataSeeder function (data from appDelegate managedObjectContext)
        var launchedOnce = NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") // Primitives get copied, not referenced
        if launchedOnce != true {
            println("First time launching, seeding data")
            var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate // Access AppDelegate
            var seeder = CoreDataSeeder(context: appDelegate.managedObjectContext!)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            seeder.seedCoreData()
        } else {
            println("Has launched before, not seeding data")
        }
        
        self.fetchFilters()
        self.resetFilterThumbnails()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // CVH0 UIImage onto prototype cell. Create FilterCollectionViewCell custom class.
        // CVH1
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterCollectionViewCell
        
        // CVH2
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        // Lazy loading
        if filterThumbnail.filteredThumbnail != nil {
            cell.imageView.image = filterThumbnail.filteredThumbnail
        } else {
            // Set collection imageView to originalThumbnail, then generate filteredThumbnail. Set FilteredCollectionViewCell to image result.
            cell.imageView.image = filterThumbnail.originalThumbnail
            filterThumbnail.generateThumbnail({ (image) -> (Void) in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCollectionViewCell {
                    cell.imageView.image = image
                }
            })
        }
        
        // CVH3
        return cell
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        var filteredImage = UIImage()
        var image = CIImage(image: self.currentImage)
        var imageFilter = CIFilter(name: filterThumbnail.filterName)
        imageFilter.setDefaults()
        imageFilter.setValue(image, forKey: kCIInputImageKey)
        
        var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
        var extent = result.extent()
        var imageRef = self.context?.createCGImage(result, fromRect: extent)
        filteredImage = UIImage(CGImage: imageRef)
        self.imageView.image = filteredImage
        
        let revertButton = UIBarButtonItem(title: "Revert", style: UIBarButtonItemStyle.Bordered, target: self, action: "revertFilter")
        self.navigationItem.leftBarButtonItem = revertButton
        self.exitFilterMode()
    }
    
    // MARK: - Gallery Delegate
    
    func didTapOnPicture(image : UIImage) {
        self.currentImage = image
        self.imageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
    }

    // MARK: - Core Image Context
    
    func coreImageContext() {
        var options = [kCIContextWorkingColorSpace : NSNull()] //
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2) // Newer devices can use OpenGLES3
        self.context = CIContext(EAGLContext: myEAGLContext, options: options)
    }
    
    // MARK: - Photo Filter
    
    func generateThumbnail() {
        let size = CGSize(width: 150, height: 150)
        
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 150, height: 150))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func fetchFilters() {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context = appDelegate.managedObjectContext
        
        var error : NSError?
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        let fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            self.filters = filters
        }
    }
    
    func resetFilterThumbnails() {
        var newFilters = [FilterThumbnail]()
        for filterIndex in 0...(self.filters.count-1) { // Alternative: for var filterIndex = 0; filterIndex < self.filters.count; ++filterIndex
            var filter = self.filters[filterIndex]
            var filterName = filter.name
            var thumbnail = FilterThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.context!)
            newFilters.append(thumbnail)
        }
        
        self.filterThumbnails = newFilters
    }
    
    func revertFilter() {
        self.imageView.image = self.currentImage
        self.navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Image Picker Controller
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.currentImage = image
        self.imageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Social
    
    func postToTwitter(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            var tweetSheet : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetSheet.setInitialText("What's happening?")
            tweetSheet.addImage(self.imageView.image)
            
            self.presentViewController(tweetSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: - Animation
    
    func enterFilterMode() {
        self.imageViewHeightConstraint.constant = self.imageViewHeightConstraint.constant * 0.9
        self.imageViewWidthConstraint.constant = self.imageViewWidthConstraint.constant * 0.9
        self.collectionViewBottomConstraint.constant = 50
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "exitFilterMode")
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func exitFilterMode() {
        self.imageViewHeightConstraint.constant = self.imageViewHeightConstraint.constant / 0.9
        self.imageViewWidthConstraint.constant = self.imageViewWidthConstraint.constant / 0.9
        self.collectionViewBottomConstraint.constant = -100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "postToTwitter:")
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = composeButton
    }

    
    // MARK: - Action Sheet
    
    // UIButton and Action Sheet
    @IBAction func photoPressed(sender: AnyObject) {
        // Instantiate UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet) // UIAlertControllerStyle is an enum. Once typed, it'll give you options afterwards.
        
        // Create UIAlertActions
        let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Filter Action, calling animation function
            self.enterFilterMode()
        }
        let avfAction = UIAlertAction(title: "AVF Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_AVF", sender: self)
        }
        let cameraAction = UIAlertAction(title: "ImagePicker Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let imagePickerAction = UIAlertAction(title: "ImagePicker Moments", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let galleryAction = UIAlertAction(title: "HQ Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            // Segue from HomeViewController to GalleryViewController
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        
        let photosAction = UIAlertAction(title: "Photos Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTOS", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        // Add actions to UIAlertController
        alertController.addAction(filterAction)
        alertController.addAction(avfAction)
        alertController.addAction(cameraAction)
        alertController.addAction(imagePickerAction)
        alertController.addAction(galleryAction)
        alertController.addAction(photosAction)
        alertController.addAction(cancelAction)
        
        // Show alertController
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        } else if segue.identifier == "SHOW_PHOTOS" {
            let destinationVC = segue.destinationViewController as PhotosViewController
            destinationVC.delegate = self
        } else if segue.identifier == "SHOW_AVF" {
            let destinationVC = segue.destinationViewController as AVFViewController
            destinationVC.delegate = self
        }
    }
    
    // MARK: - viewDidLoad
    
    func setupVC() {
        var defaultImage = UIImage(named: "default")
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "postToTwitter:")
        // let postButton = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle., target: self, action: "postToTwitter:")
        self.navigationItem.rightBarButtonItem = composeButton
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 10
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.currentImage = defaultImage
        self.imageView.image = defaultImage
    }
    
}

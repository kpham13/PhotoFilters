//
//  HomeViewController.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/13/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import UIKit
import CoreData // 11
import CoreImage // 11
import OpenGLES // 11

// 4 ImagePickerControllerDelegate, NavigationControllerDelegate | 8.5 GalleryDelegate | 10.1 CollectionViewDataSource, CollectionViewDelegate
class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var galleryVC = GalleryViewController() //? and weak var in GalleryViewController
    
    var context : CIContext? // 11.1a Core Image Context
    var originalThumbnail : UIImage? // 11.2a
    //var filterNames = [String]() // DELETE 11.4
    var filters = [Filter]() // 12.1 Core Data array
    var filterThumbnails = [FilterThumbnail]() // 11.4 Array of wrappers
    let imageQueue = NSOperationQueue()
    var currentImage : UIImage?
    
    @IBOutlet weak var imageView: UIImageView! // 1 UIImageView and Outlet
    @IBOutlet weak var collectionView: UICollectionView! // 10 UICollectionView and Outlet
    
    // 10.4 Create Constraint Outlets for Filter/Animation
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageLoad()
        self.coreImageContext()
        self.generateThumbnail() // 11.5
        
        /*// DELETE 11.4
        self.filterNames.append("CISepiaTone")
        self.filterNames.append("CIGaussianBlur")
        self.filterNames.append("CIPixellate")
        self.filterNames.append("CIGammaAdjust")
        self.filterNames.append("CIExposureAdjust")
        self.filterNames.append("CIPhotoEffectChrome")
        self.filterNames.append("CIPhotoEffectInstant")
        self.filterNames.append("CIPhotoEffectMono")
        self.filterNames.append("CIPhotoEffectNoir")
        self.filterNames.append("CIPhotoEffectTonal")
        self.filterNames.append("CIPhotoEffectTransfer")
        */
        
        // 12.3 Call CoreDataSeeder function (data from appDelegate managedObjectContext)
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
        
        // 12.4a Fetch Filters
        self.fetchFilters()

        // 12.6a Reset Filter Thumbnails
        self.resetFilterThumbnails()
        
        // 10.2
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 10.3
    // MARK: - Collection View Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // CVH0 UIImage onto prototype cell. Create FilterCollectionViewCell custom class.
        // CVH1
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterCollectionViewCell
        
        // CVH2
        /* var filterThumbnail = FilterThumbnail(name: self.filterNames[indexPath.row], thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.context!)
        filterThumbnail.generateThumbnail { (image) -> Void in
            // Generating filtered thumbnails from FilterThumbnail class, then setting FilteredCollectionViewCell to image result
            cell.imageView.image = image
        } */
        // 12.5
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
    
    // 12.7
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
        self.exitFilterMode()
    }
    
    // MARK: - Action Sheet
    
    // 2 UIButton and Action Sheet
    @IBAction func photoPressed(sender: AnyObject) {
        // Instantiate UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet) // UIAlertControllerStyle is an enum. Once typed, it'll give you options afterwards.
        
        // Create UIAlertActions
        let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
            // 10.6 Filter Action, calling animation function
            self.enterFilterMode()
        }
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
        alertController.addAction(filterAction)
        alertController.addAction(cameraAction)
        alertController.addAction(imagePickerAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        // Show alertController
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // 5
    // MARK: - Image Picker Controller
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 8.6
    // MARK: - Gallery Delegate
    
    func didTapOnPicture(image : UIImage) {
        println("didTapOnPicture")
        self.currentImage = image
        self.imageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
    }
    
    // MARK: - Core Image Context
    
    // 11.1b Setting up Core Image Context
    func coreImageContext() {
        var options = [kCIContextWorkingColorSpace : NSNull()] //
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2) // Newer devices can use OpenGLES3
        self.context = CIContext(EAGLContext: myEAGLContext, options: options)
    }
    
    // MARK: - Photo Filter
    
    // 11.2b Generate Thumbnail
    func generateThumbnail() {
        let size = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    // 12.4b Fetch filters
    func fetchFilters() {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context = appDelegate.managedObjectContext
        
        var error : NSError?
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        let fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            println("Filters: \(filters.count)")
            self.filters = filters
            println("Filters: \(self.filters.count)")
        }
    }

    // 12.6b
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
    
    // MARK: - Animation
    
    // 10.5
    func enterFilterMode() {
        self.imageViewHeightConstraint.constant = self.imageViewHeightConstraint.constant * 0.9
        self.imageViewWidthConstraint.constant = self.imageViewWidthConstraint.constant * 0.9
        self.collectionViewBottomConstraint.constant = 50
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // 12.8
    func exitFilterMode() {
        self.imageViewHeightConstraint.constant = self.imageViewHeightConstraint.constant / 0.9
        self.imageViewWidthConstraint.constant = self.imageViewWidthConstraint.constant / 0.9
        self.collectionViewBottomConstraint.constant = -100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // 8.2
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
    }
    
    // MARK: - On Load
    
    func imageLoad() {
        var defaultImage = UIImage(named: "default")
        
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 6
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.currentImage = defaultImage
        self.imageView.image = defaultImage
    }
}
